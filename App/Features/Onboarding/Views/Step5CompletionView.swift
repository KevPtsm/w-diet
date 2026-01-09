//
//  Step5CompletionView.swift
//  w-diet
//
//  Step 10: Completion - celebration and start button
//

import SwiftUI

/// Step 10: Completion - celebratory screen with start button
struct Step5CompletionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onComplete: () -> Void
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Celebratory mascot
            VStack(spacing: 16) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.fireGold)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                Text("Bereit!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Theme.gray100)
                    .cornerRadius(20)
            }

            Spacer()

            // Calorie summary (minimal)
            VStack(spacing: 8) {
                Text("\(viewModel.calculatedCalorieTarget)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Theme.fireGold)

                Text("kcal pro Tag")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
            }
            .frame(height: 100)

            Spacer()

            // Start Button
            Button(action: {
                onComplete()
            }) {
                Text("Los geht's")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Theme.fireGold)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 16)

            Spacer()
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Preview

#Preview {
    Step5CompletionView(viewModel: OnboardingViewModel(), onComplete: {})
}
