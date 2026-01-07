//
//  Step3EatingWindowView.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 06.01.26.
//

import SwiftUI

/// Step 3: Intermittent Fasting - Eating Window Selection
struct Step3EatingWindowView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showTooltip = false
    @State private var selectedStartHour: Int = 12 // Default 12:00
    @State private var selectedEndHour: Int = 18   // Default 18:00 (6 hour window)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Intervallfasten")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Iss innerhalb deines 6-Stunden-Fensters. Außerhalb solltest du Kalorien vermeiden, um die Fettverbrennung zu maximieren.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // Eating Window Picker (MOVED TO TOP)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Wähle dein Essfenster")
                        .font(.headline)
                        .padding(.horizontal)

                    // Time Window Display
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Text(formattedTimeRange)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(selectedStartHour >= 11 && selectedStartHour <= 13 ? Theme.fireGold : .primary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Theme.gray100)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedStartHour >= 11 && selectedStartHour <= 13 ? Theme.fireGold : Color.clear, lineWidth: 2)
                    )
                    .padding(.horizontal)

                    // Start Time Slider with Enhanced Markers
                    VStack(alignment: .leading, spacing: 8) {
                        // Enhanced slider with visible hour markers
                        VStack(spacing: 0) {
                            // Hour marker dots (positioned above slider)
                            GeometryReader { geometry in
                                let sliderWidth = geometry.size.width

                                // Background recommended range
                                let startPosition = (11.0 / 23.0) * sliderWidth
                                let endPosition = (13.0 / 23.0) * sliderWidth
                                let width = endPosition - startPosition

                                Rectangle()
                                    .fill(Theme.fireGold.opacity(0.15))
                                    .frame(width: width, height: 12)
                                    .offset(x: startPosition, y: 0)
                                    .cornerRadius(6)

                                // Hour marker dots
                                ForEach(0..<24, id: \.self) { hour in
                                    let position = (Double(hour) / 23.0) * sliderWidth
                                    let isRecommended = hour >= 11 && hour <= 13

                                    Circle()
                                        .fill(isRecommended ? Theme.fireGold : Color.gray.opacity(0.4))
                                        .frame(width: isRecommended ? 10 : 6, height: isRecommended ? 10 : 6)
                                        .offset(x: position - (isRecommended ? 5 : 3), y: isRecommended ? 1 : 3)
                                }
                            }
                            .frame(height: 12)
                            .padding(.bottom, 8)

                            // Slider
                            Slider(
                                value: Binding(
                                    get: { Double(selectedStartHour) },
                                    set: { newValue in
                                        selectedStartHour = Int(newValue)
                                        // Automatically set end to 6 hours later
                                        selectedEndHour = (selectedStartHour + 6) % 24
                                        updateViewModel()
                                    }
                                ),
                                in: 0...23,
                                step: 1
                            )
                            .tint(selectedStartHour >= 11 && selectedStartHour <= 13 ? Theme.fireGold : Color.gray)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)

                // Tip Box
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.title3)
                        .foregroundColor(.yellow)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tipp")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text("Kalorienfreie Getränke sind außerhalb des Essfensters erlaubt. Das Essfenster morgens einzuhalten ist wichtiger als abends.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)

                // Benefits
                VStack(alignment: .leading, spacing: 16) {
                    Text("Hauptvorteile")
                        .font(.headline)

                    benefitRow(
                        icon: "flame.fill",
                        title: "Fettverbrennung",
                        description: "Längere Fastenphasen erhöhen die Fettverbrennung"
                    )

                    benefitRow(
                        icon: "heart.text.square.fill",
                        title: "Stoffwechselgesundheit",
                        description: "Senkt Blutdruck und Stress, verbessert Insulinempfindlichkeit"
                    )

                    benefitRow(
                        icon: "brain.head.profile",
                        title: "Mentale Klarheit",
                        description: "Fördert Konzentration und kognitive Leistung"
                    )
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(8)
                .padding(.horizontal)

                // IF Study Link
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
                    .padding()
                    .background(Color(.systemGray6).opacity(0.3))
                    .cornerRadius(8)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical)
        }
        .onAppear {
            // Initialize sliders with existing values if available
            let calendar = Calendar.current
            selectedStartHour = calendar.component(.hour, from: viewModel.eatingWindowStart)
            selectedEndHour = calendar.component(.hour, from: viewModel.eatingWindowEnd)
        }
        .sheet(isPresented: $showTooltip) {
            tooltipView
        }
    }

    // MARK: - Components

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

    // MARK: - Helper Methods

    private var formattedTimeRange: String {
        "\(formatHour(selectedStartHour)) - \(formatHour(selectedEndHour))"
    }

    private func formatHour(_ hour: Int) -> String {
        String(format: "%02d:00", hour)
    }

    private func updateViewModel() {
        // Update ViewModel with selected times
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

    // MARK: - Tooltip

    private var tooltipView: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Warum funktioniert das?")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Forschungen zeigen, dass Intervallfasten mit einem begrenzten Essfenster die Fettverbrennung fördert und den Stoffwechsel verbessert.")
                        .font(.body)

                    Text("Ein 6-Stunden-Fenster bietet eine gute Balance zwischen Effektivität und Alltagstauglichkeit.")
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
    Step3EatingWindowView(viewModel: OnboardingViewModel())
}
