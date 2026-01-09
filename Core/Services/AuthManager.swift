//
//  AuthManager.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 06.01.26.
//

import Foundation
import Supabase
import Combine

/// Authentication manager for Supabase Auth
///
/// **CRITICAL RULES:**
/// - Singleton pattern with shared instance
/// - JWT tokens stored in Keychain (NEVER UserDefaults)
/// - Published properties for SwiftUI reactivity
/// - All errors wrapped in AppError.auth()
///
/// **Usage:**
/// ```swift
/// // In w_dietApp.swift
/// .environmentObject(AuthManager.shared)
///
/// // In ViewModel
/// @EnvironmentObject var authManager: AuthManager
/// try await authManager.signInWithApple()
/// ```
@MainActor
final class AuthManager: ObservableObject {
    // MARK: - Singleton

    static let shared = AuthManager()

    // MARK: - Published Properties

    /// Whether user is currently authenticated
    @Published var isAuthenticated = false

    /// Current user ID from Supabase Auth (nil if not authenticated)
    @Published var currentUserId: String?

    /// Current user email (nil if not authenticated)
    @Published var currentUserEmail: String?

    // MARK: - Private Properties

    private let supabaseClient: SupabaseClient
    private let keychainService = "com.w-diet.auth"
    private let tokenKey = "supabase_session_token"

    // MARK: - Initialization

    // MARK: - Constants

    private static let redirectURL = URL(string: "w-diet://auth-callback")!

    private init() {
        // Initialize Supabase client with configuration
        // Use placeholder URL if configuration is not set up yet
        guard let supabaseURL = URL(string: AppConfiguration.supabaseURL.isEmpty ? "https://placeholder.supabase.co" : AppConfiguration.supabaseURL) else {
            fatalError("Invalid Supabase URL configuration")
        }

        self.supabaseClient = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: AppConfiguration.supabaseAnonKey.isEmpty ? "placeholder-key" : AppConfiguration.supabaseAnonKey,
            options: SupabaseClientOptions(
                auth: SupabaseClientOptions.AuthOptions(
                    redirectToURL: Self.redirectURL
                )
            )
        )

        // Only restore session if Supabase is properly configured
        if !AppConfiguration.supabaseURL.isEmpty {
            Task {
                await restoreSession()
            }
        }
    }

    // MARK: - Authentication Methods

    /// Sign in with Apple using ID token from native ASAuthorizationController
    func signInWithAppleToken(idToken: String) async throws {
        do {
            // Use Supabase Auth with Apple ID token
            let session = try await supabaseClient.auth.signInWithIdToken(
                credentials: .init(provider: .apple, idToken: idToken)
            )

            // Store session in Keychain
            try storeSession(session)

            // Update published state
            updateAuthState(session: session)

        } catch {
            let authError = AppError.auth(.signInFailed("Apple Sign-In failed: \(error.localizedDescription)"))
            authError.report()
            throw authError
        }
    }

    /// Sign in with Google OAuth (requires Google Cloud Console setup)
    func signInWithGoogle() async throws {
        do {
            // Supabase Auth SDK handles Google OAuth flow via web redirect
            // NOTE: Requires Google OAuth configured in Supabase dashboard
            try await supabaseClient.auth.signInWithOAuth(provider: .google)

            // Session will be handled by URL callback
            // Check for active session after redirect
            if let session = try? await supabaseClient.auth.session {
                try storeSession(session)
                updateAuthState(session: session)
            }

        } catch {
            let authError = AppError.auth(.signInFailed("Google Sign-In failed: \(error.localizedDescription)"))
            authError.report()
            throw authError
        }
    }

    /// Sign in with Email/Password
    func signInWithEmail(email: String, password: String) async throws {
        do {
            // Validate inputs
            guard !email.isEmpty, !password.isEmpty else {
                throw AppError.auth(.invalidCredentials)
            }

            // Supabase Auth SDK handles email/password authentication
            let session = try await supabaseClient.auth.signIn(email: email, password: password)

            // Store session in Keychain
            try storeSession(session)

            // Update published state
            updateAuthState(session: session)

        } catch let error as AppError {
            error.report()
            throw error
        } catch {
            let authError = AppError.auth(.signInFailed("Email Sign-In failed: \(error.localizedDescription)"))
            authError.report()
            throw authError
        }
    }

    /// Sign up with Email/Password (creates new account)
    func signUpWithEmail(email: String, password: String) async throws {
        do {
            // Validate inputs (10 char minimum per industry standard)
            guard !email.isEmpty, password.count >= 10 else {
                throw AppError.auth(.invalidCredentials)
            }

            // Supabase Auth SDK handles email/password registration
            let response = try await supabaseClient.auth.signUp(email: email, password: password)

            // Check if email confirmation is required
            if let session = response.session {
                // Auto-confirmed - store session
                try storeSession(session)
                updateAuthState(session: session)
            } else {
                // Email confirmation required - throw informational error
                throw AppError.auth(.signInFailed("Bitte bestätige deine E-Mail-Adresse."))
            }

        } catch let error as AppError {
            error.report()
            throw error
        } catch {
            let authError = AppError.auth(.signInFailed("Registration failed: \(error.localizedDescription)"))
            authError.report()
            throw authError
        }
    }

    /// Sign out current user
    func signOut() async throws {
        do {
            // Sign out from Supabase
            try await supabaseClient.auth.signOut()

            // Clear Keychain
            try clearSession()

            // Update published state
            isAuthenticated = false
            currentUserId = nil
            currentUserEmail = nil

        } catch {
            let authError = AppError.auth(.signInFailed("Sign out failed: \(error.localizedDescription)"))
            authError.report()
            throw authError
        }
    }

    // MARK: - OAuth Callback

    /// Handle OAuth callback URL from external browser
    func handleOAuthCallback(url: URL) async {
        do {
            let session = try await supabaseClient.auth.session(from: url)
            try storeSession(session)
            updateAuthState(session: session)
        } catch {
            #if DEBUG
            print("⚠️ OAuth callback failed: \(error)")
            #endif
        }
    }

    // MARK: - Session Management

    /// Restore session from Keychain on app launch
    private func restoreSession() async {
        do {
            // Try to retrieve session from Keychain
            guard let sessionData = try retrieveSessionFromKeychain(),
                  let session = try? JSONDecoder().decode(Session.self, from: sessionData) else {
                return
            }

            // Verify session is still valid with Supabase
            let currentSession = try await supabaseClient.auth.session

            // Update auth state
            await updateAuthState(session: currentSession)

        } catch {
            // Silent failure - user will need to sign in again
            #if DEBUG
            print("⚠️ Failed to restore session: \(error)")
            #endif
        }
    }

    /// Update authentication state from session
    private func updateAuthState(session: Session) {
        isAuthenticated = true
        currentUserId = session.user.id.uuidString
        currentUserEmail = session.user.email
    }

    // MARK: - Keychain Storage

    /// Store session in Keychain (NEVER UserDefaults - security requirement)
    private func storeSession(_ session: Session) throws {
        do {
            let sessionData = try JSONEncoder().encode(session)

            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: keychainService,
                kSecAttrAccount as String: tokenKey,
                kSecValueData as String: sessionData
            ]

            // Delete existing item first
            SecItemDelete(query as CFDictionary)

            // Add new item
            let status = SecItemAdd(query as CFDictionary, nil)

            guard status == errSecSuccess else {
                throw AppError.auth(.tokenStorageFailed)
            }

        } catch {
            let authError = AppError.auth(.tokenStorageFailed)
            authError.report()
            throw authError
        }
    }

    /// Retrieve session from Keychain
    private func retrieveSessionFromKeychain() throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw AppError.auth(.tokenRetrievalFailed)
        }

        return result as? Data
    }

    /// Clear session from Keychain
    private func clearSession() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AppError.auth(.tokenClearFailed)
        }
    }

    // MARK: - Supabase Sync

    /// Sync user profile to Supabase database
    func syncUserProfile(_ profile: UserProfile) async throws {
        guard isAuthenticated else {
            throw AppError.auth(.notAuthenticated)
        }

        do {
            // Prepare profile data for Supabase (using snake_case keys)
            let profileData: [String: AnyJSON] = [
                "user_id": .string(profile.userId),
                "email": .string(profile.email),
                "goal": profile.goal.map { .string($0) } ?? .null,
                "calorie_target": profile.calorieTarget.map { .integer($0) } ?? .null,
                "eating_window_start": profile.eatingWindowStart.map { .string($0) } ?? .null,
                "eating_window_end": profile.eatingWindowEnd.map { .string($0) } ?? .null,
                "onboarding_completed": .bool(profile.onboardingCompleted),
                "gender": profile.gender.map { .string($0) } ?? .null,
                "age": profile.age.map { .integer($0) } ?? .null,
                "height_cm": profile.heightCm.map { .double($0) } ?? .null,
                "weight_kg": profile.weightKg.map { .double($0) } ?? .null,
                "activity_level": profile.activityLevel.map { .string($0) } ?? .null,
                "calculated_calories": profile.calculatedCalories.map { .integer($0) } ?? .null,
                "updated_at": .string(ISO8601DateFormatter().string(from: Date()))
            ]

            // Upsert to Supabase (insert or update based on user_id)
            try await supabaseClient
                .from("user_profiles")
                .upsert(profileData, onConflict: "user_id")
                .execute()

            #if DEBUG
            print("✅ User profile synced to Supabase")
            #endif

        } catch {
            #if DEBUG
            print("⚠️ Failed to sync profile to Supabase: \(error)")
            #endif
            // Don't throw - sync failure shouldn't break the app (offline-first)
        }
    }
}
