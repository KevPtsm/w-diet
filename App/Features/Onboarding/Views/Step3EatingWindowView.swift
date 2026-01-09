//
//  Step3EatingWindowView.swift
//  w-diet
//
//  Step 9: Intermittent Fasting - Eating Window Selection
//

import SwiftUI

/// Step 9: Intermittent Fasting - Eating Window Selection
struct Step3EatingWindowView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedStartHour: Int = 12 // Default 12:00

    private var selectedEndHour: Int {
        (selectedStartHour + 6) % 24
    }

    private var isRecommendedTime: Bool {
        selectedStartHour >= 11 && selectedStartHour <= 13
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 20)

                // Mascot with speech bubble (consistent with MATADOR)
                VStack(spacing: 12) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Theme.fireGold)

                    Text("Das ist Intervallfasten")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Theme.gray100)
                        .cornerRadius(16)
                }
                .padding(.bottom, 20)

                // Time Window Card
                VStack(spacing: 16) {
                    Text("Wähle dein 6 Stunden Essensfenster")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(formattedTimeRange)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(isRecommendedTime ? Theme.fireGold : .primary)

                    // Always reserve space for badge to prevent layout shifts
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Empfohlene Zeit")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.fireGold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Theme.fireGold.opacity(0.15))
                    .cornerRadius(16)
                    .opacity(isRecommendedTime ? 1 : 0)

                    Slider(
                        value: Binding(
                            get: { Double(selectedStartHour) },
                            set: { newValue in
                                selectedStartHour = Int(newValue)
                                updateViewModel()
                            }
                        ),
                        in: 6...18,
                        step: 1
                    )
                    .tint(isRecommendedTime ? Theme.fireGold : Color.gray)
                }
                .padding()
                .background(Theme.backgroundSecondary)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Theme.gray300, lineWidth: 1)
                )
                .padding(.horizontal, 32)

                // Benefits Card
                VStack(alignment: .leading, spacing: 10) {
                    benefitRow(icon: "flame.fill", text: "Maximiert Fettverbrennung")
                    benefitRow(icon: "heart.fill", text: "Verbessert Stoffwechsel")
                }
                .padding(14)
                .background(Theme.backgroundSecondary)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Theme.gray300, lineWidth: 1)
                )
                .padding(.top, 12)
                .padding(.horizontal, 32)

                // Tip card
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.title3)
                        .foregroundColor(.yellow)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tipp")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text("Kalorienfreie Getränke sind außerhalb des Essfensters erlaubt.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(12)
                .padding(.top, 12)
                .padding(.horizontal, 32)

                // Study Link
                Link(destination: URL(string: "https://pubmed.ncbi.nlm.nih.gov/29754952/")!) {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.body)
                        Text("Intervallfasten-Studie lesen")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .padding(14)
                    .background(Theme.backgroundSecondary)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Theme.gray300, lineWidth: 1)
                    )
                }
                .padding(.top, 12)
                .padding(.horizontal, 32)

                Spacer()
                    .frame(height: 100)
            }
        }
        .onAppear {
            let calendar = Calendar.current
            selectedStartHour = calendar.component(.hour, from: viewModel.eatingWindowStart)
        }
    }

    // MARK: - Components

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(Theme.fireGold)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()
        }
    }

    // MARK: - Helper Methods

    private var formattedTimeRange: String {
        "\(formatHour(selectedStartHour)) - \(formatHour(selectedEndHour))"
    }

    private func formatHour(_ hour: Int) -> String {
        String(format: "%02d:00", hour)
    }

    private func updateViewModel() {
        var startComponents = DateComponents()
        startComponents.hour = selectedStartHour
        startComponents.minute = 0

        var endComponents = DateComponents()
        endComponents.hour = selectedEndHour
        endComponents.minute = 0

        if let startDate = Calendar.current.date(from: startComponents),
           let endDate = Calendar.current.date(from: endComponents) {
            viewModel.eatingWindowStart = startDate
            viewModel.eatingWindowEnd = endDate
        }
    }
}

// MARK: - Preview

#Preview {
    Step3EatingWindowView(viewModel: OnboardingViewModel())
}
