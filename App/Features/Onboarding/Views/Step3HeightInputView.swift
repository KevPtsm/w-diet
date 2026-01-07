//
//  Step3HeightInputView.swift
//  w-diet
//
//  Created for Story 1.3 - Enhanced Onboarding
//

import SwiftUI

/// Step 3: Height Input - collects user's height for calorie calculation
struct Step3HeightInputView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedHeightCm: Int = 170 // Default 170 cm (1.70m)

    var body: some View {
        VStack(spacing: 0) {
            // Header at top
            VStack(alignment: .leading, spacing: 8) {
                Text("Wie groß bist du?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)

                Text("Scrolle, um deine Größe in Metern auszuwählen")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 20)

            Spacer()

            // Picker in center
            VStack(spacing: 24) {
                // Height Picker (meters)
                Picker("Height", selection: $selectedHeightCm) {
                    ForEach(100...220, id: \.self) { heightCm in
                        let meters = Double(heightCm) / 100.0
                        Text(String(format: "%.2f m", meters))
                            .font(.system(size: 26, weight: .semibold))
                            .tag(heightCm)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .onChange(of: selectedHeightCm) { _, _ in
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    updateViewModel()
                }
            }

            Spacer()
        }
        .onAppear {
            // Initialize with default or existing value
            if !viewModel.heightInput.isEmpty {
                if let height = Double(viewModel.heightInput) {
                    selectedHeightCm = Int(height)
                    // Clamp to valid range
                    if selectedHeightCm < 100 {
                        selectedHeightCm = 100
                    } else if selectedHeightCm > 220 {
                        selectedHeightCm = 220
                    }
                }
            } else {
                // Set default to 170 cm (1.70m)
                selectedHeightCm = 170
                updateViewModel()
            }
        }
    }

    private func updateViewModel() {
        // Store as cm internally for calculations
        viewModel.heightInput = "\(selectedHeightCm)"
        viewModel.heightInputError = nil
    }
}

// MARK: - Preview

#Preview {
    Step3HeightInputView(viewModel: OnboardingViewModel())
}
