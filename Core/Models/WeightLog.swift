//
//  WeightLog.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 06.01.26.
//

import Foundation
import GRDB

/// Weight log model for tracking daily weight measurements
///
/// **CRITICAL RULES:**
/// - Uses FetchableRecord + PersistableRecord (NOT Codable alone)
/// - CodingKeys maps camelCase ↔ snake_case for database
/// - All dates use GRDB's `.datetime` column type
/// - synced_at = NULL means not yet synced to Supabase
struct WeightLog: Codable, FetchableRecord, PersistableRecord {
    // MARK: - Properties

    /// Local SQLite primary key (auto-increment)
    let id: Int?

    /// Supabase auth user ID
    let userId: String

    /// Weight in kilograms
    let weightKg: Double

    /// When the weight was logged
    let loggedAt: Date

    /// Timestamp when log was created locally
    let createdAt: Date

    /// Timestamp when log was last updated locally
    let updatedAt: Date

    /// Timestamp when log was last synced to Supabase (NULL = not synced)
    let syncedAt: Date?

    // MARK: - GRDB Configuration

    /// Database table name
    static let databaseTableName = "weight_logs"

    // MARK: - CodingKeys (CRITICAL: snake_case ↔ camelCase mapping)

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case weightKg = "weight_kg"
        case loggedAt = "logged_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case syncedAt = "synced_at"
    }

    // MARK: - Initialization

    init(
        id: Int? = nil,
        userId: String,
        weightKg: Double,
        loggedAt: Date = Date(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        syncedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.weightKg = weightKg
        self.loggedAt = loggedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncedAt = syncedAt
    }
}

// MARK: - Query Extensions

extension WeightLog {
    /// Fetch weight logs for a specific user
    static func fetchForUser(_ db: Database, userId: String) throws -> [WeightLog] {
        try WeightLog
            .filter(Column("user_id") == userId)
            .order(Column("logged_at").desc)
            .fetchAll(db)
    }

    /// Check if weight was logged today for a user
    static func hasLoggedToday(_ db: Database, userId: String, today: Date) throws -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let count = try WeightLog
            .filter(Column("user_id") == userId)
            .filter(Column("logged_at") >= startOfDay)
            .filter(Column("logged_at") < endOfDay)
            .fetchCount(db)

        return count > 0
    }

    /// Fetch all logs that need syncing
    static func fetchUnsynced(_ db: Database) throws -> [WeightLog] {
        try WeightLog
            .filter(Column("synced_at") == nil || Column("synced_at") < Column("updated_at"))
            .fetchAll(db)
    }

    /// Fetch latest weight for a user
    static func fetchLatest(_ db: Database, userId: String) throws -> WeightLog? {
        try WeightLog
            .filter(Column("user_id") == userId)
            .order(Column("logged_at").desc)
            .fetchOne(db)
    }

    /// Fetch weight logs for the last N days
    static func fetchLastNDays(_ db: Database, userId: String, days: Int, referenceDate: Date = Date()) throws -> [WeightLog] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: referenceDate)!

        return try WeightLog
            .filter(Column("user_id") == userId)
            .filter(Column("logged_at") >= startDate)
            .order(Column("logged_at").desc)
            .fetchAll(db)
    }

    /// Calculate average weight for the last N days
    static func calculateAverage(_ db: Database, userId: String, days: Int, referenceDate: Date = Date()) throws -> Double? {
        let logs = try fetchLastNDays(db, userId: userId, days: days, referenceDate: referenceDate)
        guard !logs.isEmpty else { return nil }

        let sum = logs.reduce(0.0) { $0 + $1.weightKg }
        return sum / Double(logs.count)
    }

    /// Count how many weight logs exist in the last N days
    static func countLastNDays(_ db: Database, userId: String, days: Int, referenceDate: Date = Date()) throws -> Int {
        let logs = try fetchLastNDays(db, userId: userId, days: days, referenceDate: referenceDate)
        return logs.count
    }
}
