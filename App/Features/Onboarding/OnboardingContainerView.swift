//
//  OnboardingContainerView.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 06.01.26.
//

import SwiftUI

/// Container view for the onboarding flow (0 = consent, 1-10 = steps)
///
/// **CRITICAL RULES:**
/// - @StateObject for ViewModel (NOT in init!)
/// - NavigationStack (NOT NavigationView)
/// - No way to skip or dismiss until complete
/// - Progress indicator shows current step (hidden on consent screen)
/// - GDPR consent (Step 0) must be completed before health data collection
struct OnboardingContainerView: View {
    // MARK: - State

    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.onboardingCompleted) private var onboardingCompleted
    @State private var isConfirming = false

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
                    .environment(\.isConfirmingSelection, isConfirming)

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
        // Weight loss: 9 steps (includes age, MATADOR and eating window - skips redundant completion screen)
        // Maintain/Gain: 8 steps (includes age, skips MATADOR and eating window)
        // Note: Step 0 (consent) is not counted in progress
        viewModel.selectedGoal == "lose_weight" ? 9 : 8
    }

    private var progressIndicator: some View {
        Group {
            // Hide progress indicator on consent screen (step 0)
            if viewModel.currentStep > 0 {
                HStack(spacing: 8) {
                    ForEach(1...totalSteps, id: \.self) { step in
                        Circle()
                            .fill(step == viewModel.currentStep ? Theme.fireGold : Theme.gray300)
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.vertical, 16)
            } else {
                // Placeholder for consent screen
                Spacer()
                    .frame(height: 42)
            }
        }
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case 0:
            Step0ConsentView(viewModel: viewModel)
        case 1:
            Step1GoalSelectionView(viewModel: viewModel)
        case 2:
            Step2GenderSelectionView(viewModel: viewModel)
        case 3:
            Step3AgeInputView(viewModel: viewModel)
        case 4:
            Step3HeightInputView(viewModel: viewModel)
        case 5:
            Step4WeightInputView(viewModel: viewModel)
        case 6:
            Step5ActivityLevelView(viewModel: viewModel)
        case 7:
            Step2CalorieTargetView(viewModel: viewModel)
        case 8:
            // For weight loss: show MATADOR explainer
            // For maintain/gain: skip to completion
            if viewModel.selectedGoal == "lose_weight" {
                Step4MatadorExplainerView(viewModel: viewModel)
            } else {
                Step5CompletionView(viewModel: viewModel, onComplete: handleOnboardingComplete)
            }
        case 9:
            // For weight loss: show eating window after MATADOR
            if viewModel.selectedGoal == "lose_weight" {
                Step3EatingWindowView(viewModel: viewModel)
            } else {
                Text("Unknown step")
            }
        case 10:
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
        Group {
            // Hide navigation buttons on consent screen (step 0) - slider handles navigation
            if viewModel.currentStep > 0 {
                HStack {
                    // Back Button (hidden on step 1)
                    if viewModel.currentStep > 1 {
                        Button(action: {
                            viewModel.previousStep()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                    }

                    Spacer()

                    // Continue/Complete Button
                    if viewModel.currentStep < totalSteps {
                        // Regular continue button
                        Button(action: {
                            // Trigger confirmation animation
                            withAnimation(.easeInOut(duration: 0.15)) {
                                isConfirming = true
                            }
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            // Navigate after brief delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    isConfirming = false
                                }
                                viewModel.nextStep()
                            }
                        }) {
                            Image(systemName: "arrow.right")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(viewModel.canContinue ? .white : Theme.gray300)
                                .frame(width: 56, height: 56)
                                .background(viewModel.canContinue ? Theme.fireGold : Theme.gray100)
                                .clipShape(Circle())
                        }
                        .disabled(!viewModel.canContinue || isConfirming)
                    } else if viewModel.currentStep == totalSteps {
                        // Final step - complete onboarding button
                        Button(action: {
                            // Trigger confirmation animation
                            withAnimation(.easeInOut(duration: 0.15)) {
                                isConfirming = true
                            }
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            // Complete onboarding after brief delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    isConfirming = false
                                }
                                handleOnboardingComplete()
                            }
                        }) {
                            Image(systemName: "checkmark")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Theme.fireGold)
                                .clipShape(Circle())
                        }
                        .disabled(isConfirming)
                    }
                }
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

// MARK: - Environment Key for Confirmation Animation

private struct IsConfirmingSelectionKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isConfirmingSelection: Bool {
        get { self[IsConfirmingSelectionKey.self] }
        set { self[IsConfirmingSelectionKey.self] = newValue }
    }
}

// MARK: - Preview

#Preview {
    OnboardingContainerView()
}
