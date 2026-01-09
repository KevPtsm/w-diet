//
//  ManualEntryView.swift
//  w-diet
//
//  Manual entry form for food logging
//

import SwiftUI

/// Manual entry form for logging meals without database search
struct ManualEntryView: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    var onSave: (MealLog) -> Void
    private let authManager: AuthManager

    init(onSave: @escaping (MealLog) -> Void, authManager: AuthManager = .shared) {
        self.onSave = onSave
        self.authManager = authManager
    }

    // MARK: - State

    @State private var mealName = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""

    @State private var showValidationError = false
    @State private var validationMessage = ""

    // MARK: - Computed

    private var hasMacros: Bool {
        !protein.isEmpty || !carbs.isEmpty || !fat.isEmpty
    }

    private var calculatedCaloriesFromMacros: Int {
        let p = Double(protein) ?? 0
        let c = Double(carbs) ?? 0
        let f = Double(fat) ?? 0
        return Int(p * 4 + c * 4 + f * 9)
    }

    private var displayCalories: String {
        if !calories.isEmpty {
            return calories
        } else if hasMacros {
            return "\(calculatedCaloriesFromMacros)"
        }
        return ""
    }

    private var canSave: Bool {
        !mealName.isEmpty && (!calories.isEmpty || hasMacros)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // Meal Name Section
                Section {
                    TextField("Schnelleintrag", text: $mealName)
                } header: {
                    Text("Mahlzeit")
                }

                // Macros Section (moved up)
                Section {
                    macroRow(label: "Eiweiß", value: $protein, unit: "g", color: Theme.macroProtein)
                    macroRow(label: "Kohlenhydrate", value: $carbs, unit: "g", color: Theme.warning)
                    macroRow(label: "Fett", value: $fat, unit: "g", color: Theme.macroFat)
                } header: {
                    Text("Makronährstoffe")
                }

                // Calories Section (shows calculated value from macros)
                Section {
                    HStack {
                        if hasMacros && calories.isEmpty {
                            // Show calculated calories (read-only display)
                            Text("\(calculatedCaloriesFromMacros)")
                                .foregroundColor(Theme.fireGold)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        } else {
                            TextField("0", text: $calories)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: calories) { _, newValue in
                                    calories = newValue.filter { $0.isNumber }
                                }
                        }
                        Text("kcal")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Kalorien")
                } footer: {
                    if hasMacros && calories.isEmpty {
                        Text("Automatisch berechnet aus Makros")
                    }
                }

            }
            .navigationTitle("Manuell eingeben")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        saveEntry()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
            .alert("Fehler", isPresented: $showValidationError) {
                Button("OK") {}
            } message: {
                Text(validationMessage)
            }
        }
    }

    // MARK: - Components

    private func macroRow(label: String, value: Binding<String>, unit: String, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
            Spacer()
            TextField("0", text: value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 60)
                .onChange(of: value.wrappedValue) { _, newValue in
                    // Allow only digits and one decimal point
                    let filtered = newValue.filter { $0.isNumber || $0 == "." || $0 == "," }
                    // Replace comma with period for consistency
                    let normalized = filtered.replacingOccurrences(of: ",", with: ".")
                    // Ensure only one decimal point
                    let parts = normalized.split(separator: ".", omittingEmptySubsequences: false)
                    if parts.count > 2 {
                        value.wrappedValue = String(parts[0]) + "." + String(parts[1])
                    } else if normalized != newValue {
                        value.wrappedValue = normalized
                    }
                }
            Text(unit)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Actions

    private func saveEntry() {
        // Parse values (default to 0)
        let caloriesInt = Int(calories) ?? 0
        let proteinValue = Double(protein) ?? 0
        let carbsValue = Double(carbs) ?? 0
        let fatValue = Double(fat) ?? 0

        // Calculate calories from macros if not provided
        let finalCalories: Int
        if caloriesInt > 0 {
            finalCalories = caloriesInt
        } else {
            // Calculate from macros: protein 4kcal/g, carbs 4kcal/g, fat 9kcal/g
            finalCalories = Int(proteinValue * 4 + carbsValue * 4 + fatValue * 9)
        }

        let userId = authManager.currentUserId ?? "unknown"
        let meal = MealLog(
            userId: userId,
            mealName: mealName,
            caloriesKcal: finalCalories,
            proteinG: proteinValue,
            carbsG: carbsValue,
            fatG: fatValue
        )

        onSave(meal)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    ManualEntryView(onSave: { _ in })
}
