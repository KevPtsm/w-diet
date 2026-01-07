//
//  WeightLoggingSheet.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 06.01.26.
//

import SwiftUI
import GRDB

/// Sheet for logging daily weight with same picker as onboarding
struct WeightLoggingSheet: View {
    // MARK: - Properties

    @Binding var isPresented: Bool
    let onWeightSaved: () -> Void

    @State private var selectedWeightWhole: Int = 70 // Whole kg
    @State private var selectedWeightDecimal: Int = 0 // Decimal (0-9)
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let dbManager: GRDBManager

    // MARK: - Initialization

    init(
        isPresented: Binding<Bool>,
        onWeightSaved: @escaping () -> Void,
        dbManager: GRDBManager = .shared
    ) {
        self._isPresented = isPresented
        self.onWeightSaved = onWeightSaved
        self.dbManager = dbManager
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Wie viel wiegst du heute?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)

                    Text("Tägliches Wiegen hilft dir, deinen Fortschritt zu tracken")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer()

                // Picker in center
                VStack(spacing: 24) {
                    // Weight Pickers (kg + decimal)
                    HStack(spacing: 0) {
                        // Whole kg picker
                        Picker("Weight", selection: $selectedWeightWhole) {
                            ForEach(40...200, id: \.self) { weight in
                                Text("\(weight)")
                                    .font(.system(size: 26, weight: .semibold))
                                    .tag(weight)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 150)
                        .clipped()
                        .onChange(of: selectedWeightWhole) { _, _ in
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }

                        Text(".")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)

                        // Decimal picker
                        Picker("Decimal", selection: $selectedWeightDecimal) {
                            ForEach(0...9, id: \.self) { decimal in
                                Text("\(decimal)")
                                    .font(.system(size: 26, weight: .semibold))
                                    .tag(decimal)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60, height: 150)
                        .clipped()
                        .onChange(of: selectedWeightDecimal) { _, _ in
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }

                        Text("kg")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                            .padding(.leading, 8)
                    }
                }

                Spacer()

                // Save Button
                Button {
                    Task {
                        await saveWeight()
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    } else {
                        Text("Gewicht speichern")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
                .background(Theme.fireGold)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 40)
                .disabled(isLoading)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        isPresented = false
                    }
                }
            }
            .alert("Fehler", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
            .task {
                // Load current weight from database
                await loadCurrentWeight()
            }
        }
    }

    // MARK: - Actions

    /// Load current weight to pre-fill pickers
    private func loadCurrentWeight() async {
        do {
            // TEMPORARY: Use mock user ID until auth is set up
            let userId = "mock-user-id"

            // Load latest weight
            let latestWeight = try await dbManager.read { db in
                try WeightLog.fetchLatest(db, userId: userId)
            }

            if let weight = latestWeight?.weightKg {
                selectedWeightWhole = Int(weight)
                selectedWeightDecimal = Int((weight - Double(Int(weight))) * 10)
            }
        } catch {
            // Ignore error, use default values
            #if DEBUG
            print("⚠️ Could not load current weight: \(error)")
            #endif
        }
    }

    /// Save weight to database
    private func saveWeight() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // TEMPORARY: Use mock user ID until auth is set up
            let userId = "mock-user-id"

            // Calculate weight value
            let weightKg = Double(selectedWeightWhole) + Double(selectedWeightDecimal) / 10.0

            // Create new weight log entry
            let newWeightLog = WeightLog(
                userId: userId,
                weightKg: weightKg,
                loggedAt: Date()
            )

            try await dbManager.write { db in
                try newWeightLog.insert(db)
            }

            // Update user profile with new weight
            try await dbManager.write { db in
                if let profile = try UserProfile.fetchByUserId(db, userId: userId) {
                    let updatedProfile = UserProfile(
                        id: profile.id,
                        userId: profile.userId,
                        email: profile.email,
                        goal: profile.goal,
                        calorieTarget: profile.calorieTarget,
                        eatingWindowStart: profile.eatingWindowStart,
                        eatingWindowEnd: profile.eatingWindowEnd,
                        onboardingCompleted: profile.onboardingCompleted,
                        gender: profile.gender,
                        heightCm: profile.heightCm,
                        weightKg: weightKg, // Update weight
                        activityLevel: profile.activityLevel,
                        calculatedCalories: profile.calculatedCalories,
                        cycleStartDate: profile.cycleStartDate,
                        createdAt: profile.createdAt,
                        updatedAt: Date(),
                        syncedAt: nil // Mark as needing sync
                    )

                    try updatedProfile.update(db)
                }
            }

            #if DEBUG
            print("✅ Weight saved: \(weightKg) kg")
            #endif

            // Dismiss sheet
            isPresented = false

            // Notify parent to reload data
            onWeightSaved()

        } catch let error as AppError {
            error.report()
            errorMessage = error.userMessage
        } catch {
            let appError = AppError.unknown(error)
            appError.report()
            errorMessage = appError.userMessage
        }
    }
}

// MARK: - Preview

#Preview {
    WeightLoggingSheet(
        isPresented: .constant(true),
        onWeightSaved: {}
    )
}
