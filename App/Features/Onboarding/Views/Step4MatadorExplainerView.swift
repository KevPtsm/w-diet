//
//  Step4MatadorExplainerView.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 06.01.26.
//

import SwiftUI

/// Step 4: MATADOR Cycle Explainer
struct Step4MatadorExplainerView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showTooltip = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Was ist MATADOR?")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Der MATADOR-Zyklus wechselt 2 Wochen Kaloriendefizit mit 2 Wochen Erhaltungskalorien. Dieser Rhythmus verhindert den Stoffwechsel-Crash und führt zu mehr Gewichtsverlust als kontinuierliches Diäten.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // Visual Diagram
                VStack(spacing: 16) {
                    Text("Der 4-Wochen-Zyklus")
                        .font(.headline)

                    VStack(spacing: 8) {
                        // Week 1: Deficit Phase
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                ForEach(1...7, id: \.self) { day in
                                    cycleDayBox(phase: .deficit, isLarge: false)
                                }
                            }
                            HStack {
                                Text("Woche 1")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("Kaloriendefizit")
                                    .font(.caption2)
                                    .foregroundColor(Theme.deficitPhase)
                            }
                        }

                        // Week 2: Deficit Phase
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                ForEach(1...7, id: \.self) { day in
                                    cycleDayBox(phase: .deficit, isLarge: false)
                                }
                            }
                            HStack {
                                Text("Woche 2")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("Kaloriendefizit")
                                    .font(.caption2)
                                    .foregroundColor(Theme.deficitPhase)
                            }
                        }

                        // Week 3: Maintenance Phase
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                ForEach(1...7, id: \.self) { day in
                                    cycleDayBox(phase: .maintenance, isLarge: false)
                                }
                            }
                            HStack {
                                Text("Woche 3")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("Erhalt")
                                    .font(.caption2)
                                    .foregroundColor(Theme.maintenancePhase)
                            }
                        }

                        // Week 4: Maintenance Phase
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                ForEach(1...7, id: \.self) { day in
                                    cycleDayBox(phase: .maintenance, isLarge: false)
                                }
                            }
                            HStack {
                                Text("Woche 4")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("Erhalt")
                                    .font(.caption2)
                                    .foregroundColor(Theme.maintenancePhase)
                            }
                        }
                    }
                }
                .padding()
                .background(Theme.gray100)
                .cornerRadius(12)
                .padding(.horizontal)

                // Benefits
                VStack(alignment: .leading, spacing: 16) {
                    Text("Hauptvorteile")
                        .font(.headline)

                    benefitRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Stoffwechsel",
                        description: "Kein Stoffwechsel-Crash durch regelmäßige Erholungsphasen"
                    )

                    benefitRow(
                        icon: "bolt.fill",
                        title: "Mehr Gewichtsverlust",
                        description: "Durch stabilen Stoffwechsel verlierst du mehr Gewicht"
                    )

                    benefitRow(
                        icon: "checkmark.shield.fill",
                        title: "Gewichtsverlust bewahren",
                        description: "Das verlorene Gewicht bleibt auch langfristig weg"
                    )

                    benefitRow(
                        icon: "figure.strengthtraining.traditional",
                        title: "Muskeln erhalten",
                        description: "Du verlierst Fett, nicht deine Muskelmasse"
                    )

                    benefitRow(
                        icon: "heart.fill",
                        title: "Lebensqualität",
                        description: "Höhere Lebensqualität durch den nachhaltigen Zyklus"
                    )
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(8)
                .padding(.horizontal)

                // MATADOR Study Link
                Link(destination: URL(string: "https://www.nature.com/articles/ijo2017206")!) {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.body)
                        Text("MATADOR Studie lesen")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color(.systemGray6).opacity(0.3))
                    .cornerRadius(8)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showTooltip) {
            tooltipView
        }
    }

    // MARK: - Components

    private enum CyclePhase {
        case deficit
        case maintenance
    }

    private func cycleDayBox(phase: CyclePhase, isLarge: Bool) -> some View {
        Rectangle()
            .fill(phase == .deficit ? Theme.deficitPhase : Theme.maintenancePhase)
            .frame(height: isLarge ? 60 : 30)
            .cornerRadius(3)
    }

    private func benefitRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Theme.fireGold)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Tooltip

    private var tooltipView: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Warum funktioniert das?")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Forschungen zeigen, dass der Wechsel zwischen Essens- und Fastenphasen hilft, die Stoffwechselrate besser aufrechtzuerhalten als kontinuierliches Diäten.")
                        .font(.body)

                    Text("Der MATADOR-Ansatz wurde wissenschaftlich untersucht und verbessert nachweislich die Diättreue und langfristiges Gewichtsmanagement.")
                        .font(.body)
                }
                .padding()
            }
            .navigationTitle("Die Wissenschaft")
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
    Step4MatadorExplainerView(viewModel: OnboardingViewModel())
}
