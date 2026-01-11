//
//  MacroProgressView.swift
//  w-diet
//
//  Shared macro progress component with circular ring and macro columns
//

import SwiftUI

/// Displays calorie progress ring with macro breakdown
struct MacroProgressView: View {
    // MARK: - Properties

    let caloriesConsumed: Int
    let caloriesTarget: Int
    let proteinConsumed: Double
    let proteinTarget: Double
    let carbsConsumed: Double
    let carbsTarget: Double
    let fatConsumed: Double
    let fatTarget: Double

    // MARK: - Body

    var body: some View {
        VStack(spacing: 35) {
            // Circular Progress Ring
            ZStack {
                // Center text
                VStack(spacing: 4) {
                    Text(caloriesConsumed, format: .number.grouping(.never))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(caloriesConsumed > 0 ? Theme.fireGold : Theme.gray400)
                    Text("/ \(caloriesTarget.formatted(.number.grouping(.never)))")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Circular ring
                CircularMacroRing(
                    proteinCalories: proteinConsumed * 4, // 4 kcal per gram
                    carbsCalories: carbsConsumed * 4, // 4 kcal per gram
                    fatCalories: fatConsumed * 9, // 9 kcal per gram
                    targetCalories: Double(caloriesTarget)
                )
                .frame(width: 200, height: 200)
            }

            // Three macros side by side
            HStack(spacing: 16) {
                macroColumn(
                    title: "Eiweiß",
                    consumed: proteinConsumed,
                    target: proteinTarget,
                    color: Theme.macroProtein
                )

                macroColumn(
                    title: "Kohlenhydrate",
                    consumed: carbsConsumed,
                    target: carbsTarget,
                    color: Theme.warning
                )

                macroColumn(
                    title: "Fett",
                    consumed: fatConsumed,
                    target: fatTarget,
                    color: Theme.macroFat
                )
            }
        }
    }

    // MARK: - Macro Column

    private func macroColumn(
        title: String,
        consumed: Double,
        target: Double,
        color: Color
    ) -> some View {
        let progress = target > 0 ? min(consumed / target, 1.0) : 0

        return VStack(spacing: 8) {
            // Title
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            // Value (consumed / target)
            Text("\(Int(consumed)) / \(Int(target))")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.gray100)
                        .frame(height: 6)

                    // Fill
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 6)

                    // Border for light mode visibility
                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder(Theme.lightModeBorder, lineWidth: 1)
                        .frame(height: 6)
                }
            }
            .frame(height: 6)
        }
        .frame(maxWidth: .infinity)
    }
}
