//
//  NutritionLabelResultView.swift
//  w-diet
//
//  Shows extracted nutrition values and lets user input portion size
//

import SwiftUI

/// View for displaying nutrition label scan results
struct NutritionLabelResultView: View {
    @Environment(\.dismiss) private var dismiss

    let image: UIImage?
    let result: NutritionLabelResult?
    let isAnalyzing: Bool
    let targetDate: Date?
    var onSave: (MealLog) -> Void

    private let authManager: AuthManager

    @MainActor init(
        image: UIImage?,
        result: NutritionLabelResult?,
        isAnalyzing: Bool,
        targetDate: Date? = nil,
        onSave: @escaping (MealLog) -> Void,
        authManager: AuthManager = .shared
    ) {
        self.image = image
        self.result = result
        self.isAnalyzing = isAnalyzing
        self.targetDate = targetDate
        self.onSave = onSave
        self.authManager = authManager
    }

    // MARK: - State

    @State private var portionGrams: String = "100"
    @State private var productName: String = ""

    // MARK: - Computed

    private var portionMultiplier: Double {
        (Double(portionGrams) ?? 100) / 100.0
    }

    private var calculatedCalories: Int {
        guard let result = result else { return 0 }
        return Int(Double(result.calories) * portionMultiplier)
    }

    private var calculatedProtein: Double {
        guard let result = result else { return 0 }
        return result.protein * portionMultiplier
    }

    private var calculatedCarbs: Double {
        guard let result = result else { return 0 }
        return result.carbs * portionMultiplier
    }

    private var calculatedFat: Double {
        guard let result = result else { return 0 }
        return result.fat * portionMultiplier
    }

    private var canSave: Bool {
        !productName.isEmpty && (Double(portionGrams) ?? 0) > 0
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if isAnalyzing {
                    loadingView
                } else if let result = result, result.isValid {
                    resultsForm(result)
                } else {
                    errorView
                }
            }
            .navigationTitle("Nährwerte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.title2)
                            .foregroundColor(Theme.fireGold)
                    }
                }

                if result?.isValid == true {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Speichern") {
                            saveEntry()
                        }
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                    }
                }
            }
        }
    }

    // MARK: - Views

    private var loadingView: some View {
        VStack(spacing: 24) {
            Spacer()

            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
            }

            ProgressView()
                .scaleEffect(1.5)

            Text("Erkenne Nährwerte...")
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
    }

    private func resultsForm(_ result: NutritionLabelResult) -> some View {
        Form {
            // Image preview
            if let img = image {
                Section {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 150)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(8)
                }
            }

            // Product name
            Section {
                TextField("z.B. Joghurt, Müsli...", text: $productName)
            } header: {
                Text("Produktname")
            }

            // Portion input
            Section {
                HStack {
                    Text("Portion")
                    Spacer()
                    TextField("100", text: $portionGrams)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .onChange(of: portionGrams) { _, newValue in
                            portionGrams = newValue.filter { $0.isNumber }
                        }
                    Text("g")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Menge")
            } footer: {
                Text("Nährwerte werden pro 100g erkannt und auf deine Portion umgerechnet")
            }

            // Extracted values (per 100g)
            Section {
                nutritionRow(label: "Kalorien", valuePer100: result.calories, calculated: calculatedCalories, unit: "kcal", color: Theme.fireGold)
                nutritionRow(label: "Eiweiß", valuePer100: result.protein, calculated: calculatedProtein, unit: "g", color: Theme.macroProtein)
                nutritionRow(label: "Kohlenhydrate", valuePer100: result.carbs, calculated: calculatedCarbs, unit: "g", color: Theme.warning)
                nutritionRow(label: "Fett", valuePer100: result.fat, calculated: calculatedFat, unit: "g", color: Theme.macroFat)
            } header: {
                Text("Nährwerte")
            }
        }
    }

    private func nutritionRow(label: String, valuePer100: some Numeric, calculated: some Numeric, unit: String, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
            Spacer()

            // Per 100g (faded)
            Text("\(formatNumber(valuePer100))")
                .foregroundStyle(.secondary)
                .font(.caption)

            Image(systemName: "arrow.right")
                .font(.caption2)
                .foregroundStyle(.tertiary)

            // Calculated for portion (bold)
            Text("\(formatNumber(calculated)) \(unit)")
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }

    private var errorView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(Theme.disabled)

            Text("Keine Nährwerte erkannt")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Bitte fotografiere die Nährwerttabelle auf der Verpackung")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
    }

    // MARK: - Helpers

    private func formatNumber(_ value: some Numeric) -> String {
        if let intVal = value as? Int {
            return "\(intVal)"
        } else if let doubleVal = value as? Double {
            return String(format: "%.1f", doubleVal)
        }
        return "\(value)"
    }

    private func saveEntry() {
        let userId = authManager.currentUserId ?? "unknown"

        let meal = MealLog(
            userId: userId,
            mealName: productName,
            caloriesKcal: calculatedCalories,
            proteinG: calculatedProtein,
            carbsG: calculatedCarbs,
            fatG: calculatedFat,
            loggedAt: targetDate ?? Date()
        )

        onSave(meal)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    NutritionLabelResultView(
        image: nil,
        result: NutritionLabelResult(calories: 245, protein: 12, carbs: 30, fat: 8),
        isAnalyzing: false
    ) { _ in }
}
