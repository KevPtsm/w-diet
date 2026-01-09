//
//  LoginViewModel.swift
//  w-diet
//
//  ViewModel for login screen
//

import AuthenticationServices
import Combine
import Foundation
import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false

    // MARK: - Dependencies

    private let authManager: AuthManager

    // MARK: - Initialization

    init(authManager: AuthManager? = nil) {
        self.authManager = authManager ?? AuthManager.shared
    }

    // MARK: - Apple Sign In

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        isLoading = true
        defer { isLoading = false }

        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityToken = appleIDCredential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8) else {
                errorMessage = "Apple Sign-In Daten konnten nicht verarbeitet werden."
                return
            }

            do {
                try await authManager.signInWithAppleToken(idToken: tokenString)
                isAuthenticated = true
            } catch let error as AppError {
                errorMessage = error.userMessage
            } catch {
                errorMessage = "Apple Sign-In fehlgeschlagen: \(error.localizedDescription)"
            }

        case .failure(let error):
            // User cancelled - don't show error
            if let authError = error as? ASAuthorizationError,
               authError.code == .canceled {
                return
            }
            errorMessage = "Apple Sign-In fehlgeschlagen: \(error.localizedDescription)"
        }
    }

    // MARK: - Google Sign In

    func signInWithGoogle() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await authManager.signInWithGoogle()
            isAuthenticated = true
        } catch let error as AppError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = "Google Sign-In fehlgeschlagen: \(error.localizedDescription)"
        }
    }

    // MARK: - Email Sign In

    func signInWithEmail(email: String, password: String) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Bitte E-Mail und Passwort eingeben."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authManager.signInWithEmail(email: email, password: password)
            isAuthenticated = true
        } catch let error as AppError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = "Anmeldung fehlgeschlagen: \(error.localizedDescription)"
        }
    }

    // MARK: - Email Sign Up

    func signUpWithEmail(email: String, password: String) async {
        guard !email.isEmpty else {
            errorMessage = "Bitte E-Mail eingeben."
            return
        }

        guard password.count >= 10 else {
            errorMessage = "Passwort muss mindestens 10 Zeichen lang sein."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authManager.signUpWithEmail(email: email, password: password)
            isAuthenticated = true
        } catch let error as AppError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = "Registrierung fehlgeschlagen: \(error.localizedDescription)"
        }
    }
}
