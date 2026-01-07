//
//  Step2CalorieTargetView.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 06.01.26.
//

import SwiftUI

/// Step 2: Calorie Target Input
struct Step2CalorieTargetView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showTooltip = false
    @FocusState private var isInputFocused: Bool
    @State private var debouncedCalorieValue: Int = 0
    @State private var debounceTask: Task<Void, Never>?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dein Kalorienziel")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Basierend auf deinem Profil haben wir ein personalisiertes Ziel berechnet. Du kannst es bei Bedarf anpassen.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // Calorie Input
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        TextField("2000", text: $viewModel.calorieTargetInput)
                            .keyboardType(.numberPad)
                            .font(.system(size: 48, weight: .bold))
                            .multilineTextAlignment(.center)
                            .focused($isInputFocused)
                            .onChange(of: viewModel.calorieTargetInput) { oldValue, newValue in
                                // Filter to only allow digits
                                let filtered = newValue.filter { $0.isNumber }

                                // Limit to 4 digits (max 9999)
                                if filtered.count > 4 {
                                    viewModel.calorieTargetInput = String(filtered.prefix(4))
                                } else if filtered != newValue {
                                    viewModel.calorieTargetInput = filtered
                                }
                            }

                        Text("kcal")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    if let error = viewModel.calorieInputError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                .onChange(of: viewModel.calorieTargetInput) { _, newValue in
                    // Cancel previous debounce task
                    debounceTask?.cancel()

                    // Create new debounce task
                    debounceTask = Task {
                        try? await Task.sleep(nanoseconds: 400_000_000) // 400ms
                        if !Task.isCancelled {
                            if let value = Int(newValue) {
                                debouncedCalorieValue = value
                            }
                        }
                    }

                    // Real-time validation to clear error when input becomes valid
                    let minThreshold = viewModel.calculatedCalorieTarget > 0 ? viewModel.calculatedCalorieTarget - 200 : 1400
                    if let calories = Int(newValue), calories >= minThreshold, calories <= 9999 {
                        viewModel.calorieInputError = nil
                    } else if newValue.count >= 4, let calories = Int(newValue) {
                        // Set error if 4 digits entered and invalid
                        if calories < minThreshold {
                            viewModel.calorieInputError = "Kalorienziel muss mindestens \(minThreshold) kcal betragen"
                        } else if calories > 9999 {
                            viewModel.calorieInputError = "Kalorienziel darf maximal 9999 kcal betragen"
                        }
                    }
                }

                // Low Calorie Warning (only show after 4 digits entered)
                if viewModel.calorieTargetInput.count >= 4,
                   let calories = Int(viewModel.calorieTargetInput),
                   calories > 0,
                   viewModel.calculatedCalorieTarget > 0,
                   calories < viewModel.calculatedCalorieTarget - 200 {
                    let minThreshold = viewModel.calculatedCalorieTarget - 200
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title3)
                            .foregroundColor(.orange)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Warnung")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text("Ein Kalorienziel unter \(String(format: "%d", minThreshold)) kcal ist sehr niedrig und nicht nachhaltig.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                // Tip Box 1 - Flexibility (moved to top)
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Das ist nur ein Richtwert")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text(flexibilityText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)

                // Tip Box 2 - Protein
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.title3)
                        .foregroundColor(.yellow)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tipp")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text("Der Fokus auf Protein ist wichtiger als die Kalorien selbst.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical)
        }
        .onAppear {
            isInputFocused = true
            // Initialize debounced value
            if let initialValue = Int(viewModel.calorieTargetInput) {
                debouncedCalorieValue = initialValue
            }
        }
        .sheet(isPresented: $showTooltip) {
            tooltipView
        }
    }

    // MARK: - Computed Properties

    private var flexibilityText: String {
        // Use debounced value to avoid flickering during typing
        guard debouncedCalorieValue > 0 else {
            return "Es ist völlig in Ordnung, wenn du dein Kalorienziel etwas überschreitest."
        }

        // Calculate 10% over
        let tenPercent = Double(debouncedCalorieValue) * 0.10
        // Round to nearest 100
        let roundedBuffer = Int((tenPercent / 100.0).rounded()) * 100

        return "Es ist völlig in Ordnung, bis zu \(roundedBuffer) kcal über dein Ziel zu gehen."
    }

    // MARK: - Tooltip

    private var tooltipView: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Warum Kalorien wichtig sind")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("An Feeding-Tagen im MATADOR-Zyklus hilft das Erreichen deines Kalorienziels, Muskelmasse zu erhalten und deinen Stoffwechsel aufrechtzuerhalten.")
                        .font(.body)

                    Text("Die App berechnet automatisch deine Protein-, Kohlenhydrat- und Fettziele basierend auf dieser Zahl.")
                        .font(.body)
                }
                .padding()
            }
            .navigationTitle("Kalorienziel")
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
    Step2CalorieTargetView(viewModel: OnboardingViewModel())
}
