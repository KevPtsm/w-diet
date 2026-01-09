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

    // MARK: - Dependencies

    private let dbManager: GRDBManager
    private let authManager: AuthManager

    // MARK: - Initialization

    init(dbManager: GRDBManager = .shared, authManager: AuthManager = .shared) {
        self.dbManager = dbManager
        self.authManager = authManager
    }

    // MARK: - Actions

    func loadTodaysMeals() async {
        isLoading = true
        defer { isLoading = false }

        guard let userId = authManager.currentUserId else { return }

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
}
