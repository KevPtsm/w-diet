//
//  Step2GenderSelectionView.swift
//  w-diet
//
//  Created for Story 1.3 - Enhanced Onboarding
//

import SwiftUI

/// Step 2: Gender Selection - collects user's gender for calorie calculation
struct Step2GenderSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header at top
            VStack(alignment: .leading, spacing: 8) {
                Text("Was ist dein Geschlecht?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)

                Text("Wir nutzen dies für präzise Kalorienberechnungen")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 20)

            Spacer()

            // Gender Cards centered
            VStack(spacing: 16) {
                genderCard(
                    gender: "male",
                    title: "Männlich",
                    icon: "figure.stand"
                )

                genderCard(
                    gender: "female",
                    title: "Weiblich",
                    icon: "figure.stand.dress"
                )
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    // MARK: - Gender Card

    private func genderCard(gender: String, title: String, icon: String) -> some View {
        Button(action: {
            viewModel.selectedGender = gender
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(viewModel.selectedGender == gender ? .white : Theme.fireGold)
                    .frame(width: 60, height: 60)

                Text(title)
                    .font(.headline)
                    .foregroundColor(viewModel.selectedGender == gender ? .white : Theme.textPrimary)

                Spacer()

                if viewModel.selectedGender == gender {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            .padding()
            .background(viewModel.selectedGender == gender ? Theme.fireGold : Theme.gray100)
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview

#Preview {
    Step2GenderSelectionView(viewModel: OnboardingViewModel())
}
