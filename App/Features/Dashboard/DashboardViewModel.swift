//
//  DashboardViewModel.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 04.01.26.
//

import Foundation
import SwiftUI
import Combine

/// Weight trend indicator
enum WeightTrend {
    case up      // Weight increasing (bad)
    case down    // Weight decreasing or stable (good)

    var icon: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        }
    }

    var color: Color {
        switch self {
        case .up: return Theme.warning
        case .down: return Theme.success
        }
    }
}

/// ViewModel for the Dashboard screen
///
/// Shows overview of:
/// - Current MATADOR cycle status
/// - Today's macro progress
/// - Quick actions
@MainActor
final class DashboardViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isLoading = false
    @Published var errorMessage: String?

    // Cycle status
    @Published var cyclePhase: String = "Kein aktiver Zyklus"
    @Published var currentDay: Int = 0
    @Published var daysRemaining: Int = 0

    // Weight reminder
    @Published var showWeightReminder: Bool = false

    // Weight tracking
    @Published var currentWeight: Double?
    @Published var averageWeight7Days: Double?
    @Published var weightTrend: WeightTrend = .down

    // Today's macros (will be calculated from user profile + meal logs)
    @Published var caloriesConsumed: Int = 0
    @Published var caloriesTarget: Int = 2000
    @Published var proteinConsumed: Double = 0
    @Published var proteinTarget: Double = 0  // Calculated from weight
    @Published var carbsConsumed: Double = 0
    @Published var carbsTarget: Double = 0   // Calculated from remaining calories
    @Published var fatConsumed: Double = 0
    @Published var fatTarget: Double = 0     // Calculated from weight

    // MARK: - Dependencies

    private nonisolated(unsafe) let timeProvider: TimeProvider
    private let dbManager: GRDBManager

    // MARK: - Initialization

    nonisolated init(
        timeProvider: TimeProvider = SystemTimeProvider(),
        dbManager: GRDBManager = .shared
    ) {
        self.timeProvider = timeProvider
        self.dbManager = dbManager
    }

    // MARK: - Actions

    /// Load dashboard data
    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // TEMPORARY: Use mock user ID until auth is set up
            let userId = "mock-user-id"

            // Load user profile to get weight and calorie target
            guard let profile = try await dbManager.read({ db in
                try UserProfile.fetchByUserId(db, userId: userId)
            }) else {
                // No profile found
                cyclePhase = "Kein aktiver Zyklus"
                currentDay = 0
                daysRemaining = 0
                return
            }

            // Set calorie target from profile
            caloriesTarget = profile.calorieTarget ?? 2000

            // Calculate macro targets if we have weight
            if let weightKg = profile.weightKg {
                // Protein: 2g per kg bodyweight
                proteinTarget = 2.0 * weightKg

                // Fat: 1g per kg bodyweight
                fatTarget = 1.0 * weightKg

                // Carbs: Remaining calories after protein and fat
                let proteinCalories = proteinTarget * 4.0  // 4 kcal per gram
                let fatCalories = fatTarget * 9.0          // 9 kcal per gram
                let remainingCalories = Double(caloriesTarget) - proteinCalories - fatCalories
                carbsTarget = max(0, remainingCalories / 4.0)  // 4 kcal per gram

                #if DEBUG
                print("📊 Macro Targets Calculated:")
                print("   Weight: \(weightKg) kg")
                print("   Calories: \(caloriesTarget) kcal")
                print("   Protein: \(Int(proteinTarget))g (2g × \(weightKg)kg)")
                print("   Fat: \(Int(fatTarget))g (1g × \(weightKg)kg)")
                print("   Carbs: \(Int(carbsTarget))g (remaining calories)")
                #endif
            }

            // Calculate MATADOR cycle status from cycle start date
            if let cycleStart = profile.cycleStartDate {
                let calendar = Calendar.current
                let daysSinceStart = calendar.dateComponents([.day], from: cycleStart, to: timeProvider.now).day ?? 0

                // Calculate current day within the 28-day cycle (1-28)
                let dayInCycle = (daysSinceStart % 28) + 1
                currentDay = dayInCycle

                // Determine phase (Days 1-14: Diet, Days 15-28: Maintenance)
                if dayInCycle <= 14 {
                    cyclePhase = "Diätphase"
                    daysRemaining = 14 - dayInCycle + 1
                } else {
                    cyclePhase = "Erhaltungsphase"
                    daysRemaining = 28 - dayInCycle + 1
                }

                #if DEBUG
                print("🔄 MATADOR Cycle Status:")
                print("   Cycle Start: \(cycleStart)")
                print("   Days Since Start: \(daysSinceStart)")
                print("   Current Day: \(currentDay)")
                print("   Phase: \(cyclePhase)")
                print("   Days Remaining: \(daysRemaining)")
                #endif
            } else {
                // No active cycle
                cyclePhase = "Kein aktiver Zyklus"
                currentDay = 0
                daysRemaining = 0
            }

            // Check if weight was logged today (skip Day 1 since onboarding captures it)
            let shouldShowWeightReminder: Bool
            if let cycleStart = profile.cycleStartDate {
                let calendar = Calendar.current
                let isDay1 = calendar.isDate(cycleStart, inSameDayAs: timeProvider.now)

                if isDay1 {
                    // Day 1: Don't show reminder (onboarding captured weight)
                    shouldShowWeightReminder = false
                } else {
                    // Check if weight was logged today
                    let today = timeProvider.now
                    let hasLoggedToday = try await dbManager.read({ db in
                        try WeightLog.hasLoggedToday(db, userId: userId, today: today)
                    })
                    shouldShowWeightReminder = !hasLoggedToday
                }
            } else {
                // No active cycle
                shouldShowWeightReminder = false
            }

            showWeightReminder = shouldShowWeightReminder

            #if DEBUG
            print("⚖️ Weight Reminder Status:")
            print("   Show Reminder: \(shouldShowWeightReminder)")
            #endif

            // Load weight statistics
            let today = timeProvider.now
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

            let latestWeight = try await dbManager.read({ db in
                try WeightLog.fetchLatest(db, userId: userId)
            })
            let avgToday = try await dbManager.read({ db in
                try WeightLog.calculateAverage(db, userId: userId, days: 7, referenceDate: today)
            })
            let avgYesterday = try await dbManager.read({ db in
                try WeightLog.calculateAverage(db, userId: userId, days: 7, referenceDate: yesterday)
            })
            let weightLogCount = try await dbManager.read({ db in
                try WeightLog.countLastNDays(db, userId: userId, days: 7, referenceDate: today)
            })

            currentWeight = latestWeight?.weightKg
            averageWeight7Days = avgToday

            // Calculate weight trend by comparing today's avg to yesterday's avg
            // Only show trend if we have 2+ data points
            if let todayAvg = avgToday, let yesterdayAvg = avgYesterday, weightLogCount >= 2 {
                // If today's average is higher than yesterday's = trending up (bad)
                // If today's average is same or lower = trending down (good)
                if todayAvg > yesterdayAvg {
                    weightTrend = .up
                } else {
                    weightTrend = .down
                }
            } else {
                // Not enough data for trend - default to down (green)
                weightTrend = .down
            }

            #if DEBUG
            print("⚖️ Weight Statistics:")
            print("   Current: \(currentWeight?.formatted(.number.precision(.fractionLength(1))) ?? "N/A") kg")
            print("   Today's Avg: \(avgToday?.formatted(.number.precision(.fractionLength(2))) ?? "N/A") kg")
            print("   Yesterday's Avg: \(avgYesterday?.formatted(.number.precision(.fractionLength(2))) ?? "N/A") kg")
            print("   Data Points: \(weightLogCount)")
            print("   Trend: \(weightTrend)")
            #endif

            // Load today's meal logs and calculate consumed macros
            let todaysMeals = try await dbManager.read({ db in
                try MealLog.fetchForUserToday(db, userId: userId)
            })

            // Calculate totals from meals
            caloriesConsumed = todaysMeals.reduce(0) { $0 + $1.caloriesKcal }
            proteinConsumed = todaysMeals.reduce(0) { $0 + $1.proteinG }
            carbsConsumed = todaysMeals.reduce(0) { $0 + $1.carbsG }
            fatConsumed = todaysMeals.reduce(0) { $0 + $1.fatG }

            #if DEBUG
            print("🍽️ Today's Meals:")
            print("   Count: \(todaysMeals.count)")
            print("   Calories: \(caloriesConsumed) kcal")
            print("   Protein: \(Int(proteinConsumed))g")
            print("   Carbs: \(Int(carbsConsumed))g")
            print("   Fat: \(Int(fatConsumed))g")
            #endif

        } catch let error as AppError {
            error.report()
            errorMessage = error.userMessage
        } catch {
            let appError = AppError.unknown(error)
            appError.report()
            errorMessage = appError.userMessage
        }
    }

    /// Calculate macro progress percentage
    func macroProgress(consumed: Double, target: Double) -> Double {
        guard target > 0 else { return 0 }
        return min(consumed / target, 1.0)
    }

    /// Formatted percentage string
    func progressText(consumed: Double, target: Double, unit: String) -> String {
        "\(Int(consumed)) / \(Int(target)) \(unit)"
    }
}
