//
//  OnboardingViewModel.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 06.01.26.
//

import Foundation
import SwiftUI
import Combine
import GRDB

/// ViewModel for the onboarding flow
///
/// **CRITICAL RULES:**
/// - Must be @MainActor for UI updates
/// - State machine pattern for step navigation
/// - All data saved to GRDB on completion
/// - Never skip validation before proceeding to next step
///
/// **Usage:**
/// ```swift
/// @StateObject private var viewModel = OnboardingViewModel()
/// ```
@MainActor
final class OnboardingViewModel: ObservableObject {
    // MARK: - Published Properties

    /// Current step in onboarding flow (1-9)
    @Published var currentStep: Int = 1

    /// Loading state for async operations
    @Published var isLoading = false

    /// Error message to display
    @Published var errorMessage: String?

    // MARK: - Step 1: Goal Selection

    /// Selected fitness goal ("lose_weight", "maintain_weight", "gain_muscle")
    @Published var selectedGoal: String?

    // MARK: - Step 2: Gender Selection (NEW - Story 1.3)

    /// Selected gender ("male", "female")
    @Published var selectedGender: String?

    // MARK: - Step 3: Height Input (NEW - Story 1.3)

    /// Height input in cm (as string for Picker binding)
    @Published var heightInput: String = ""

    /// Validation error for height input
    @Published var heightInputError: String?

    // MARK: - Step 4: Weight Input (NEW - Story 1.3)

    /// Weight input in kg (as string for Picker binding)
    @Published var weightInput: String = ""

    /// Validation error for weight input
    @Published var weightInputError: String?

    // MARK: - Step 5: Activity Level (NEW - Story 1.3)

    /// Selected activity level ("sedentary", "lightly_active", "moderately_active", "very_active", "extra_active")
    @Published var selectedActivityLevel: String?

    // MARK: - Step 6: Calorie Target (was Step 2)

    /// Daily calorie target (as string for TextField binding)
    @Published var calorieTargetInput: String = ""

    /// Validation error for calorie input
    @Published var calorieInputError: String?

    /// Originally calculated calorie target (for dynamic warning threshold)
    @Published var calculatedCalorieTarget: Int = 0

    // MARK: - Step 3: Eating Window

    /// Eating window start time
    @Published var eatingWindowStart: Date = {
        var components = DateComponents()
        components.hour = 12
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()

    /// Eating window end time
    @Published var eatingWindowEnd: Date = {
        var components = DateComponents()
        components.hour = 18
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()

    /// Computed eating window duration in hours
    var eatingWindowDuration: Int {
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: eatingWindowStart)
        let endHour = calendar.component(.hour, from: eatingWindowEnd)

        if endHour >= startHour {
            return endHour - startHour
        } else {
            return (24 - startHour) + endHour
        }
    }

    // MARK: - Dependencies

    private let dbManager: GRDBManager
    private let authManager: AuthManager

    // MARK: - Initialization

    nonisolated init(
        dbManager: GRDBManager = .shared,
        authManager: AuthManager = .shared
    ) {
        self.dbManager = dbManager
        self.authManager = authManager
    }

    // MARK: - Navigation Methods

    /// Advance to next step with validation
    func nextStep() {
        // Validate current step before proceeding
        guard validateCurrentStep() else {
            return
        }

        // Calculate and pre-fill calorie target after activity level (Step 5 -> Step 6)
        if currentStep == 5 {
            calculateAndSetCalorieTarget()
        }

        // Advance step
        currentStep += 1
    }

    /// Calculate calorie target using Mifflin-St Jeor equation
    private func calculateAndSetCalorieTarget() {
        // Ensure we have all required data
        guard let gender = selectedGender,
              let heightCm = Double(heightInput),
              let weightKg = Double(weightInput),
              let activityLevel = selectedActivityLevel,
              let goal = selectedGoal else {
            // Fallback to simple default if calculation not possible
            let defaultCalories = selectedGoal == "lose_weight" ? 1800 : 2000
            calorieTargetInput = "\(defaultCalories)"
            return
        }

        // Calculate TDEE using Mifflin-St Jeor
        guard let tdee = CalorieCalculator.calculateTDEE(
            gender: gender,
            heightCm: heightCm,
            weightKg: weightKg,
            age: 30, // Default age assumption
            activityLevel: activityLevel
        ) else {
            // Fallback if calculation fails
            let defaultCalories = goal == "lose_weight" ? 1800 : 2000
            calorieTargetInput = "\(defaultCalories)"
            return
        }

        // Calculate target based on goal
        let targetCalories = CalorieCalculator.calculateTargetCalories(tdee: tdee, goal: goal)
        calorieTargetInput = "\(targetCalories)"
        calculatedCalorieTarget = targetCalories // Store for dynamic warning threshold

        #if DEBUG
        print("📊 Calorie Calculation:")
        print("   Gender: \(gender)")
        print("   Height: \(heightCm) cm")
        print("   Weight: \(weightKg) kg")
        print("   Activity: \(activityLevel)")
        print("   TDEE: \(tdee) kcal")
        print("   Goal: \(goal)")
        print("   Target: \(targetCalories) kcal")
        #endif
    }

    /// Go back to previous step
    func previousStep() {
        guard currentStep > 1 else { return }
        currentStep -= 1

        // Clear any validation errors when going back
        errorMessage = nil
        calorieInputError = nil
    }

    /// Complete onboarding and save to database
    func completeOnboarding() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // TEMPORARY: Use mock user ID until auth is set up
            let userId = "mock-user-id"
            let email = "mock@example.com"

            // TODO: Uncomment when AuthManager is properly configured
            // guard let userId = authManager.currentUserId else {
            //     throw AppError.auth(.notAuthenticated)
            // }
            //
            // guard let email = authManager.currentUserEmail else {
            //     throw AppError.auth(.notAuthenticated)
            // }

            // Convert calorie input to integer
            guard let calorieTarget = Int(calorieTargetInput) else {
                errorMessage = "Invalid calorie target"
                return
            }

            // Convert eating window times to HH:mm format
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"

            let windowStart = timeFormatter.string(from: eatingWindowStart)
            let windowEnd = timeFormatter.string(from: eatingWindowEnd)

            // Fetch existing user profile or create new one
            let existingProfile = try await dbManager.read { db in
                try UserProfile.fetchByUserId(db, userId: userId)
            }

            // Convert inputs to proper types for saving
            let heightCmValue = Double(heightInput)
            let weightKgValue = Double(weightInput)

            // Start MATADOR cycle on the completion date
            let cycleStartDate = Date()

            let updatedProfile: UserProfile
            if let existing = existingProfile {
                // Update existing profile with onboarding data
                updatedProfile = UserProfile(
                    id: existing.id,
                    userId: existing.userId,
                    email: existing.email,
                    goal: selectedGoal,
                    calorieTarget: calorieTarget,
                    eatingWindowStart: windowStart,
                    eatingWindowEnd: windowEnd,
                    onboardingCompleted: true,
                    gender: selectedGender,
                    heightCm: heightCmValue,
                    weightKg: weightKgValue,
                    activityLevel: selectedActivityLevel,
                    calculatedCalories: calculatedCalorieTarget,
                    cycleStartDate: cycleStartDate,
                    createdAt: existing.createdAt,
                    updatedAt: Date(),
                    syncedAt: nil // Mark as needing sync
                )

                try await dbManager.write { db in
                    try updatedProfile.update(db)
                }
            } else {
                // Create new profile with onboarding data
                updatedProfile = UserProfile(
                    userId: userId,
                    email: email,
                    goal: selectedGoal,
                    calorieTarget: calorieTarget,
                    eatingWindowStart: windowStart,
                    eatingWindowEnd: windowEnd,
                    onboardingCompleted: true,
                    gender: selectedGender,
                    heightCm: heightCmValue,
                    weightKg: weightKgValue,
                    activityLevel: selectedActivityLevel,
                    calculatedCalories: calculatedCalorieTarget,
                    cycleStartDate: cycleStartDate
                )

                try await dbManager.write { db in
                    try updatedProfile.insert(db)
                }
            }

            // Create initial weight log entry
            if let weightKg = weightKgValue {
                let initialWeightLog = WeightLog(
                    userId: userId,
                    weightKg: weightKg,
                    loggedAt: cycleStartDate
                )

                try await dbManager.write { db in
                    try initialWeightLog.insert(db)
                }

                #if DEBUG
                print("📊 Created initial weight log: \(weightKg) kg")
                #endif
            }

            #if DEBUG
            print("✅ Onboarding completed for user \(userId)")
            print("   Goal: \(selectedGoal ?? "none")")
            print("   Gender: \(selectedGender ?? "none")")
            print("   Height: \(heightInput) cm")
            print("   Weight: \(weightInput) kg")
            print("   Activity: \(selectedActivityLevel ?? "none")")
            print("   Calorie Target: \(calorieTarget) kcal")
            print("   Eating Window: \(windowStart) - \(windowEnd)")
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

    // MARK: - Validation

    /// Validate current step before allowing navigation
    private func validateCurrentStep() -> Bool {
        switch currentStep {
        case 1: // Goal Selection
            guard selectedGoal != nil else {
                errorMessage = "Please select a goal"
                return false
            }
            return true

        case 2: // Gender Selection
            guard selectedGender != nil else {
                errorMessage = "Please select your gender"
                return false
            }
            return true

        case 3: // Height Input
            guard !heightInput.isEmpty else {
                heightInputError = "Please enter your height"
                return false
            }

            guard let height = Double(heightInput) else {
                heightInputError = "Please enter a valid number"
                return false
            }

            // Validate range (100-220 cm)
            guard height >= 100 && height <= 220 else {
                heightInputError = "Height must be between 100-220 cm"
                return false
            }

            heightInputError = nil
            return true

        case 4: // Weight Input
            guard !weightInput.isEmpty else {
                weightInputError = "Please enter your weight"
                return false
            }

            guard let weight = Double(weightInput) else {
                weightInputError = "Please enter a valid number"
                return false
            }

            // Validate range (kg only)
            guard weight >= 40 && weight <= 200 else {
                weightInputError = "Weight must be between 40-200 kg"
                return false
            }

            weightInputError = nil
            return true

        case 5: // Activity Level
            guard selectedActivityLevel != nil else {
                errorMessage = "Please select your activity level"
                return false
            }
            return true

        case 6: // Calorie Target
            // Validate calorie input
            guard !calorieTargetInput.isEmpty else {
                calorieInputError = "Please enter a calorie target"
                return false
            }

            guard let calories = Int(calorieTargetInput) else {
                calorieInputError = "Please enter a valid number"
                return false
            }

            // Dynamic threshold: calculated target - 200, or 1400 if no calculation yet
            let minThreshold = calculatedCalorieTarget > 0 ? calculatedCalorieTarget - 200 : 1400

            guard calories >= minThreshold && calories <= 9999 else {
                if calories < minThreshold {
                    calorieInputError = "Kalorienziel muss mindestens \(minThreshold) kcal betragen"
                } else {
                    calorieInputError = "Kalorienziel darf maximal 9999 kcal betragen"
                }
                return false
            }

            calorieInputError = nil
            return true

        case 7: // Eating Window
            // Validate eating window (no validation needed, time pickers always valid)
            return true

        case 8: // MATADOR Explainer
            // No input required, always valid
            return true

        case 9: // Completion
            // Final step, no validation needed
            return true

        default:
            return false
        }
    }

    /// Check if continue button should be enabled for current step
    var canContinue: Bool {
        switch currentStep {
        case 1:
            return selectedGoal != nil
        case 2:
            return selectedGender != nil
        case 3:
            return !heightInput.isEmpty && heightInputError == nil
        case 4:
            return !weightInput.isEmpty && weightInputError == nil
        case 5:
            return selectedActivityLevel != nil
        case 6:
            return !calorieTargetInput.isEmpty && calorieInputError == nil
        case 7:
            return true
        case 8:
            return true
        case 9:
            return true
        default:
            return false
        }
    }

    // MARK: - Helper Methods

    /// Get formatted eating window string (e.g., "12:00 - 20:00")
    var formattedEatingWindow: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let start = formatter.string(from: eatingWindowStart)
        let end = formatter.string(from: eatingWindowEnd)
        return "\(start) - \(end)"
    }

    /// Get display name for selected goal
    var goalDisplayName: String {
        switch selectedGoal {
        case "lose_weight":
            return "Gewicht verlieren"
        case "maintain_weight":
            return "Gewicht halten"
        case "gain_muscle":
            return "Muskeln aufbauen"
        default:
            return "Nicht festgelegt"
        }
    }
}
