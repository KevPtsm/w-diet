//
//  GRDBManager.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 04.01.26.
//

import Foundation
import GRDB

/// GRDB database manager - primary source of truth for offline-first architecture
///
/// **CRITICAL RULES:**
/// - GRDB (SQLite) is ALWAYS the primary source of truth
/// - Supabase (PostgreSQL) is secondary sync, optional
/// - App MUST work 100% offline (no internet dependency)
/// - All migrations MUST be registered via `migrator.registerMigration()`
/// - NEVER create tables directly outside of migrations
///
/// Example usage:
/// ```swift
/// let dbManager = try GRDBManager.shared
/// let mealLogs = try await dbManager.read { db in
///     try MealLog.fetchAll(db)
/// }
/// ```
final class GRDBManager {
    // MARK: - Singleton

    static let shared: GRDBManager = {
        do {
            return try GRDBManager()
        } catch {
            fatalError("Failed to initialize GRDBManager: \(error)")
        }
    }()

    // MARK: - Properties

    private let dbQueue: DatabaseQueue
    private let migrator: DatabaseMigrator

    // MARK: - Initialization

    private init() throws {
        // 1. Set up database file path
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let dbURL = appSupportURL.appendingPathComponent("w-diet.sqlite")

        #if DEBUG
        print("📁 Database path: \(dbURL.path)")
        #endif

        // 2. Create database queue
        do {
            dbQueue = try DatabaseQueue(path: dbURL.path)
        } catch {
            throw AppError.databaseInitializationFailed(underlying: error)
        }

        // 3. Set up migrations
        migrator = Self.setupMigrations()

        // 4. Run migrations
        do {
            try migrator.migrate(dbQueue)
            #if DEBUG
            print("✅ Database migrations completed")
            #endif
        } catch {
            throw AppError.databaseMigrationFailed(version: "unknown", underlying: error)
        }
    }

    // MARK: - Test Initialization (for unit tests with in-memory database)

    static func makeTestDatabase() throws -> GRDBManager {
        let dbQueue = try DatabaseQueue()
        let migrator = setupMigrations()
        try migrator.migrate(dbQueue)

        return GRDBManager(dbQueue: dbQueue, migrator: migrator)
    }

    private init(dbQueue: DatabaseQueue, migrator: DatabaseMigrator) {
        self.dbQueue = dbQueue
        self.migrator = migrator
    }

    // MARK: - Migrations Setup

    private static func setupMigrations() -> DatabaseMigrator {
        var migrator = DatabaseMigrator()

        // MARK: - v1.0-POC Migrations

        // Migration 1: Create meal_logs table
        migrator.registerMigration("v1_create_meal_logs") { db in
            try db.create(table: "meal_logs") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("user_id", .text).notNull()
                t.column("meal_name", .text).notNull()
                t.column("calories_kcal", .integer).notNull()
                t.column("protein_g", .double).notNull()
                t.column("carbs_g", .double).notNull()
                t.column("fat_g", .double).notNull()
                t.column("logged_at", .datetime).notNull()
                t.column("created_at", .datetime).notNull()
                t.column("updated_at", .datetime).notNull()
                t.column("synced_at", .datetime) // NULL = not synced yet
            }

            // Indexes for performance
            try db.create(index: "idx_meal_logs_user_id", on: "meal_logs", columns: ["user_id"])
            try db.create(index: "idx_meal_logs_logged_at", on: "meal_logs", columns: ["logged_at"])
            try db.create(index: "idx_meal_logs_synced_at", on: "meal_logs", columns: ["synced_at"])
        }

        // Migration 2: Create weight_logs table
        migrator.registerMigration("v1_create_weight_logs") { db in
            try db.create(table: "weight_logs") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("user_id", .text).notNull()
                t.column("weight_kg", .double).notNull()
                t.column("logged_at", .datetime).notNull()
                t.column("created_at", .datetime).notNull()
                t.column("updated_at", .datetime).notNull()
                t.column("synced_at", .datetime) // NULL = not synced yet
            }

            try db.create(index: "idx_weight_logs_user_id", on: "weight_logs", columns: ["user_id"])
            try db.create(index: "idx_weight_logs_logged_at", on: "weight_logs", columns: ["logged_at"])
        }

        // Migration 3: Create cycle_state table (singleton - only 1 row)
        migrator.registerMigration("v1_create_cycle_state") { db in
            try db.create(table: "cycle_state") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("user_id", .text).notNull()
                t.column("is_active", .boolean).notNull()
                t.column("current_phase", .text).notNull() // "diet" or "maintenance"
                t.column("cycle_start_date", .datetime).notNull()
                t.column("diet_days", .integer).notNull()
                t.column("maintenance_days", .integer).notNull()
                t.column("current_day", .integer).notNull()
                t.column("target_weight_kg", .double)
                t.column("created_at", .datetime).notNull()
                t.column("updated_at", .datetime).notNull()
                t.column("synced_at", .datetime) // NULL = not synced yet
            }

            try db.create(index: "idx_cycle_state_user_id", on: "cycle_state", columns: ["user_id"])
        }

        // Migration 4: Create sync_queue table (for offline sync recovery)
        migrator.registerMigration("v1_create_sync_queue") { db in
            try db.create(table: "sync_queue") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("table_name", .text).notNull()
                t.column("record_id", .integer).notNull()
                t.column("operation", .text).notNull() // "insert", "update", "delete"
                t.column("created_at", .datetime).notNull()
                t.column("retry_count", .integer).notNull().defaults(to: 0)
                t.column("last_error", .text)
            }

            try db.create(index: "idx_sync_queue_created_at", on: "sync_queue", columns: ["created_at"])
        }

        return migrator
    }

    // MARK: - Database Access

    /// Read from the database (read-only transaction)
    func read<T>(_ operation: (Database) throws -> T) throws -> T {
        try dbQueue.read(operation)
    }

    /// Read from the database asynchronously
    func read<T>(_ operation: @escaping (Database) throws -> T) async throws -> T {
        try await dbQueue.read(operation)
    }

    /// Write to the database (read-write transaction)
    func write<T>(_ operation: (Database) throws -> T) throws -> T {
        try dbQueue.write(operation)
    }

    /// Write to the database asynchronously
    func write<T>(_ operation: @escaping (Database) throws -> T) async throws -> T {
        try await dbQueue.write(operation)
    }

    // MARK: - Helper Methods

    /// Check if a table exists
    func tableExists(_ tableName: String) throws -> Bool {
        try dbQueue.read { db in
            try db.tableExists(tableName)
        }
    }

    /// Get database statistics (for debugging)
    func getStatistics() throws -> DatabaseStatistics {
        try dbQueue.read { db in
            let pageCount = try Int.fetchOne(db, sql: "PRAGMA page_count") ?? 0
            let pageSize = try Int.fetchOne(db, sql: "PRAGMA page_size") ?? 0
            let sizeInBytes = pageCount * pageSize

            let tables = try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'
            """)

            return DatabaseStatistics(
                sizeInBytes: sizeInBytes,
                tables: tables
            )
        }
    }

    /// Erase all data (for testing or user data reset)
    func eraseAll() throws {
        try dbQueue.write { db in
            try db.execute(sql: "DELETE FROM meal_logs")
            try db.execute(sql: "DELETE FROM weight_logs")
            try db.execute(sql: "DELETE FROM cycle_state")
            try db.execute(sql: "DELETE FROM sync_queue")
        }
    }
}

// MARK: - Database Statistics

struct DatabaseStatistics {
    let sizeInBytes: Int
    let tables: [String]

    var sizeInMB: Double {
        Double(sizeInBytes) / 1_048_576.0
    }
}
