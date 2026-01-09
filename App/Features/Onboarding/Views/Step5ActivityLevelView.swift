//
//  Step5ActivityLevelView.swift
//  w-diet
//
//  Step 6: Activity Level - collects user's activity level for calorie calculation
//

import SwiftUI

/// Step 6: Activity Level - collects user's activity level for calorie calculation
struct Step5ActivityLevelView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.isConfirmingSelection) private var isConfirming

    var body: some View {
        let _ = preSelectActivityLevel()
        VStack(spacing: 0) {
            Spacer()

            // Mascot with speech bubble
            VStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Theme.fireGold)

                Text("Wie aktiv bist du?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.gray100)
                    .cornerRadius(16)
            }
            .padding(.bottom, 24)

            // Activity Level Cards
            VStack(spacing: 12) {
                activityLevelCard(
                    level: "sedentary",
                    title: "Wenig aktiv",
                    icon: "figure.stand"
                )

                activityLevelCard(
                    level: "lightly_active",
                    title: "Leicht aktiv",
                    icon: "figure.walk"
                )

                activityLevelCard(
                    level: "moderately_active",
                    title: "Mäßig aktiv",
                    icon: "figure.run"
                )

                activityLevelCard(
                    level: "very_active",
                    title: "Sehr aktiv",
                    icon: "figure.highintensity.intervaltraining"
                )

                activityLevelCard(
                    level: "extra_active",
                    title: "Extrem aktiv",
                    icon: "figure.martial.arts"
                )
            }
            .padding(.horizontal, 32)

            // Tip card
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.title3)
                    .foregroundColor(.yellow)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Tipp")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("Dies ist relevant für die Kalorienberechnung.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal, 32)
            .padding(.top, 16)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Pre-select Default

    private func preSelectActivityLevel() {
        if viewModel.selectedActivityLevel == nil {
            viewModel.selectedActivityLevel = "lightly_active"
        }
    }

    // MARK: - Activity Level Card

    private func activityLevelCard(level: String, title: String, icon: String) -> some View {
        let isSelected = viewModel.selectedActivityLevel == level

        return Button(action: {
            viewModel.selectedActivityLevel = level
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : Theme.fireGold)
                    .frame(width: 32)

                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)

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
            .frame(height: 56)
            .background(isSelected ? Theme.fireGold : Theme.backgroundSecondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.clear : Theme.gray300, lineWidth: 1)
            )
            .scaleEffect(isSelected && isConfirming ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isConfirming)
        }
    }
}

// MARK: - Preview

#Preview {
    Step5ActivityLevelView(viewModel: OnboardingViewModel())
}
