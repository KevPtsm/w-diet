//
//  Step1GoalSelectionView.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 06.01.26.
//

import SwiftUI

/// Step 1: Goal Selection - allows user to choose fitness goal
struct Step1GoalSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showTooltip = false

    var body: some View {
        VStack(spacing: 0) {
            // Header at top
            VStack(alignment: .leading, spacing: 8) {
                Text("Was ist dein Ziel?")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Wähle das Ziel, das am besten zu dir passt")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 20)

            Spacer()

            // Goal Cards centered
            VStack(spacing: 16) {
                goalCard(
                    goal: "lose_weight",
                    title: "Gewicht verlieren",
                    icon: "arrow.down.circle.fill",
                    description: "Körpergewicht reduzieren und Muskeln erhalten",
                    isEnabled: true
                )

                goalCard(
                    goal: "maintain_weight",
                    title: "Gewicht halten",
                    icon: "equal.circle.fill",
                    description: "Aktuelles Gewicht halten und Körperkomposition verbessern",
                    isEnabled: false
                )

                goalCard(
                    goal: "gain_muscle",
                    title: "Muskeln aufbauen",
                    icon: "arrow.up.circle.fill",
                    description: "Muskelmasse und Kraft aufbauen",
                    isEnabled: false
                )
            }
            .padding(.horizontal)

            Spacer()
        }
        .sheet(isPresented: $showTooltip) {
            tooltipView
        }
    }

    // MARK: - Goal Card

    private func goalCard(goal: String, title: String, icon: String, description: String, isEnabled: Bool) -> some View {
        Button(action: {
            if isEnabled {
                viewModel.selectedGoal = goal
            }
        }) {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(isEnabled ? (viewModel.selectedGoal == goal ? .white : Theme.fireGold) : Theme.disabled)
                    .frame(width: 60, height: 60)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isEnabled ? (viewModel.selectedGoal == goal ? .white : Theme.textPrimary) : Theme.disabled)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(isEnabled ? (viewModel.selectedGoal == goal ? .white.opacity(0.9) : Theme.textSecondary) : Theme.disabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if !isEnabled {
                    Text("Bald verfügbar")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.energyOrange)
                        .cornerRadius(8)
                } else if viewModel.selectedGoal == goal {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            .padding()
            .background(viewModel.selectedGoal == goal && isEnabled ? Theme.fireGold : Theme.gray100)
            .cornerRadius(12)
        }
        .disabled(!isEnabled)
    }

    // MARK: - Tooltip

    private var tooltipView: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("MATADOR funktioniert für alle Ziele")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Der MATADOR-Zyklus ist darauf ausgelegt, deinen Stoffwechsel unabhängig von deinem Ziel zu erhalten.")
                        .font(.body)

                    VStack(alignment: .leading, spacing: 12) {
                        Label("Gewicht verlieren: Minimiert metabolische Anpassung im Kaloriendefizit", systemImage: "arrow.down.circle")
                        Label("Gewicht halten: Aktuelles Gewicht mit flexibler Ernährung halten", systemImage: "equal.circle")
                        Label("Muskeln aufbauen: Masse aufbauen bei optimaler Körperkomposition", systemImage: "arrow.up.circle")
                    }
                    .font(.subheadline)

                    Text("Dein Ziel hilft uns, passende Kalorienziele und Tracking-Metriken festzulegen.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Über Ziele")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        showTooltip = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Preview

#Preview {
    Step1GoalSelectionView(viewModel: OnboardingViewModel())
}
