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
/// **CRITICAL RULES:**
/// - Uses Codable + FetchableRecord + PersistableRecord
/// - CodingKeys maps camelCase ↔ snake_case for database
/// - All dates use GRDB's `.datetime` column type
/// - synced_at = NULL means not yet synced to Supabase
struct MealLog: Codable, Identifiable, FetchableRecord, PersistableRecord {
    // MARK: - Properties

    /// Local SQLite primary key (auto-increment)
    var id: Int64?

    /// Supabase auth user ID
    let userId: String

    /// Meal name
    let mealName: String

    /// Calories in kcal
    let caloriesKcal: Int

    /// Protein in grams
    let proteinG: Double

    /// Carbohydrates in grams
    let carbsG: Double

    /// Fat in grams
    let fatG: Double

    /// When the meal was logged
    let loggedAt: Date

    /// Timestamp when log was created locally
    let createdAt: Date

    /// Timestamp when log was last updated locally
    let updatedAt: Date

    /// Timestamp when log was last synced to Supabase (NULL = not synced)
    var syncedAt: Date?

    // MARK: - GRDB Configuration

    /// Database table name
    static let databaseTableName = "meal_logs"

    // MARK: - CodingKeys (CRITICAL: snake_case ↔ camelCase mapping)

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

    /// Time of day emoji based on when the meal was logged
    var timeOfDayEmoji: String {
        let hour = Calendar.current.component(.hour, from: loggedAt)
        switch hour {
        case 5..<11: return "☀️"   // Morgens
        case 11..<16: return "🌤️"  // Mittags
        case 16..<19: return "🌅"  // Nachmittags
        default: return "🌙"       // Abends
        }
    }

    /// Time of day label in German
    var timeOfDayLabel: String {
        let hour = Calendar.current.component(.hour, from: loggedAt)
        switch hour {
        case 5..<11: return "Morgens"
        case 11..<16: return "Mittags"
        case 16..<19: return "Nachmittags"
        default: return "Abends"
        }
    }

    /// Formatted time string
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: loggedAt)
    }

    // MARK: - Initialization

    init(
        id: Int64? = nil,
        userId: String,
        mealName: String,
        caloriesKcal: Int,
        proteinG: Double,
        carbsG: Double,
        fatG: Double,
        loggedAt: Date = Date(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        syncedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.mealName = mealName
        self.caloriesKcal = caloriesKcal
        self.proteinG = proteinG
        self.carbsG = carbsG
        self.fatG = fatG
        self.loggedAt = loggedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncedAt = syncedAt
    }
}

// MARK: - Query Extensions

extension MealLog {
    /// Fetch meal logs for a specific user on a specific day
    static func fetchForUserToday(_ db: Database, userId: String, today: Date = Date()) throws -> [MealLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return try MealLog
            .filter(Column("user_id") == userId)
            .filter(Column("logged_at") >= startOfDay)
            .filter(Column("logged_at") < endOfDay)
            .order(Column("logged_at").desc)
            .fetchAll(db)
    }

    /// Fetch all logs that need syncing
    static func fetchUnsynced(_ db: Database) throws -> [MealLog] {
        try MealLog
            .filter(Column("synced_at") == nil || Column("synced_at") < Column("updated_at"))
            .fetchAll(db)
    }

    /// Check if any meal was logged on a specific date
    static func hasLoggedOnDate(_ db: Database, userId: String, date: Date) throws -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let count = try MealLog
            .filter(Column("user_id") == userId)
            .filter(Column("logged_at") >= startOfDay)
            .filter(Column("logged_at") < endOfDay)
            .fetchCount(db)

        return count > 0
    }

    /// Fetch meal logs for a specific user on a specific date
    static func fetchForDate(_ db: Database, userId: String, date: Date) throws -> [MealLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return try MealLog
            .filter(Column("user_id") == userId)
            .filter(Column("logged_at") >= startOfDay)
            .filter(Column("logged_at") < endOfDay)
            .order(Column("logged_at").asc)
            .fetchAll(db)
    }

    /// Fetch all meal logs for a specific month
    static func fetchForMonth(_ db: Database, userId: String, month: Date) throws -> [MealLog] {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return []
        }

        return try MealLog
            .filter(Column("user_id") == userId)
            .filter(Column("logged_at") >= startOfMonth)
            .filter(Column("logged_at") < endOfMonth)
            .order(Column("logged_at").desc)
            .fetchAll(db)
    }

    /// Calculate total calories for a specific date
    static func totalCaloriesForDate(_ db: Database, userId: String, date: Date) throws -> Int {
        let meals = try fetchForDate(db, userId: userId, date: date)
        return meals.reduce(0) { $0 + $1.caloriesKcal }
    }

    /// Calculate total calories for a month
    static func totalCaloriesForMonth(_ db: Database, userId: String, month: Date) throws -> Int {
        let meals = try fetchForMonth(db, userId: userId, month: month)
        return meals.reduce(0) { $0 + $1.caloriesKcal }
    }

    /// Get days with logged meals in a month
    static func daysWithMealsInMonth(_ db: Database, userId: String, month: Date) throws -> Set<Int> {
        let meals = try fetchForMonth(db, userId: userId, month: month)
        let calendar = Calendar.current
        var days: Set<Int> = []
        for meal in meals {
            days.insert(calendar.component(.day, from: meal.loggedAt))
        }
        return days
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
    }
}
