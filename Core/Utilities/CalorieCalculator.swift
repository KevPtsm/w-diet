//
//  CalorieCalculator.swift
//  w-diet
//
//  Created for Story 1.3 - Enhanced Onboarding
//

import Foundation

/// Utility for calculating calorie needs using the Mifflin-St Jeor equation
///
/// **Formula:**
/// - Male BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age + 5
/// - Female BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age - 161
/// - TDEE = BMR × Activity Factor
///
/// **Activity Factors:**
/// - Sedentary (little/no exercise): 1.2
/// - Lightly active (exercise 1-3 days/week): 1.375
/// - Moderately active (exercise 3-5 days/week): 1.55
/// - Very active (exercise 6-7 days/week): 1.725
/// - Extra active (intense exercise daily): 1.9
enum CalorieCalculator {

    /// Calculate Total Daily Energy Expenditure (TDEE) using Mifflin-St Jeor equation
    ///
    /// - Parameters:
    ///   - gender: User's gender ("male" or "female")
    ///   - heightCm: Height in centimeters
    ///   - weightKg: Weight in kilograms
    ///   - age: Age in years (defaults to 30 if not provided)
    ///   - activityLevel: Activity level identifier
    /// - Returns: Calculated TDEE in calories, or nil if inputs are invalid
    static func calculateTDEE(
        gender: String,
        heightCm: Double,
        weightKg: Double,
        age: Int = 30,
        activityLevel: String
    ) -> Int? {
        // Validate inputs
        guard heightCm > 0, weightKg > 0, age > 0 else {
            return nil
        }

        // Calculate BMR using Mifflin-St Jeor equation
        let bmr: Double
        if gender == "male" {
            bmr = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) + 5
        } else if gender == "female" {
            bmr = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) - 161
        } else {
            return nil // Invalid gender
        }

        // Get activity factor
        guard let activityFactor = getActivityFactor(for: activityLevel) else {
            return nil
        }

        // Calculate TDEE
        let tdee = bmr * activityFactor

        return Int(tdee.rounded())
    }

    /// Calculate recommended calorie target based on goal
    ///
    /// **Calculation Logic:**
    /// 1. Round TDEE down to nearest 100 (e.g., 2832 → 2800)
    /// 2. Apply goal-based adjustment:
    ///    - Weight Loss: -700 kcal (e.g., 2800 → 2100)
    ///    - Maintenance: no change
    ///    - Muscle Gain: +300 kcal
    /// 3. Ensure minimum of 1500 kcal for health and sustainability
    ///
    /// - Parameters:
    ///   - tdee: Total Daily Energy Expenditure
    ///   - goal: User's fitness goal ("lose_weight", "maintain_weight", "gain_muscle")
    /// - Returns: Recommended calorie target
    static func calculateTargetCalories(tdee: Int, goal: String) -> Int {
        // Absolute minimum for health (WHO recommendation)
        let minimumCalories = 1500

        // Round down to nearest 100
        let roundedTDEE = (tdee / 100) * 100

        let targetCalories: Int
        switch goal {
        case "lose_weight":
            // 700 calorie deficit for healthy weight loss (~0.7 kg/week)
            targetCalories = roundedTDEE - 700
        case "maintain_weight":
            // Maintain at rounded TDEE
            targetCalories = roundedTDEE
        case "gain_muscle":
            // 300 calorie surplus for muscle gain
            targetCalories = roundedTDEE + 300
        default:
            targetCalories = roundedTDEE
        }

        // Ensure we never go below minimum
        return max(targetCalories, minimumCalories)
    }

    /// Get activity factor multiplier for TDEE calculation
    ///
    /// - Parameter activityLevel: Activity level identifier
    /// - Returns: Activity factor, or nil if invalid
    private static func getActivityFactor(for activityLevel: String) -> Double? {
        switch activityLevel {
        case "sedentary":
            return 1.2
        case "lightly_active":
            return 1.375
        case "moderately_active":
            return 1.55
        case "very_active":
            return 1.725
        case "extra_active":
            return 1.9
        default:
            return nil
        }
    }

    /// Get display name for activity level
    ///
    /// - Parameter activityLevel: Activity level identifier
    /// - Returns: Human-readable name
    static func getActivityLevelName(for activityLevel: String) -> String {
        switch activityLevel {
        case "sedentary":
            return "Sedentary"
        case "lightly_active":
            return "Lightly Active"
        case "moderately_active":
            return "Moderately Active"
        case "very_active":
            return "Very Active"
        case "extra_active":
            return "Extra Active"
        default:
            return "Unknown"
        }
    }
}
