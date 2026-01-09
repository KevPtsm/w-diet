//
//  Step2CalorieTargetView.swift
//  w-diet
//
//  Step 7: Calorie Target - shows calculated calorie goal
//

import SwiftUI

/// Step 7: Calorie Target - displays calculated calorie goal based on user data
struct Step2CalorieTargetView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Mascot with speech bubble
            VStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Theme.fireGold)

                Text("Dein persönliches Ziel")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.gray100)
                    .cornerRadius(16)
            }
            .padding(.bottom, 32)

            // Large calorie display
            VStack(spacing: 8) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(viewModel.calculatedCalorieTarget)")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(Theme.fireGold)

                    Text("kcal")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.textSecondary)
                }

                Text("pro Tag")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
            }
            .frame(height: 150)

            Spacer()

            // Tips at bottom
            VStack(spacing: 12) {
                // Green tip - Flexibility
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Das ist nur ein Richtwert")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text(flexibilityText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)

                // Yellow tip - Adjustable
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.title3)
                        .foregroundColor(.yellow)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tipp")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text("Du kannst dein Kalorienziel jederzeit in den Einstellungen anpassen.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
    }

    // MARK: - Computed Properties

    private var flexibilityText: String {
        let calories = viewModel.calculatedCalorieTarget
        guard calories > 0 else {
            return "Bis zu 200 kcal drüber ist völlig in Ordnung"
        }

        // Calculate 10% over, round to nearest 100
        let tenPercent = Double(calories) * 0.10
        let roundedBuffer = Int((tenPercent / 100.0).rounded()) * 100

        return "Bis zu \(roundedBuffer) kcal drüber ist völlig in Ordnung"
    }
}

// MARK: - Preview

#Preview {
    Step2CalorieTargetView(viewModel: OnboardingViewModel())
}
