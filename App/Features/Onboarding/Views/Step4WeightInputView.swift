//
//  Step4WeightInputView.swift
//  w-diet
//
//  Step 5: Weight Input - collects user's weight for calorie calculation
//

import SwiftUI

/// Step 5: Weight Input - collects user's weight for calorie calculation
struct Step4WeightInputView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Mascot with speech bubble
            VStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Theme.fireGold)

                Text("Wieviel wiegst du?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.gray100)
                    .cornerRadius(16)
            }
            .padding(.bottom, 24)

            // Weight Pickers (consistent 150pt height)
            HStack(spacing: 0) {
                Picker("Weight", selection: $viewModel.selectedWeightWhole) {
                    ForEach(40...200, id: \.self) { weight in
                        Text("\(weight)")
                            .font(.system(size: 28, weight: .semibold))
                            .tag(weight)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80, height: 150)
                .clipped()
                .onChange(of: viewModel.selectedWeightWhole) { _, _ in
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }

                Text(",")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                Picker("Decimal", selection: $viewModel.selectedWeightDecimal) {
                    ForEach(0...9, id: \.self) { decimal in
                        Text("\(decimal)")
                            .font(.system(size: 28, weight: .semibold))
                            .tag(decimal)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 50, height: 150)
                .clipped()
                .onChange(of: viewModel.selectedWeightDecimal) { _, _ in
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }

                Text("kg")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                    .padding(.leading, 8)
            }
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
}

// MARK: - Preview

#Preview {
    Step4WeightInputView(viewModel: OnboardingViewModel())
}
