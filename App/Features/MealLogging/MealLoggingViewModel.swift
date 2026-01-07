//
//  MealLoggingViewModel.swift
//  w-diet
//
//  ViewModel for meal logging screen
//

import Combine
import Foundation
import GRDB
import SwiftUI

@MainActor
final class MealLoggingViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var todaysMeals: [MealLog] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Computed Properties

    var totalCalories: Int {
        todaysMeals.reduce(0) { $0 + $1.caloriesKcal }
    }

    var totalProtein: Double {
        todaysMeals.reduce(0) { $0 + $1.proteinG }
    }

    var totalCarbs: Double {
        todaysMeals.reduce(0) { $0 + $1.carbsG }
    }

    var totalFat: Double {
        todaysMeals.reduce(0) { $0 + $1.fatG }
    }

    // MARK: - Dependencies

    private let dbManager: GRDBManager

    // MARK: - Initialization

    init(dbManager: GRDBManager = .shared) {
        self.dbManager = dbManager
    }

    // MARK: - Actions

    func loadTodaysMeals() async {
        isLoading = true
        defer { isLoading = false }

        let userId = "mock-user-id" // TODO: Get from auth manager

        // Get start and end of today
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        do {
            // Run database query on background thread
            let meals = try await Task.detached { [dbManager] in
                try dbManager.read { db in
                    try MealLog.fetchForUserToday(db, userId: userId)
                }
            }.value

            todaysMeals = meals
        } catch {
            errorMessage = "Fehler beim Laden der Mahlzeiten"
            AppError.databaseQueryFailed(query: "fetch_todays_meals", underlying: error).report()
        }
    }

    func deleteMeal(_ meal: MealLog) async {
        guard let mealId = meal.id else { return }

        do {
            // Run database operation on background thread
            try await Task.detached { [dbManager] in
                try dbManager.write { db in
                    try db.execute(sql: "DELETE FROM meal_logs WHERE id = ?", arguments: [mealId])
                }
            }.value

            // Remove from local list
            todaysMeals.removeAll { $0.id == mealId }
        } catch {
            errorMessage = "Fehler beim Löschen der Mahlzeit"
            AppError.databaseWriteFailed(operation: "delete_meal", underlying: error).report()
        }
    }

    func addMeal(_ meal: MealLog) async {
        do {
            // Run database operation on background thread
            try await Task.detached { [dbManager] in
                var mutableMeal = meal
                try dbManager.write { db in
                    try mutableMeal.insert(db)
                }
            }.value

            // Reload to get updated list
            await loadTodaysMeals()
        } catch {
            errorMessage = "Fehler beim Speichern der Mahlzeit"
            AppError.databaseWriteFailed(operation: "insert_meal", underlying: error).report()
        }
    }
}
