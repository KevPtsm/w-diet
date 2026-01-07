//
//  Step4WeightInputView.swift
//  w-diet
//
//  Created for Story 1.3 - Enhanced Onboarding
//

import SwiftUI

/// Step 4: Weight Input - collects user's weight for calorie calculation
struct Step4WeightInputView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedWeightWhole: Int = 70 // Whole kg
    @State private var selectedWeightDecimal: Int = 0 // Decimal (0-9)

    var body: some View {
        VStack(spacing: 0) {
            // Header at top
            VStack(alignment: .leading, spacing: 8) {
                Text("Wie viel wiegst du aktuell?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)

                Text("Wir nutzen dies für deine Kalorienberechnung")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 20)

            Spacer()

            // Picker in center
            VStack(spacing: 24) {
                // Weight Pickers (kg + decimal)
                HStack(spacing: 0) {
                    // Whole kg picker
                    Picker("Weight", selection: $selectedWeightWhole) {
                        ForEach(40...200, id: \.self) { weight in
                            Text("\(weight)")
                                .font(.system(size: 26, weight: .semibold))
                                .tag(weight)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100, height: 150)
                    .clipped()
                    .onChange(of: selectedWeightWhole) { _, _ in
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        updateViewModel()
                    }

                    Text(".")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)

                    // Decimal picker
                    Picker("Decimal", selection: $selectedWeightDecimal) {
                        ForEach(0...9, id: \.self) { decimal in
                            Text("\(decimal)")
                                .font(.system(size: 26, weight: .semibold))
                                .tag(decimal)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60, height: 150)
                    .clipped()
                    .onChange(of: selectedWeightDecimal) { _, _ in
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        updateViewModel()
                    }

                    Text("kg")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                        .padding(.leading, 8)
                }
            }

            Spacer()
        }
        .onAppear {
            // Initialize with default or existing value
            if !viewModel.weightInput.isEmpty {
                if let weight = Double(viewModel.weightInput) {
                    selectedWeightWhole = Int(weight)
                    selectedWeightDecimal = Int((weight - Double(Int(weight))) * 10)
                }
            } else {
                // Set default to 70.0 kg
                selectedWeightWhole = 70
                selectedWeightDecimal = 0
                updateViewModel()
            }
        }
    }

    private func updateViewModel() {
        let weightValue = Double(selectedWeightWhole) + Double(selectedWeightDecimal) / 10.0
        viewModel.weightInput = String(format: "%.1f", weightValue)
        viewModel.weightInputError = nil
    }
}

// MARK: - Preview

#Preview {
    Step4WeightInputView(viewModel: OnboardingViewModel())
}
