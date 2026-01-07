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

    private init() {
        // Initialize Supabase client with configuration
        // Use placeholder URL if configuration is not set up yet
        guard let supabaseURL = URL(string: AppConfiguration.supabaseURL.isEmpty ? "https://placeholder.supabase.co" : AppConfiguration.supabaseURL) else {
            fatalError("Invalid Supabase URL configuration")
        }

        self.supabaseClient = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: AppConfiguration.supabaseAnonKey.isEmpty ? "placeholder-key" : AppConfiguration.supabaseAnonKey
        )

        // Only restore session if Supabase is properly configured
        if !AppConfiguration.supabaseURL.isEmpty {
            Task {
                await restoreSession()
            }
        }
    }

    // MARK: - Authentication Methods

    /// Sign in with Apple OAuth
    func signInWithApple() async throws {
        do {
            // Supabase Auth SDK handles Apple OAuth flow
            let session = try await supabaseClient.auth.signInWithOAuth(provider: .apple)

            // Store session in Keychain
            try storeSession(session)

            // Update published state
            await updateAuthState(session: session)

        } catch {
            let authError = AppError.auth(.signInFailed("Apple Sign-In failed: \(error.localizedDescription)"))
            authError.report()
            throw authError
        }
    }

    /// Sign in with Google OAuth
    func signInWithGoogle() async throws {
        do {
            // Supabase Auth SDK handles Google OAuth flow
            let session = try await supabaseClient.auth.signInWithOAuth(provider: .google)

            // Store session in Keychain
            try storeSession(session)

            // Update published state
            await updateAuthState(session: session)

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
            await updateAuthState(session: session)

        } catch let error as AppError {
            error.report()
            throw error
        } catch {
            let authError = AppError.auth(.signInFailed("Email Sign-In failed: \(error.localizedDescription)"))
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
}
