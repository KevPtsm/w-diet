//
//  RootView.swift
//  w-diet
//
//  Root view that determines whether to show login, onboarding, or dashboard
//

import Combine
import GRDB
import SwiftUI

struct RootView: View {
    @StateObject private var viewModel = RootViewModel()
    @ObservedObject private var authManager = AuthManager.shared
    @State private var refreshTrigger = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                // Loading state
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !authManager.isAuthenticated {
                // Show login
                LoginView()
            } else if viewModel.needsOnboarding {
                // Show onboarding
                OnboardingContainerView()
                    .environment(\.onboardingCompleted, {
                        refreshTrigger.toggle()
                    })
            } else {
                // Show dashboard
                DashboardView()
            }
        }
        .task {
            await viewModel.checkAuthAndOnboarding()
        }
        .onChange(of: refreshTrigger) { _, _ in
            Task {
                await viewModel.checkAuthAndOnboarding()
            }
        }
        .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                Task {
                    await viewModel.checkAuthAndOnboarding()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .profileDidReset)) { _ in
            Task {
                await viewModel.checkAuthAndOnboarding()
            }
        }
    }
}

// Environment key for onboarding completion callback
private struct OnboardingCompletedKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var onboardingCompleted: () -> Void {
        get { self[OnboardingCompletedKey.self] }
        set { self[OnboardingCompletedKey.self] = newValue }
    }
}

@MainActor
final class RootViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var needsOnboarding = true

    private let dbManager: GRDBManager
    private let authManager: AuthManager

    init(dbManager: GRDBManager = .shared, authManager: AuthManager = .shared) {
        self.dbManager = dbManager
        self.authManager = authManager
    }

    func checkAuthAndOnboarding() async {
        // Get user ID from AuthManager
        guard let userId = authManager.currentUserId else {
            // Not authenticated - will show login
            isLoading = false
            return
        }

        do {
            // Check if user profile exists and onboarding is completed
            let profile = try await dbManager.read { db in
                try UserProfile.fetchByUserId(db, userId: userId)
            }

            needsOnboarding = profile?.onboardingCompleted == false || profile == nil

        } catch {
            // If error, assume needs onboarding
            needsOnboarding = true
        }

        isLoading = false
    }
}
