//
//  LoginView.swift
//  w-diet
//
//  Authentication screen with Apple, Google, and Email registration options
//

import AuthenticationServices
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var isLoginMode = false // false = register, true = login

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Logo
                Image(systemName: "flame.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.fireGold)

                Spacer()

                // Registration/Login Options
                VStack(spacing: 16) {
                    // Apple Button (Custom for German text)
                    Button {
                        triggerAppleSignIn()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "apple.logo")
                                .font(.title2)
                            Text(isLoginMode ? "Mit Apple anmelden" : "Mit Apple registrieren")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Theme.fireGold)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }

                    // Google Button
                    Button {
                        Task {
                            await viewModel.signInWithGoogle()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "g.circle.fill")
                                .font(.title2)
                            Text(isLoginMode ? "Mit Google anmelden" : "Mit Google registrieren")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Theme.fireGold)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }

                // Terms notice
                Text("Mit der Registrierung stimmst du unseren Nutzungsbedingungen und Datenschutzrichtlinien zu.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                // Toggle Login/Register at bottom
                Button {
                    isLoginMode.toggle()
                } label: {
                    Text(isLoginMode ? "Noch kein Konto? Registrieren" : "Bereits ein Konto? Anmelden")
                        .font(.subheadline)
                        .foregroundColor(Theme.fireGold)
                }
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 24)
            .background(Theme.backgroundPrimary)
            .overlay {
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
            .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }

    // MARK: - Apple Sign In

    private func triggerAppleSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.performRequests()

        // Handle via coordinator
        AppleSignInCoordinator.shared.viewModel = viewModel
        controller.delegate = AppleSignInCoordinator.shared
    }
}

// MARK: - Apple Sign In Coordinator

class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate {
    static let shared = AppleSignInCoordinator()
    var viewModel: LoginViewModel?

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            await viewModel?.handleAppleSignIn(result: .success(authorization))
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task { @MainActor in
            await viewModel?.handleAppleSignIn(result: .failure(error))
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView()
}
