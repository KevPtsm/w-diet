//
//  Step5CompletionView.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 06.01.26.
//

import SwiftUI

/// Step 5: Completion and Dashboard Reveal
struct Step5CompletionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onComplete: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer()

                // Fire Character
                Image(systemName: "flame.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(Theme.fireGold)
                    .symbolEffect(.bounce, options: .repeating)

                // Success Message
                VStack(spacing: 16) {
                    Text("Alles klar!")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Lass uns mit deiner Reise starten")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Summary
                VStack(alignment: .leading, spacing: 16) {
                    summaryRow(label: "Ziel", value: viewModel.goalDisplayName)
                    Divider()
                    summaryRow(label: "Tagesziel", value: "\(viewModel.calorieTargetInput) kcal")
                    Divider()
                    summaryRow(label: "Essfenster", value: viewModel.formattedEatingWindow)
                }
                .padding()
                .background(Theme.gray100)
                .cornerRadius(12)
                .padding(.horizontal)

                // Start Button
                Button(action: {
                    onComplete()
                }) {
                    Text("Los geht's")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.fireGold)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical)
        }
    }

    // MARK: - Components

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Preview

#Preview {
    Step5CompletionView(viewModel: OnboardingViewModel(), onComplete: {})
}
