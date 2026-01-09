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

/// Notification posted when profile is reset, triggering navigation to onboarding
extension Notification.Name {
    static let profileDidReset = Notification.Name("profileDidReset")
}

@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Editable fields
    @Published var editGoal: String = "lose_weight"
    @Published var editGender: String = "male"
    @Published var editHeight: Double = 170
    @Published var editWeight: Double = 70
    @Published var editActivityLevel: String = "moderately_active"
    @Published var editEatingWindowStart: String = "12:00"
    @Published var editEatingWindowEnd: String = "18:00"

    // MARK: - Dependencies

    private let dbManager: GRDBManager
    private let authManager: AuthManager

    // MARK: - Initialization

    init(dbManager: GRDBManager = .shared, authManager: AuthManager = .shared) {
        self.dbManager = dbManager
        self.authManager = authManager
    }

    // MARK: - Computed Properties

    var activityLevelDisplayName: String {
        guard let level = profile?.activityLevel else { return "--" }
        return Self.activityLevelName(level)
    }

    static func activityLevelName(_ level: String) -> String {
        switch level {
        case "sedentary": return "Wenig aktiv"
        case "lightly_active": return "Leicht aktiv"
        case "moderately_active": return "Mäßig aktiv"
        case "very_active": return "Sehr aktiv"
        case "extra_active": return "Extrem aktiv"
        default: return level
        }
    }

    static let activityLevels: [(key: String, title: String, description: String)] = [
        ("sedentary", "Wenig aktiv", "Bürojob, wenig Bewegung"),
        ("lightly_active", "Leicht aktiv", "Bürojob + leichter Sport"),
        ("moderately_active", "Mäßig aktiv", "Aktiver Alltag + Sport"),
        ("very_active", "Sehr aktiv", "Sehr aktiver Alltag + Sport"),
        ("extra_active", "Extrem aktiv", "Körperliche Arbeit + Sport")
    ]

    // MARK: - Actions

    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }

        do {
            guard let userId = authManager.currentUserId else {
                errorMessage = "Nicht angemeldet"
                return
            }

            profile = try await dbManager.read { db in
                try UserProfile.fetchByUserId(db, userId: userId)
            }

            // Populate edit fields with current values
            if let p = profile {
                editGoal = p.goal ?? "lose_weight"
                editGender = p.gender ?? "male"
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
            // Recalculate TDEE using CalorieCalculator
            guard let tdee = CalorieCalculator.calculateTDEE(
                gender: editGender,
                heightCm: editHeight,
                weightKg: editWeight,
                age: 30,
                activityLevel: editActivityLevel
            ) else {
                errorMessage = "Fehler bei der Kalorienberechnung"
                return
            }

            // Store TDEE as reference; actual target is calculated dynamically by phase
            let dietCalories = CalorieCalculator.calculateMatadorCalories(tdee: tdee, isDietPhase: true)

            let updatedProfile = UserProfile(
                id: currentProfile.id,
                userId: currentProfile.userId,
                email: currentProfile.email,
                goal: editGoal,
                calorieTarget: dietCalories,
                eatingWindowStart: editEatingWindowStart,
                eatingWindowEnd: editEatingWindowEnd,
                onboardingCompleted: currentProfile.onboardingCompleted,
                gender: editGender,
                heightCm: editHeight,
                weightKg: editWeight,
                activityLevel: editActivityLevel,
                calculatedCalories: tdee,  // Store TDEE for reference
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

    /// Reset MATADOR cycle to Day 1 (today)
    func resetCycle() async {
        guard let currentProfile = profile else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let updatedProfile = UserProfile(
                id: currentProfile.id,
                userId: currentProfile.userId,
                email: currentProfile.email,
                goal: currentProfile.goal,
                calorieTarget: currentProfile.calorieTarget,
                eatingWindowStart: currentProfile.eatingWindowStart,
                eatingWindowEnd: currentProfile.eatingWindowEnd,
                onboardingCompleted: currentProfile.onboardingCompleted,
                gender: currentProfile.gender,
                heightCm: currentProfile.heightCm,
                weightKg: currentProfile.weightKg,
                activityLevel: currentProfile.activityLevel,
                calculatedCalories: currentProfile.calculatedCalories,
                cycleStartDate: Date(),  // Reset to today = Day 1
                createdAt: currentProfile.createdAt,
                updatedAt: Date(),
                syncedAt: nil
            )

            try await dbManager.write { db in
                try updatedProfile.update(db)
            }

            profile = updatedProfile
        } catch {
            errorMessage = "Fehler beim Zurücksetzen des Zyklus"
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

            // Notify RootView to navigate to onboarding
            NotificationCenter.default.post(name: .profileDidReset, object: nil)
        } catch {
            errorMessage = "Fehler beim Zurücksetzen des Profils"
        }
    }

    // MARK: - GDPR Features

    /// Delete all user data (DSGVO Art. 17 - Recht auf Löschung)
    func deleteAccount() async -> Bool {
        guard let userId = authManager.currentUserId else {
            errorMessage = "Nicht angemeldet"
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            // Delete all user data from local database
            try await dbManager.write { db in
                // Delete meal logs
                try db.execute(sql: "DELETE FROM meal_logs WHERE user_id = ?", arguments: [userId])
                // Delete weight logs
                try db.execute(sql: "DELETE FROM weight_logs WHERE user_id = ?", arguments: [userId])
                // Delete cycle state
                try db.execute(sql: "DELETE FROM cycle_state WHERE user_id = ?", arguments: [userId])
                // Delete user profile
                try db.execute(sql: "DELETE FROM user_profiles WHERE user_id = ?", arguments: [userId])
                // Clear sync queue for this user
                try db.execute(sql: "DELETE FROM sync_queue")
            }

            // Sign out from auth
            try await authManager.signOut()

            return true
        } catch {
            errorMessage = "Fehler beim Löschen des Kontos"
            return false
        }
    }

    /// Export all user data as JSON (DSGVO Art. 20 - Recht auf Datenübertragbarkeit)
    func exportUserData() async -> URL? {
        guard let userId = authManager.currentUserId else {
            errorMessage = "Nicht angemeldet"
            return nil
        }

        isLoading = true
        defer { isLoading = false }

        do {
            // Fetch all user data
            let profile = try await dbManager.read { db in
                try UserProfile.fetchByUserId(db, userId: userId)
            }

            let mealLogs = try await dbManager.read { db -> [MealLogExport] in
                let rows = try Row.fetchAll(db, sql: """
                    SELECT meal_name, calories_kcal, protein_g, carbs_g, fat_g, logged_at
                    FROM meal_logs WHERE user_id = ? ORDER BY logged_at DESC
                """, arguments: [userId])
                return rows.map { row in
                    MealLogExport(
                        mealName: row["meal_name"],
                        caloriesKcal: row["calories_kcal"],
                        proteinG: row["protein_g"],
                        carbsG: row["carbs_g"],
                        fatG: row["fat_g"],
                        loggedAt: row["logged_at"]
                    )
                }
            }

            let weightLogs = try await dbManager.read { db -> [WeightLogExport] in
                let rows = try Row.fetchAll(db, sql: """
                    SELECT weight_kg, logged_at FROM weight_logs
                    WHERE user_id = ? ORDER BY logged_at DESC
                """, arguments: [userId])
                return rows.map { row in
                    WeightLogExport(
                        weightKg: row["weight_kg"],
                        loggedAt: row["logged_at"]
                    )
                }
            }

            // Create export structure
            let exportData = UserDataExport(
                exportDate: ISO8601DateFormatter().string(from: Date()),
                profile: profile.map { ProfileExport(from: $0) },
                mealLogs: mealLogs,
                weightLogs: weightLogs
            )

            // Encode to JSON
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(exportData)

            // Write to temporary file
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "w-diet-export-\(Date().timeIntervalSince1970).json"
            let fileURL = tempDir.appendingPathComponent(fileName)
            try jsonData.write(to: fileURL)

            return fileURL
        } catch {
            errorMessage = "Fehler beim Exportieren der Daten"
            return nil
        }
    }
}

// MARK: - Export Data Structures

struct UserDataExport: Codable {
    let exportDate: String
    let profile: ProfileExport?
    let mealLogs: [MealLogExport]
    let weightLogs: [WeightLogExport]
}

struct ProfileExport: Codable {
    let email: String
    let goal: String?
    let calorieTarget: Int?
    let eatingWindowStart: String?
    let eatingWindowEnd: String?
    let gender: String?
    let age: Int?
    let heightCm: Double?
    let weightKg: Double?
    let activityLevel: String?
    let createdAt: String

    init(from profile: UserProfile) {
        self.email = profile.email
        self.goal = profile.goal
        self.calorieTarget = profile.calorieTarget
        self.eatingWindowStart = profile.eatingWindowStart
        self.eatingWindowEnd = profile.eatingWindowEnd
        self.gender = profile.gender
        self.age = profile.age
        self.heightCm = profile.heightCm
        self.weightKg = profile.weightKg
        self.activityLevel = profile.activityLevel
        self.createdAt = ISO8601DateFormatter().string(from: profile.createdAt)
    }
}

struct MealLogExport: Codable {
    let mealName: String
    let caloriesKcal: Int
    let proteinG: Double
    let carbsG: Double
    let fatG: Double
    let loggedAt: Date
}

struct WeightLogExport: Codable {
    let weightKg: Double
    let loggedAt: Date
}
