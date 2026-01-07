//
//  RootView.swift
//  w-diet
//
//  Root view that determines whether to show onboarding or dashboard
//

import SwiftUI
import Combine
import GRDB

struct RootView: View {
    @StateObject private var viewModel = RootViewModel()
    @State private var refreshTrigger = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                // Loading state
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            await viewModel.checkOnboardingStatus()
        }
        .onChange(of: refreshTrigger) { _, _ in
            Task {
                await viewModel.checkOnboardingStatus()
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

    init(dbManager: GRDBManager = .shared) {
        self.dbManager = dbManager
    }

    func checkOnboardingStatus() async {
        // TEMPORARY: Use mock user ID until auth is set up
        let userId = "mock-user-id"

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
