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
        case "extra_active", "extremely_active":
            return 1.9
        default:
            return nil
        }
    }

    // MARK: - MATADOR Protocol

    /// MATADOR diet phase calorie factor (67% of TDEE = 33% deficit)
    static let matadorDietFactor: Double = 0.67

    /// Calculate MATADOR phase-adjusted calories
    ///
    /// **MATADOR Protocol (Byrne et al., 2017):**
    /// - Diet phase (Days 1-14): 67% of TDEE (33% energy restriction)
    /// - Maintenance phase (Days 15-28): 100% of TDEE (energy balance)
    ///
    /// The 2-week "metabolic rest periods" at energy balance reverse
    /// adaptive thermogenesis within 10-14 days.
    ///
    /// - Parameters:
    ///   - tdee: Total Daily Energy Expenditure
    ///   - isDietPhase: True if in diet phase (days 1-14), false for maintenance (days 15-28)
    /// - Returns: Phase-adjusted calorie target
    static func calculateMatadorCalories(tdee: Int, isDietPhase: Bool) -> Int {
        if isDietPhase {
            // Diet phase: 67% of TDEE (33% deficit)
            let dietCalories = Int(Double(tdee) * matadorDietFactor)
            // Ensure minimum 1200 kcal for safety
            return max(dietCalories, 1200)
        } else {
            // Maintenance phase: 100% of TDEE
            return tdee
        }
    }

}
