//
//  MacroCalculator.swift
//  w-diet
//
//  Macro target calculation based on user's body weight
//

import Foundation

/// Utility for calculating macro targets based on body weight
///
/// **Formulas:**
/// - Protein: 2g × weight(kg)
/// - Fat: 1g × weight(kg)
/// - Carbs: Remaining calories ÷ 4 (4 kcal per gram)
///
/// **Usage:**
/// ```swift
/// let macros = MacroCalculator.calculateMacros(
///     weightKg: 80,
///     targetCalories: 2000
/// )
/// ```
enum MacroCalculator {

    /// Calculate macro targets based on weight and calorie goal
    ///
    /// - Parameters:
    ///   - weightKg: User's body weight in kilograms
    ///   - targetCalories: Daily calorie target
    /// - Returns: Tuple of (protein, carbs, fat) in grams
    static func calculateMacros(
        weightKg: Double,
        targetCalories: Int
    ) -> (protein: Double, carbs: Double, fat: Double) {
        // Protein: 2g per kg bodyweight
        let proteinGrams = 2.0 * weightKg

        // Fat: 1g per kg bodyweight
        let fatGrams = 1.0 * weightKg

        // Calculate calories from protein and fat
        let proteinCalories = proteinGrams * 4.0  // 4 kcal per gram
        let fatCalories = fatGrams * 9.0          // 9 kcal per gram

        // Remaining calories go to carbs
        let remainingCalories = Double(targetCalories) - proteinCalories - fatCalories
        let carbsGrams = max(0, remainingCalories / 4.0)  // 4 kcal per gram, ensure non-negative

        return (
            protein: proteinGrams,
            carbs: carbsGrams,
            fat: fatGrams
        )
    }
}
