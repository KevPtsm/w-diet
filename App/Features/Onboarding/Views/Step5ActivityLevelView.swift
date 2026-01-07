//
//  Step5ActivityLevelView.swift
//  w-diet
//
//  Created for Story 1.3 - Enhanced Onboarding
//

import SwiftUI

/// Step 5: Activity Level - collects user's activity level for calorie calculation
struct Step5ActivityLevelView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header at top
            VStack(alignment: .leading, spacing: 8) {
                Text("Wie aktiv bist du?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)

                Text("Dies hilft uns, deinen Kalorienbedarf zu berechnen")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 20)

            Spacer()

            // Activity Level Cards centered
            VStack(spacing: 12) {
                activityLevelCard(
                    level: "sedentary",
                    title: "Wenig aktiv",
                    description: "Kaum oder kein Sport"
                )

                activityLevelCard(
                    level: "lightly_active",
                    title: "Leicht aktiv",
                    description: "Sport 1-3 Tage/Woche"
                )

                activityLevelCard(
                    level: "moderately_active",
                    title: "Mäßig aktiv",
                    description: "Sport 3-5 Tage/Woche"
                )

                activityLevelCard(
                    level: "very_active",
                    title: "Sehr aktiv",
                    description: "Sport 6-7 Tage/Woche"
                )

                activityLevelCard(
                    level: "extra_active",
                    title: "Extrem aktiv",
                    description: "Intensives Training täglich"
                )
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    // MARK: - Activity Level Card

    private func activityLevelCard(level: String, title: String, description: String) -> some View {
        Button(action: {
            viewModel.selectedActivityLevel = level
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(viewModel.selectedActivityLevel == level ? .white : Theme.textPrimary)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(viewModel.selectedActivityLevel == level ? .white.opacity(0.9) : Theme.textSecondary)
                }

                Spacer()

                if viewModel.selectedActivityLevel == level {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                }
            }
            .padding()
            .background(viewModel.selectedActivityLevel == level ? Theme.fireGold : Theme.gray100)
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview

#Preview {
    Step5ActivityLevelView(viewModel: OnboardingViewModel())
}
