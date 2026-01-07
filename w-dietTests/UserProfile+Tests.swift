//
//  UserProfile+Tests.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 06.01.26.
//

import XCTest
import GRDB
@testable import w_diet

/// Unit tests for UserProfile model
///
/// **Test Coverage:**
/// - GRDB FetchableRecord/PersistableRecord conformance
/// - CodingKeys mapping (camelCase ↔ snake_case)
/// - Database CRUD operations
/// - Query extensions
/// - Sync status tracking
final class UserProfileTests: XCTestCase {
    var dbManager: GRDBManager!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory test database
        dbManager = try GRDBManager.makeTestDatabase()
    }

    override func tearDown() async throws {
        try dbManager.eraseAll()
        dbManager = nil
        try await super.tearDown()
    }

    // MARK: - Model Creation Tests

    func testUserProfileInitialization() {
        // Given user profile data
        let userId = "test-user-123"
        let email = "test@example.com"

        // When creating profile
        let profile = UserProfile(
            userId: userId,
            email: email
        )

        // Then properties should be set correctly
        XCTAssertNil(profile.id) // Not yet saved to DB
        XCTAssertEqual(profile.userId, userId)
        XCTAssertEqual(profile.email, email)
        XCTAssertNil(profile.goal) // Not set yet
        XCTAssertNil(profile.calorieTarget) // Not set yet
        XCTAssertNil(profile.eatingWindowStart) // Not set yet
        XCTAssertNil(profile.eatingWindowEnd) // Not set yet
        XCTAssertFalse(profile.onboardingCompleted) // Default is false
        XCTAssertNotNil(profile.createdAt)
        XCTAssertNotNil(profile.updatedAt)
        XCTAssertNil(profile.syncedAt) // Not yet synced
    }

    // MARK: - Database CRUD Tests

    func testInsertUserProfile() async throws {
        // Given a user profile
        let profile = UserProfile(
            userId: "user-123",
            email: "user@example.com"
        )

        // When inserting into database
        try await dbManager.write { db in
            try profile.insert(db)
        }

        // Then profile should be retrievable
        let fetched = try await dbManager.read { db in
            try UserProfile.fetchByUserId(db, userId: "user-123")
        }

        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.userId, "user-123")
        XCTAssertEqual(fetched?.email, "user@example.com")
        XCTAssertNotNil(fetched?.id) // Auto-incremented by DB
    }

    func testFetchUserProfileByUserId() async throws {
        // Given profiles in database
        let profile1 = UserProfile(userId: "user-1", email: "user1@example.com")
        let profile2 = UserProfile(userId: "user-2", email: "user2@example.com")

        try await dbManager.write { db in
            try profile1.insert(db)
            try profile2.insert(db)
        }

        // When fetching by user_id
        let fetched = try await dbManager.read { db in
            try UserProfile.fetchByUserId(db, userId: "user-1")
        }

        // Then correct profile should be returned
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.userId, "user-1")
        XCTAssertEqual(fetched?.email, "user1@example.com")
    }

    func testFetchUserProfileByEmail() async throws {
        // Given a profile in database
        let profile = UserProfile(userId: "user-123", email: "test@example.com")

        try await dbManager.write { db in
            try profile.insert(db)
        }

        // When fetching by email
        let fetched = try await dbManager.read { db in
            try UserProfile.fetchByEmail(db, email: "test@example.com")
        }

        // Then profile should be found
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.email, "test@example.com")
    }

    func testUpdateUserProfile() async throws {
        // Given an existing profile
        var profile = UserProfile(userId: "user-123", email: "old@example.com")

        try await dbManager.write { db in
            try profile.insert(db)
        }

        // When updating email
        let fetchedProfile = try await dbManager.read { db in
            try UserProfile.fetchByUserId(db, userId: "user-123")!
        }

        let updatedProfile = UserProfile(
            id: fetchedProfile.id,
            userId: fetchedProfile.userId,
            email: "new@example.com",
            createdAt: fetchedProfile.createdAt,
            updatedAt: Date()
        )

        try await dbManager.write { db in
            try updatedProfile.update(db)
        }

        // Then email should be updated
        let final = try await dbManager.read { db in
            try UserProfile.fetchByUserId(db, userId: "user-123")
        }

        XCTAssertEqual(final?.email, "new@example.com")
    }

    // MARK: - CodingKeys Tests

    func testCodingKeysMappingSnakeCase() async throws {
        // Given a profile with snake_case DB columns
        let profile = UserProfile(userId: "user-123", email: "test@example.com")

        try await dbManager.write { db in
            try profile.insert(db)
        }

        // When fetching raw SQL
        let row = try await dbManager.read { db in
            try Row.fetchOne(db, sql: "SELECT * FROM user_profiles WHERE user_id = ?", arguments: ["user-123"])
        }

        // Then database should use snake_case
        XCTAssertNotNil(row)
        XCTAssertEqual(row?["user_id"] as! String, "user-123") // snake_case in DB
        XCTAssertNotNil(row?["created_at"]) // snake_case
        XCTAssertNotNil(row?["updated_at"]) // snake_case
    }

    func testCodingKeysMappingCamelCase() async throws {
        // Given a profile inserted via GRDB
        let profile = UserProfile(userId: "user-123", email: "test@example.com")

        try await dbManager.write { db in
            try profile.insert(db)
        }

        // When fetching via model
        let fetched = try await dbManager.read { db in
            try UserProfile.fetchByUserId(db, userId: "user-123")
        }

        // Then Swift model should use camelCase
        XCTAssertEqual(fetched?.userId, "user-123") // camelCase in Swift
        XCTAssertNotNil(fetched?.createdAt) // camelCase
        XCTAssertNotNil(fetched?.updatedAt) // camelCase
    }

    // MARK: - Sync Status Tests

    func testNeedsSyncWhenNotYetSynced() {
        // Given unsynced profile
        let profile = UserProfile(userId: "user-123", email: "test@example.com")

        // Then should need sync
        XCTAssertTrue(profile.needsSync)
    }

    func testNeedsSyncWhenModifiedAfterSync() {
        // Given a synced profile
        let syncedAt = Date()
        let profile = UserProfile(
            userId: "user-123",
            email: "test@example.com",
            createdAt: Date(),
            updatedAt: Date().addingTimeInterval(10), // Updated after sync
            syncedAt: syncedAt
        )

        // Then should need sync
        XCTAssertTrue(profile.needsSync)
    }

    func testDoesNotNeedSyncWhenUpToDate() {
        // Given a fully synced profile
        let now = Date()
        let profile = UserProfile(
            userId: "user-123",
            email: "test@example.com",
            createdAt: now,
            updatedAt: now,
            syncedAt: now.addingTimeInterval(1) // Synced after update
        )

        // Then should not need sync
        XCTAssertFalse(profile.needsSync)
    }

    func testMarkAsSynced() {
        // Given unsynced profile
        let profile = UserProfile(userId: "user-123", email: "test@example.com")

        // When marking as synced
        let synced = profile.markAsSynced()

        // Then syncedAt should be set
        XCTAssertNotNil(synced.syncedAt)
        XCTAssertFalse(synced.needsSync)
    }

    func testFetchUnsyncedProfiles() async throws {
        // Given mixed synced/unsynced profiles
        let synced = UserProfile(
            userId: "user-1",
            email: "synced@example.com",
            createdAt: Date(),
            updatedAt: Date(),
            syncedAt: Date()
        )

        let unsynced = UserProfile(
            userId: "user-2",
            email: "unsynced@example.com"
        )

        try await dbManager.write { db in
            try synced.insert(db)
            try unsynced.insert(db)
        }

        // When fetching unsynced
        let unsyncedProfiles = try await dbManager.read { db in
            try UserProfile.fetchUnsynced(db)
        }

        // Then only unsynced should be returned
        XCTAssertEqual(unsyncedProfiles.count, 1)
        XCTAssertEqual(unsyncedProfiles.first?.userId, "user-2")
    }

    // MARK: - Constraint Tests

    func testUserIdMustBeUnique() async throws {
        // Given a profile
        let profile1 = UserProfile(userId: "user-123", email: "user1@example.com")

        try await dbManager.write { db in
            try profile1.insert(db)
        }

        // When inserting duplicate user_id
        let profile2 = UserProfile(userId: "user-123", email: "user2@example.com")

        do {
            try await dbManager.write { db in
                try profile2.insert(db)
            }
            XCTFail("Should throw constraint violation")

        } catch {
            // Then should fail with UNIQUE constraint error
            XCTAssertTrue(error is DatabaseError)
        }
    }

    func testEmailMustBeUnique() async throws {
        // Given a profile
        let profile1 = UserProfile(userId: "user-1", email: "test@example.com")

        try await dbManager.write { db in
            try profile1.insert(db)
        }

        // When inserting duplicate email
        let profile2 = UserProfile(userId: "user-2", email: "test@example.com")

        do {
            try await dbManager.write { db in
                try profile2.insert(db)
            }
            XCTFail("Should throw constraint violation")

        } catch {
            // Then should fail with UNIQUE constraint error
            XCTAssertTrue(error is DatabaseError)
        }
    }

    // MARK: - Onboarding Fields Tests (v2)

    func testUserProfileWithOnboardingData() {
        // Given onboarding data
        let userId = "user-123"
        let email = "user@example.com"
        let goal = "lose_weight"
        let calorieTarget = 1800
        let windowStart = "12:00"
        let windowEnd = "20:00"

        // When creating profile with onboarding data
        let profile = UserProfile(
            userId: userId,
            email: email,
            goal: goal,
            calorieTarget: calorieTarget,
            eatingWindowStart: windowStart,
            eatingWindowEnd: windowEnd,
            onboardingCompleted: true
        )

        // Then all onboarding fields should be set
        XCTAssertEqual(profile.goal, goal)
        XCTAssertEqual(profile.calorieTarget, calorieTarget)
        XCTAssertEqual(profile.eatingWindowStart, windowStart)
        XCTAssertEqual(profile.eatingWindowEnd, windowEnd)
        XCTAssertTrue(profile.onboardingCompleted)
    }

    func testInsertUserProfileWithOnboardingData() async throws {
        // Given a profile with onboarding data
        let profile = UserProfile(
            userId: "user-123",
            email: "user@example.com",
            goal: "maintain_weight",
            calorieTarget: 2000,
            eatingWindowStart: "10:00",
            eatingWindowEnd: "18:00",
            onboardingCompleted: true
        )

        // When inserting into database
        try await dbManager.write { db in
            try profile.insert(db)
        }

        // Then profile should be retrievable with onboarding data
        let fetched = try await dbManager.read { db in
            try UserProfile.fetchByUserId(db, userId: "user-123")
        }

        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.goal, "maintain_weight")
        XCTAssertEqual(fetched?.calorieTarget, 2000)
        XCTAssertEqual(fetched?.eatingWindowStart, "10:00")
        XCTAssertEqual(fetched?.eatingWindowEnd, "18:00")
        XCTAssertTrue(fetched?.onboardingCompleted ?? false)
    }

    func testUpdateOnboardingFields() async throws {
        // Given an existing profile without onboarding data
        let profile = UserProfile(userId: "user-123", email: "user@example.com")

        try await dbManager.write { db in
            try profile.insert(db)
        }

        // When updating with onboarding data
        let fetchedProfile = try await dbManager.read { db in
            try UserProfile.fetchByUserId(db, userId: "user-123")!
        }

        let updatedProfile = UserProfile(
            id: fetchedProfile.id,
            userId: fetchedProfile.userId,
            email: fetchedProfile.email,
            goal: "gain_muscle",
            calorieTarget: 2500,
            eatingWindowStart: "08:00",
            eatingWindowEnd: "20:00",
            onboardingCompleted: true,
            createdAt: fetchedProfile.createdAt,
            updatedAt: Date()
        )

        try await dbManager.write { db in
            try updatedProfile.update(db)
        }

        // Then onboarding fields should be persisted
        let final = try await dbManager.read { db in
            try UserProfile.fetchByUserId(db, userId: "user-123")
        }

        XCTAssertEqual(final?.goal, "gain_muscle")
        XCTAssertEqual(final?.calorieTarget, 2500)
        XCTAssertEqual(final?.eatingWindowStart, "08:00")
        XCTAssertEqual(final?.eatingWindowEnd, "20:00")
        XCTAssertTrue(final?.onboardingCompleted ?? false)
    }

    func testCodingKeysMappingForOnboardingFields() async throws {
        // Given a profile with onboarding data
        let profile = UserProfile(
            userId: "user-123",
            email: "test@example.com",
            goal: "lose_weight",
            calorieTarget: 1800,
            eatingWindowStart: "12:00",
            eatingWindowEnd: "20:00",
            onboardingCompleted: true
        )

        try await dbManager.write { db in
            try profile.insert(db)
        }

        // When fetching raw SQL
        let row = try await dbManager.read { db in
            try Row.fetchOne(db, sql: "SELECT * FROM user_profiles WHERE user_id = ?", arguments: ["user-123"])
        }

        // Then database should use snake_case for onboarding fields
        XCTAssertNotNil(row)
        XCTAssertEqual(row?["goal"] as! String, "lose_weight")
        XCTAssertEqual(row?["calorie_target"] as! Int, 1800)
        XCTAssertEqual(row?["eating_window_start"] as! String, "12:00")
        XCTAssertEqual(row?["eating_window_end"] as! String, "20:00")
        XCTAssertEqual(row?["onboarding_completed"] as! Bool, true)
    }

    func testOnboardingCompletedDefaultsToFalse() async throws {
        // Given a profile created without explicit onboarding_completed value
        let profile = UserProfile(userId: "user-123", email: "test@example.com")

        // When inserting into database
        try await dbManager.write { db in
            try profile.insert(db)
        }

        // Then onboarding_completed should default to false
        let fetched = try await dbManager.read { db in
            try UserProfile.fetchByUserId(db, userId: "user-123")
        }

        XCTAssertFalse(fetched?.onboardingCompleted ?? true)
    }
}
