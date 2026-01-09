//
//  Step1GoalSelectionView.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 06.01.26.
//

import SwiftUI

/// Step 1: Goal Selection - allows user to choose fitness goal
struct Step1GoalSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.isConfirmingSelection) private var isConfirming

    var body: some View {
        let _ = preSelectGoal()
        VStack(spacing: 0) {
            Spacer()

            // Mascot with speech bubble
            VStack(spacing: 12) {
                // Flame mascot
                Image(systemName: "flame.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Theme.fireGold)

                // Speech bubble with question
                Text("Was ist dein Ziel?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.gray100)
                    .cornerRadius(16)
            }
            .offset(y: -7) // Fine-tune mascot position to match other screens
            .padding(.bottom, 24)

            // Goal Cards
            VStack(spacing: 16) {
                goalCard(
                    goal: "lose_weight",
                    title: "Abnehmen",
                    icon: "flame.fill",
                    isEnabled: true
                )

                goalCard(
                    goal: "maintain_weight",
                    title: "Gewicht halten",
                    icon: "scalemass.fill",
                    isEnabled: false
                )

                goalCard(
                    goal: "gain_muscle",
                    title: "Muskeln aufbauen",
                    icon: "dumbbell.fill",
                    isEnabled: false
                )
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Goal Card

    private func goalCard(goal: String, title: String, icon: String, isEnabled: Bool) -> some View {
        let isSelected = viewModel.selectedGoal == goal && isEnabled

        return Button(action: {
            if isEnabled {
                viewModel.selectedGoal = goal
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(isEnabled ? (isSelected ? .white : Theme.fireGold) : Theme.disabled)
                    .frame(width: 40)

                Text(title)
                    .font(.headline)
                    .foregroundColor(isEnabled ? (isSelected ? .white : .primary) : Theme.disabled)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(isSelected ? Theme.fireGold : Theme.backgroundSecondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.clear : Theme.gray300, lineWidth: 1)
            )
            .overlay(alignment: .topTrailing) {
                if !isEnabled {
                    soonBadge
                        .offset(x: 8, y: -8)
                }
            }
            .scaleEffect(isSelected && isConfirming ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isConfirming)
        }
        .disabled(!isEnabled)
    }

    // MARK: - Soon Badge

    private var soonBadge: some View {
        Text("Soon")
            .font(.system(size: 11))
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Theme.fireGold)
            .cornerRadius(6)
    }

    // MARK: - Pre-select Default

    private func preSelectGoal() {
        if viewModel.selectedGoal == nil {
            viewModel.selectedGoal = "lose_weight"
        }
    }
}

// MARK: - Preview

#Preview {
    Step1GoalSelectionView(viewModel: OnboardingViewModel())
}
