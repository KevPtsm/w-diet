//
//  SettingsViewModel.swift
//  w-diet
//
//  ViewModel for Settings screen
//

import Combine
import Foundation
import GRDB
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Editable fields
    @Published var editHeight: Double = 170
    @Published var editWeight: Double = 70
    @Published var editActivityLevel: String = "moderately_active"
    @Published var editEatingWindowStart: String = "12:00"
    @Published var editEatingWindowEnd: String = "18:00"

    // MARK: - Dependencies

    private let dbManager: GRDBManager

    // MARK: - Initialization

    init(dbManager: GRDBManager = .shared) {
        self.dbManager = dbManager
    }

    // MARK: - Computed Properties

    var activityLevelDisplayName: String {
        guard let level = profile?.activityLevel else { return "--" }
        return Self.activityLevelName(level)
    }

    static func activityLevelName(_ level: String) -> String {
        switch level {
        case "sedentary": return "Sitzend"
        case "lightly_active": return "Leicht aktiv"
        case "moderately_active": return "Moderat aktiv"
        case "very_active": return "Sehr aktiv"
        case "extremely_active": return "Extrem aktiv"
        default: return level
        }
    }

    static let activityLevels = [
        ("sedentary", "Sitzend"),
        ("lightly_active", "Leicht aktiv"),
        ("moderately_active", "Moderat aktiv"),
        ("very_active", "Sehr aktiv"),
        ("extremely_active", "Extrem aktiv")
    ]

    // MARK: - Actions

    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let userId = "mock-user-id"
            profile = try await dbManager.read { db in
                try UserProfile.fetchByUserId(db, userId: userId)
            }

            // Populate edit fields with current values
            if let p = profile {
                editHeight = p.heightCm ?? 170
                editWeight = p.weightKg ?? 70
                editActivityLevel = p.activityLevel ?? "moderately_active"
                editEatingWindowStart = p.eatingWindowStart ?? "12:00"
                editEatingWindowEnd = p.eatingWindowEnd ?? "18:00"
            }
        } catch {
            errorMessage = "Fehler beim Laden des Profils"
        }
    }

    func saveProfile() async {
        guard let currentProfile = profile else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            // Recalculate calories based on new values
            let newCalories = calculateCalories(
                weightKg: editWeight,
                heightCm: editHeight,
                activityLevel: editActivityLevel,
                gender: currentProfile.gender ?? "male"
            )

            let updatedProfile = UserProfile(
                id: currentProfile.id,
                userId: currentProfile.userId,
                email: currentProfile.email,
                goal: currentProfile.goal,
                calorieTarget: newCalories,
                eatingWindowStart: editEatingWindowStart,
                eatingWindowEnd: editEatingWindowEnd,
                onboardingCompleted: currentProfile.onboardingCompleted,
                gender: currentProfile.gender,
                heightCm: editHeight,
                weightKg: editWeight,
                activityLevel: editActivityLevel,
                calculatedCalories: newCalories,
                cycleStartDate: currentProfile.cycleStartDate,
                createdAt: currentProfile.createdAt,
                updatedAt: Date(),
                syncedAt: nil
            )

            try await dbManager.write { db in
                try updatedProfile.update(db)
            }

            profile = updatedProfile
        } catch {
            errorMessage = "Fehler beim Speichern des Profils"
        }
    }

    func resetProfile() async {
        guard let currentProfile = profile else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let resetProfile = UserProfile(
                id: currentProfile.id,
                userId: currentProfile.userId,
                email: currentProfile.email,
                goal: nil,
                calorieTarget: nil,
                eatingWindowStart: nil,
                eatingWindowEnd: nil,
                onboardingCompleted: false,
                gender: nil,
                heightCm: nil,
                weightKg: nil,
                activityLevel: nil,
                calculatedCalories: nil,
                cycleStartDate: nil,
                createdAt: currentProfile.createdAt,
                updatedAt: Date(),
                syncedAt: nil
            )

            try await dbManager.write { db in
                try resetProfile.update(db)
            }

            profile = resetProfile
        } catch {
            errorMessage = "Fehler beim Zurücksetzen des Profils"
        }
    }

    // MARK: - Calorie Calculation (Mifflin-St Jeor)

    private func calculateCalories(weightKg: Double, heightCm: Double, activityLevel: String, gender: String) -> Int {
        // Assuming age ~25 for simplicity (could be added to profile later)
        let age = 25.0

        // BMR using Mifflin-St Jeor
        let bmr: Double
        if gender == "male" {
            bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5
        } else {
            bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161
        }

        // Activity multiplier
        let multiplier: Double
        switch activityLevel {
        case "sedentary": multiplier = 1.2
        case "lightly_active": multiplier = 1.375
        case "moderately_active": multiplier = 1.55
        case "very_active": multiplier = 1.725
        case "extremely_active": multiplier = 1.9
        default: multiplier = 1.55
        }

        // TDEE with 20% deficit for weight loss
        let tdee = bmr * multiplier
        let deficit = tdee * 0.8

        return Int(deficit)
    }
}
