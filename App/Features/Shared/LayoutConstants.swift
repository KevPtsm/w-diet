//
//  LayoutConstants.swift
//  w-diet
//
//  Shared layout constants to avoid magic numbers
//

import SwiftUI

/// Centralized layout constants for consistent UI
enum LayoutConstants {
    // MARK: - Timing

    enum Timing {
        /// Search debounce delay in nanoseconds (400ms)
        static let searchDebounceNanoseconds: UInt64 = 400_000_000
    }

    // MARK: - Scan Buttons (FoodSearchView)

    enum ScanButton {
        static let iconSize: CGFloat = 28
        static let frameSize: CGFloat = 36
        static let spacing: CGFloat = 4
    }

    // MARK: - Scanner Views

    enum Scanner {
        static let largeIconSize: CGFloat = 80
        static let imagePreviewHeight: CGFloat = 200
        static let imagePreviewSmallHeight: CGFloat = 150
    }

    // MARK: - Input Fields

    enum Input {
        static let textFieldWidth: CGFloat = 80
    }

    // MARK: - Cards & Containers

    enum Card {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let smallCornerRadius: CGFloat = 10
    }

    // MARK: - Progress Ring

    enum ProgressRing {
        static let size: CGFloat = 200
        static let lineWidth: CGFloat = 16
    }
}
