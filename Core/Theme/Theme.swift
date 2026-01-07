//
//  Theme.swift
//  w-diet
//
//  Design System - Color Palette
//  Based on: _bmad-output/planning-artifacts/ux-design-specification.md
//

import SwiftUI

/// Global theme constants for w-diet app
///
/// **CRITICAL RULES:**
/// - ALWAYS reference this file for colors (NEVER use Color.blue, Color.red, etc.)
/// - ALWAYS check UX design specification when adding new UI elements
/// - Colors based on savanna-inspired palette
enum Theme {
    // MARK: - Primary Colors

    /// Fire Gold - Primary brand color
    /// Used for: Primary buttons, active states, progress indicators
    static let fireGold = Color(hex: "F4A460")

    /// Energy Orange - Accent color
    /// Used for: Call-to-action buttons, highlights, important notifications
    static let energyOrange = Color(hex: "FF6B35")

    // MARK: - Text Colors

    /// Primary text color - Dark gray for main content
    static let textPrimary = Color(hex: "2D2D2D")

    /// Secondary text color - Medium gray for supporting text
    static let textSecondary = Color(hex: "757575")

    /// Tertiary text color - Light gray for disabled/placeholder (same as gray400)
    static let textTertiary = Color(hex: "BDBDBD")

    // MARK: - Background Colors

    /// Primary background - Off-white for main app background (adapts to dark mode)
    static let backgroundPrimary = Color(UIColor.systemGroupedBackground)

    /// Secondary background - White for cards and elevated surfaces (adapts to dark mode)
    static let backgroundSecondary = Color(UIColor.secondarySystemGroupedBackground)

    // MARK: - Semantic Colors

    /// Success state - Green for positive actions and success messages
    static let success = Color(hex: "4CAF50")

    /// Warning state - Orange for warnings and caution messages
    static let warning = Color(hex: "FFA726")

    /// Error state - Red for errors and destructive actions
    static let error = Color(hex: "EF5350")

    /// Info state - Blue for informational messages
    static let info = Color(hex: "42A5F5")

    // MARK: - Macro Colors

    /// Protein color - Deep orange-red (darker than carbs gold)
    static let macroProtein = Color(hex: "D35400")

    /// Fat color - Light warm peach (brighter than carbs gold)
    static let macroFat = Color(hex: "FFCC80")

    // MARK: - Neutral Grays

    /// Light gray - borders, dividers, disabled states (adapts to dark mode)
    static let gray100 = Color(UIColor.systemGray6)
    static let gray200 = Color(hex: "EEEEEE")
    static let gray300 = Color(hex: "E0E0E0")
    static let gray400 = textTertiary  // Same as textTertiary
    static let gray500 = Color(hex: "9E9E9E")

    // MARK: - Component-Specific Colors (Aliases)

    /// Disabled state - alias for gray300
    static let disabled = gray300

    /// Divider lines - alias for gray300
    static let divider = gray300

    // MARK: - MATADOR Cycle Colors (for visualization)

    /// Maintenance phase - Soft mint (fresh, rejuvenating recovery phase)
    static let maintenancePhase = Color(hex: "B8E0D2")

    /// Maintenance phase accent - Darker mint for dots/indicators
    static let maintenanceAccent = Color(hex: "8FCDB8")

    /// Deficit phase - Orange/Gold for calorie deficit weeks
    static let deficitPhase = fireGold
}

// MARK: - Color Extension for Hex Support

extension Color {
    /// Initialize Color from hex string
    /// Example: Color(hex: "F4A460")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
