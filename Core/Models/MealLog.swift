//
//  MealLog.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 04.01.26.
//

import Foundation
import GRDB

/// Represents a logged meal with macronutrient information
///
/// **CRITICAL:** CodingKeys are MANDATORY for all Codable models
/// Database uses `snake_case`, Swift uses `camelCase`
/// Without explicit CodingKeys, Supabase sync silently fails
struct MealLog: Codable, Identifiable {
    var id: Int64?
    let userId: String
    let mealName: String
    let caloriesKcal: Int
    let proteinG: Double
    let carbsG: Double
    let fatG: Double
    let loggedAt: Date
    let createdAt: Date
    let updatedAt: Date
    var syncedAt: Date?

    // MARK: - CodingKeys (MANDATORY for database sync)

    /// Maps Swift camelCase to database snake_case
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case mealName = "meal_name"
        case caloriesKcal = "calories_kcal"
        case proteinG = "protein_g"
        case carbsG = "carbs_g"
        case fatG = "fat_g"
        case loggedAt = "logged_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case syncedAt = "synced_at"
    }

    // MARK: - Computed Properties

    /// Total macros in grams
    var totalMacrosG: Double {
        proteinG + carbsG + fatG
    }

    /// Protein percentage of total calories (4 kcal per gram)
    var proteinPercentage: Double {
        guard caloriesKcal > 0 else { return 0 }
        return (proteinG * 4) / Double(caloriesKcal) * 100
    }

    /// Carbs percentage of total calories (4 kcal per gram)
    var carbsPercentage: Double {
        guard caloriesKcal > 0 else { return 0 }
        return (carbsG * 4) / Double(caloriesKcal) * 100
    }

    /// Fat percentage of total calories (9 kcal per gram)
    var fatPercentage: Double {
        guard caloriesKcal > 0 else { return 0 }
        return (fatG * 9) / Double(caloriesKcal) * 100
    }

    /// Whether this meal has been synced to Supabase
    var isSynced: Bool {
        syncedAt != nil
    }
}

// MARK: - GRDB FetchableRecord

extension MealLog: FetchableRecord {
    /// Initialize from database row
    init(row: Row) {
        id = row["id"]
        userId = row["user_id"]
        mealName = row["meal_name"]
        caloriesKcal = row["calories_kcal"]
        proteinG = row["protein_g"]
        carbsG = row["carbs_g"]
        fatG = row["fat_g"]
        loggedAt = row["logged_at"]
        createdAt = row["created_at"]
        updatedAt = row["updated_at"]
        syncedAt = row["synced_at"]
    }
}

// MARK: - GRDB PersistableRecord

extension MealLog: PersistableRecord {
    /// Database table name
    static let databaseTableName = "meal_logs"

    /// Encode to database row
    func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["user_id"] = userId
        container["meal_name"] = mealName
        container["calories_kcal"] = caloriesKcal
        container["protein_g"] = proteinG
        container["carbs_g"] = carbsG
        container["fat_g"] = fatG
        container["logged_at"] = loggedAt
        container["created_at"] = createdAt
        container["updated_at"] = updatedAt
        container["synced_at"] = syncedAt
    }

    /// Update auto-incrementing ID after insert
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

// MARK: - Convenience Initializers

extension MealLog {
    /// Create a new meal log with current timestamp
    init(
        userId: String,
        mealName: String,
        caloriesKcal: Int,
        proteinG: Double,
        carbsG: Double,
        fatG: Double,
        loggedAt: Date = Date()
    ) {
        let now = Date()
        self.init(
            id: nil,
            userId: userId,
            mealName: mealName,
            caloriesKcal: caloriesKcal,
            proteinG: proteinG,
            carbsG: carbsG,
            fatG: fatG,
            loggedAt: loggedAt,
            createdAt: now,
            updatedAt: now,
            syncedAt: nil
        )
    }
}

// MARK: - Validation

extension MealLog {
    /// Validate meal log data
    func validate() throws {
        guard !mealName.isEmpty else {
            throw AppError.missingRequiredField(field: "Mahlzeitname")
        }

        guard caloriesKcal > 0 else {
            throw AppError.invalidInput(field: "Kalorien", reason: "müssen größer als 0 sein")
        }

        guard proteinG >= 0 else {
            throw AppError.invalidInput(field: "Protein", reason: "muss 0 oder größer sein")
        }

        guard carbsG >= 0 else {
            throw AppError.invalidInput(field: "Kohlenhydrate", reason: "müssen 0 oder größer sein")
        }

        guard fatG >= 0 else {
            throw AppError.invalidInput(field: "Fett", reason: "muss 0 oder größer sein")
        }

        // Sanity check: macros should roughly match calories
        // Protein: 4 kcal/g, Carbs: 4 kcal/g, Fat: 9 kcal/g
        let calculatedCalories = (proteinG * 4) + (carbsG * 4) + (fatG * 9)
        let tolerance = 0.2 // 20% tolerance
        let diff = abs(calculatedCalories - Double(caloriesKcal)) / Double(caloriesKcal)

        if diff > tolerance {
            throw AppError.mealLogInvalid(
                reason: "Makronährstoffe stimmen nicht mit Kalorien überein (Berechnet: \(Int(calculatedCalories)) kcal, Angegeben: \(caloriesKcal) kcal)"
            )
        }
    }
}
