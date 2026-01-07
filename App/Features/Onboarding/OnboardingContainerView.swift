//
//  OnboardingContainerView.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 06.01.26.
//

import SwiftUI

/// Container view for the onboarding flow (9 steps)
///
/// **CRITICAL RULES:**
/// - @StateObject for ViewModel (NOT in init!)
/// - NavigationStack (NOT NavigationView)
/// - No way to skip or dismiss until complete
/// - Progress indicator shows current step
struct OnboardingContainerView: View {
    // MARK: - State

    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.onboardingCompleted) private var onboardingCompleted

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Indicator
                progressIndicator
                    .padding(.top)

                // Step Content
                stepContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Navigation Buttons
                navigationButtons
                    .padding()
            }
            .navigationBarBackButtonHidden(true)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
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

    // MARK: - Progress Indicator

    private var totalSteps: Int {
        // Weight loss: 9 steps (includes MATADOR and eating window)
        // Maintain/Gain: 7 steps (skips MATADOR and eating window)
        viewModel.selectedGoal == "lose_weight" ? 9 : 7
    }

    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step == viewModel.currentStep ? Theme.fireGold : Theme.gray300)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 16)
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case 1:
            Step1GoalSelectionView(viewModel: viewModel)
        case 2:
            Step2GenderSelectionView(viewModel: viewModel)
        case 3:
            Step3HeightInputView(viewModel: viewModel)
        case 4:
            Step4WeightInputView(viewModel: viewModel)
        case 5:
            Step5ActivityLevelView(viewModel: viewModel)
        case 6:
            Step2CalorieTargetView(viewModel: viewModel)
        case 7:
            // For weight loss: show MATADOR explainer
            // For maintain/gain: skip to completion
            if viewModel.selectedGoal == "lose_weight" {
                Step4MatadorExplainerView(viewModel: viewModel)
            } else {
                Step5CompletionView(viewModel: viewModel, onComplete: handleOnboardingComplete)
            }
        case 8:
            // For weight loss: show eating window after MATADOR
            if viewModel.selectedGoal == "lose_weight" {
                Step3EatingWindowView(viewModel: viewModel)
            } else {
                Text("Unknown step")
            }
        case 9:
            // For weight loss: completion
            if viewModel.selectedGoal == "lose_weight" {
                Step5CompletionView(viewModel: viewModel, onComplete: handleOnboardingComplete)
            } else {
                Text("Unknown step")
            }
        default:
            Text("Unknown step")
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack {
            // Back Button (hidden on step 1)
            if viewModel.currentStep > 1 {
                Button(action: {
                    viewModel.previousStep()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Zurück")
                    }
                }
                .foregroundColor(Theme.fireGold)
            }

            Spacer()

            // Continue Button (hidden on completion step)
            if viewModel.currentStep < totalSteps {
                Button(action: {
                    viewModel.nextStep()
                }) {
                    Text("Weiter")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(viewModel.canContinue ? Theme.fireGold : Theme.disabled)
                        .cornerRadius(10)
                }
                .disabled(!viewModel.canContinue)
            }
        }
    }

    // MARK: - Actions

    private func handleOnboardingComplete() {
        Task {
            await viewModel.completeOnboarding()

            // Notify parent that onboarding is complete
            onboardingCompleted()
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingContainerView()
}
