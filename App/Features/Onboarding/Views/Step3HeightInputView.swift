//
//  Step3HeightInputView.swift
//  w-diet
//
//  Step 4: Height Input - collects user's height for calorie calculation
//

import SwiftUI

/// Step 4: Height Input - collects user's height for calorie calculation
struct Step3HeightInputView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Mascot with speech bubble
            VStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Theme.fireGold)

                Text("Wie groß bist du?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.gray100)
                    .cornerRadius(16)
            }
            .padding(.bottom, 24)

            // Height Picker (consistent 150pt height)
            HStack(spacing: 0) {
                Picker("Height", selection: $viewModel.selectedHeight) {
                    ForEach(100...220, id: \.self) { heightCm in
                        let meters = Double(heightCm) / 100.0
                        Text(String(format: "%.2f", meters))
                            .font(.system(size: 28, weight: .semibold))
                            .tag(heightCm)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 100, height: 150)
                .clipped()
                .onChange(of: viewModel.selectedHeight) { _, _ in
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }

                Text("m")
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
    Step3HeightInputView(viewModel: OnboardingViewModel())
}
