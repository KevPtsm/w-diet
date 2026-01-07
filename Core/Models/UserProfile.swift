//
//  UserProfile.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 06.01.26.
//

import Foundation
import GRDB

/// User profile model for authentication and user data
///
/// **CRITICAL RULES:**
/// - Uses FetchableRecord + PersistableRecord (NOT Codable alone)
/// - CodingKeys maps camelCase ↔ snake_case for database
/// - All dates use GRDB's `.datetime` column type
/// - synced_at = NULL means not yet synced to Supabase
///
/// **Usage:**
/// ```swift
/// // Fetch user profile
/// let profile = try await dbManager.read { db in
///     try UserProfile.fetchOne(db, key: userId)
/// }
///
/// // Save user profile
/// try await dbManager.write { db in
///     try profile.insert(db)
/// }
/// ```
struct UserProfile: Codable, FetchableRecord, PersistableRecord {
    // MARK: - Properties

    /// Local SQLite primary key (auto-increment)
    let id: Int?

    /// Supabase auth user ID (from JWT token)
    let userId: String

    /// User email address
    let email: String

    // MARK: - Onboarding Fields (v2)

    /// User's fitness goal ("lose_weight", "maintain_weight", "gain_muscle")
    let goal: String?

    /// Daily calorie target in kcal
    let calorieTarget: Int?

    /// Eating window start time (HH:mm format, e.g., "12:00")
    let eatingWindowStart: String?

    /// Eating window end time (HH:mm format, e.g., "20:00")
    let eatingWindowEnd: String?

    /// Whether user has completed onboarding flow
    let onboardingCompleted: Bool

    // MARK: - Onboarding Fields (v3 - Story 1.3)

    /// User's gender ("male", "female", "other")
    let gender: String?

    /// User's height in centimeters
    let heightCm: Double?

    /// User's weight in kilograms
    let weightKg: Double?

    /// User's activity level ("sedentary", "lightly_active", "moderately_active", "very_active", "extremely_active")
    let activityLevel: String?

    /// Calculated calorie recommendation (using Mifflin-St Jeor equation)
    let calculatedCalories: Int?

    // MARK: - MATADOR Cycle

    /// MATADOR cycle start date (when user started their first or current cycle)
    let cycleStartDate: Date?

    // MARK: - Timestamps

    /// Timestamp when profile was created locally
    let createdAt: Date

    /// Timestamp when profile was last updated locally
    let updatedAt: Date

    /// Timestamp when profile was last synced to Supabase (NULL = not synced)
    let syncedAt: Date?

    // MARK: - GRDB Configuration

    /// Database table name
    static let databaseTableName = "user_profiles"

    // MARK: - CodingKeys (CRITICAL: snake_case ↔ camelCase mapping)

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"         // Database: user_id, Swift: userId
        case email
        case goal                       // Database: goal, Swift: goal
        case calorieTarget = "calorie_target"  // Database: calorie_target, Swift: calorieTarget
        case eatingWindowStart = "eating_window_start" // Database: eating_window_start, Swift: eatingWindowStart
        case eatingWindowEnd = "eating_window_end"     // Database: eating_window_end, Swift: eatingWindowEnd
        case onboardingCompleted = "onboarding_completed" // Database: onboarding_completed, Swift: onboardingCompleted
        case gender                     // Database: gender, Swift: gender
        case heightCm = "height_cm"     // Database: height_cm, Swift: heightCm
        case weightKg = "weight_kg"     // Database: weight_kg, Swift: weightKg
        case activityLevel = "activity_level" // Database: activity_level, Swift: activityLevel
        case calculatedCalories = "calculated_calories" // Database: calculated_calories, Swift: calculatedCalories
        case cycleStartDate = "cycle_start_date" // Database: cycle_start_date, Swift: cycleStartDate
        case createdAt = "created_at"   // Database: created_at, Swift: createdAt
        case updatedAt = "updated_at"   // Database: updated_at, Swift: updatedAt
        case syncedAt = "synced_at"     // Database: synced_at, Swift: syncedAt
    }

    // MARK: - Initialization

    init(
        id: Int? = nil,
        userId: String,
        email: String,
        goal: String? = nil,
        calorieTarget: Int? = nil,
        eatingWindowStart: String? = nil,
        eatingWindowEnd: String? = nil,
        onboardingCompleted: Bool = false,
        gender: String? = nil,
        heightCm: Double? = nil,
        weightKg: Double? = nil,
        activityLevel: String? = nil,
        calculatedCalories: Int? = nil,
        cycleStartDate: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        syncedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.email = email
        self.goal = goal
        self.calorieTarget = calorieTarget
        self.eatingWindowStart = eatingWindowStart
        self.eatingWindowEnd = eatingWindowEnd
        self.onboardingCompleted = onboardingCompleted
        self.gender = gender
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.activityLevel = activityLevel
        self.calculatedCalories = calculatedCalories
        self.cycleStartDate = cycleStartDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncedAt = syncedAt
    }

    // MARK: - Helper Methods

    /// Mark profile as synced with current timestamp
    func markAsSynced() -> UserProfile {
        UserProfile(
            id: id,
            userId: userId,
            email: email,
            goal: goal,
            calorieTarget: calorieTarget,
            eatingWindowStart: eatingWindowStart,
            eatingWindowEnd: eatingWindowEnd,
            onboardingCompleted: onboardingCompleted,
            gender: gender,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activityLevel,
            calculatedCalories: calculatedCalories,
            cycleStartDate: cycleStartDate,
            createdAt: createdAt,
            updatedAt: Date(),
            syncedAt: Date()
        )
    }

    /// Check if profile needs syncing
    var needsSync: Bool {
        syncedAt == nil || syncedAt! < updatedAt
    }
}

// MARK: - Query Extensions

extension UserProfile {
    /// Fetch user profile by user_id
    static func fetchByUserId(_ db: Database, userId: String) throws -> UserProfile? {
        try UserProfile
            .filter(Column("user_id") == userId)
            .fetchOne(db)
    }

    /// Fetch user profile by email
    static func fetchByEmail(_ db: Database, email: String) throws -> UserProfile? {
        try UserProfile
            .filter(Column("email") == email)
            .fetchOne(db)
    }

    /// Fetch all profiles that need syncing
    static func fetchUnsynced(_ db: Database) throws -> [UserProfile] {
        try UserProfile
            .filter(Column("synced_at") == nil || Column("synced_at") < Column("updated_at"))
            .fetchAll(db)
    }
}
