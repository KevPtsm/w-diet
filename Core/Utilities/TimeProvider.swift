//
//  TimeProvider.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 04.01.26.
//

import Foundation

/// Protocol for providing current time - enables testable date-dependent logic
///
/// **CRITICAL:** All date/time logic MUST use TimeProvider instead of Date()
/// This is required for testing MATADOR cycle transitions (midnight switches, Day 14 → Day 15)
///
/// Example usage:
/// ```swift
/// class CycleEngine {
///     private let timeProvider: TimeProvider
///
///     init(timeProvider: TimeProvider = SystemTimeProvider()) {
///         self.timeProvider = timeProvider
///     }
///
///     func calculatePhase() -> CyclePhase {
///         let now = timeProvider.now  // Injectable for tests
///         // ... phase calculation logic
///     }
/// }
/// ```
protocol TimeProvider {
    /// Returns the current date and time
    var now: Date { get }

    /// Returns the current calendar (default: .current)
    var calendar: Calendar { get }
}

// MARK: - System Implementation (Production)

/// Production implementation using real system time
final class SystemTimeProvider: TimeProvider {
    var now: Date {
        Date()
    }

    var calendar: Calendar {
        .current
    }
}

// MARK: - Mock Implementation (Testing)

/// Mock implementation for testing - allows fixing time and advancing it
///
/// Example usage in tests:
/// ```swift
/// func testMidnightTransition() {
///     let timeProvider = MockTimeProvider(fixedDate: "2026-01-01T23:59:59Z")
///     let engine = CycleEngine(timeProvider: timeProvider)
///
///     // Before midnight
///     XCTAssertEqual(engine.currentDay, 14)
///
///     // Advance 1 second to midnight
///     timeProvider.advance(seconds: 1)
///     XCTAssertEqual(engine.currentDay, 15)
/// }
/// ```
final class MockTimeProvider: TimeProvider {
    private var currentDate: Date
    var calendar: Calendar

    var now: Date {
        currentDate
    }

    /// Initialize with a fixed date
    /// - Parameters:
    ///   - fixedDate: ISO8601 string (e.g., "2026-01-01T12:00:00Z") or Date
    ///   - calendar: Calendar to use (default: gregorian with UTC timezone)
    init(fixedDate: Date, calendar: Calendar? = nil) {
        self.currentDate = fixedDate

        if let calendar = calendar {
            self.calendar = calendar
        } else {
            var cal = Calendar(identifier: .gregorian)
            cal.timeZone = TimeZone(identifier: "UTC")!
            self.calendar = cal
        }
    }

    /// Convenience initializer with ISO8601 string
    convenience init(fixedDate iso8601String: String) {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: iso8601String) ?? Date()
        self.init(fixedDate: date)
    }

    // MARK: - Test Helpers

    /// Advance time by a number of seconds
    func advance(seconds: TimeInterval) {
        currentDate = currentDate.addingTimeInterval(seconds)
    }

    /// Advance time by a number of days
    func advance(days: Int) {
        currentDate = calendar.date(byAdding: .day, value: days, to: currentDate)!
    }

    /// Advance time by a number of hours
    func advance(hours: Int) {
        currentDate = calendar.date(byAdding: .hour, value: hours, to: currentDate)!
    }

    /// Set time to a specific hour/minute/second on the current day
    func setTime(hour: Int, minute: Int, second: Int) {
        var components = calendar.dateComponents([.year, .month, .day], from: currentDate)
        components.hour = hour
        components.minute = minute
        components.second = second
        currentDate = calendar.date(from: components)!
    }

    /// Reset to a new fixed date
    func reset(to date: Date) {
        currentDate = date
    }
}
