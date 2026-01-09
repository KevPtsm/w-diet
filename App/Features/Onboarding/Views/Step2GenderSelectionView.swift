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
    @Environment(\.isConfirmingSelection) private var isConfirming

    var body: some View {
        let _ = preSelectGender()
        VStack(spacing: 0) {
            Spacer()

            // Mascot with invisible speech bubble (matches age screen layout)
            VStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Theme.fireGold)

                // Invisible placeholder to match speech bubble height
                Text("Wie alt bist du?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .opacity(0)
            }
            .padding(.bottom, 24)

            // Gender Cards - Side by Side (fixed height for consistency)
            HStack(spacing: 16) {
                genderCard(gender: "male", icon: "♂")
                genderCard(gender: "female", icon: "♀")
            }
            .padding(.horizontal, 48)
            .frame(height: 150)

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

    private func preSelectGender() {
        if viewModel.selectedGender == nil {
            viewModel.selectedGender = "male"
        }
    }

    // MARK: - Gender Card

    private func genderCard(gender: String, icon: String) -> some View {
        let isSelected = viewModel.selectedGender == gender

        return Button(action: {
            viewModel.selectedGender = gender
        }) {
            ZStack {
                // Icon - consistent size
                Text(icon)
                    .font(.system(size: 44))
                    .foregroundColor(isSelected ? .white : Theme.fireGold)

                // Checkmark overlay
                if isSelected {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(12)
                }
            }
            .frame(width: 120, height: 120)
            .background(isSelected ? Theme.fireGold : Theme.backgroundSecondary)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected ? Color.clear : Theme.gray300, lineWidth: 1)
            )
            .scaleEffect(isSelected && isConfirming ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isConfirming)
        }
    }
}

// MARK: - Preview

#Preview {
    Step2GenderSelectionView(viewModel: OnboardingViewModel())
}
