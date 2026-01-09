//
//  MatadorCycleCalendar.swift
//  w-diet
//
//  MATADOR cycle visual calendar component
//

import SwiftUI

/// Visual calendar showing 4-week MATADOR cycle (2 weeks diet + 2 weeks maintenance)
///
/// **Design:**
/// - 4 rows × 7 columns grid
/// - Week 1-2: Fire Gold (diet phase)
/// - Week 3-4: Gray (maintenance phase)
/// - Current day: Highlighted with ring
/// - Completed days: Show date number faded
/// - Future days: Show date number
struct MatadorCycleCalendar: View {
    /// Current day in cycle (1-28), 0 if no active cycle
    let currentDay: Int

    /// Start date of the cycle (for displaying actual calendar dates)
    let cycleStartDate: Date?

    /// Whether to show template (no active cycle) or progress
    var isTemplate: Bool {
        currentDay == 0
    }

    private let daysPerWeek = 7
    private let totalWeeks = 4
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 12) {
            // Week rows
            ForEach(0..<totalWeeks, id: \.self) { week in
                weekRow(week: week)
            }
        }
    }

    // MARK: - Week Row

    private func weekRow(week: Int) -> some View {
        HStack(spacing: 8) {
            // Phase label (only show on first week of each phase)
            if week == 0 {
                Text("Diät")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .leading)
            } else if week == 2 {
                Text("Erhalt")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .leading)
            } else {
                // Empty space for alignment
                Spacer()
                    .frame(width: 50)
            }

            // 7 day circles
            ForEach(1...daysPerWeek, id: \.self) { dayInWeek in
                let dayNumber = week * daysPerWeek + dayInWeek
                dayCircle(dayNumber: dayNumber, week: week)
            }
        }
    }

    // MARK: - Helper Functions

    /// Get the calendar day number (1-31) for a given day in the cycle
    private func calendarDayNumber(forCycleDay dayNumber: Int) -> Int {
        guard let startDate = cycleStartDate else { return dayNumber }
        guard let date = calendar.date(byAdding: .day, value: dayNumber - 1, to: startDate) else { return dayNumber }
        return calendar.component(.day, from: date)
    }

    // MARK: - Day Circle

    private func dayCircle(dayNumber: Int, week: Int) -> some View {
        let isDietPhase = week < 2  // Week 1-2 are diet phase
        let isCurrentDay = dayNumber == currentDay
        let isCompleted = !isTemplate && dayNumber < currentDay
        let calendarDay = calendarDayNumber(forCycleDay: dayNumber)

        return ZStack {
            // Background circle - only for non-completed days
            if !isCompleted {
                Circle()
                    .fill(isDietPhase ? Theme.fireGold.opacity(0.2) : Theme.maintenancePhase)

                // Light mode border for visibility
                Circle()
                    .strokeBorder(Theme.lightModeBorder, lineWidth: 1)
            }

            // Border for current day (on top of light mode border)
            if isCurrentDay {
                Circle()
                    .strokeBorder(Theme.fireGold, lineWidth: 2)
            }

            // Content - icons for completed/current, numbers for future
            if isCompleted {
                // Completed day - dimmed ember with black outline for visibility
                ZStack {
                    // Black outline/stroke effect
                    Image(systemName: "smoke.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                        .offset(x: 0.5, y: 0.5)
                    Image(systemName: "smoke.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                        .offset(x: -0.5, y: -0.5)
                    // Main icon
                    Image(systemName: "smoke.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.fireGold.opacity(0.6))
                }
            } else if isCurrentDay {
                // Current day - fire icon (active burn)
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.fireGold)
            } else if isTemplate {
                // Template mode - show day numbers
                Text("\(calendarDay)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary)
            } else {
                // Future day - normal number
                Text("\(calendarDay)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
        .frame(width: 28, height: 28) // Fixed frame for consistent spacing
    }
}

// MARK: - Preview

#Preview("Active Cycle - Day 5") {
    VStack {
        // Start date: Jan 4, 2026 -> Day 5 = Jan 8
        MatadorCycleCalendar(currentDay: 5, cycleStartDate: Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 4)))
            .padding()
            .background(Theme.backgroundSecondary)
            .cornerRadius(16)
            .padding()
    }
}

#Preview("No Active Cycle") {
    VStack {
        MatadorCycleCalendar(currentDay: 0, cycleStartDate: nil)
            .padding()
            .background(Theme.backgroundSecondary)
            .cornerRadius(16)
            .padding()
    }
}

#Preview("Maintenance Phase - Day 18") {
    VStack {
        // Start date: Dec 22, 2025 -> Day 18 = Jan 8
        MatadorCycleCalendar(currentDay: 18, cycleStartDate: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 22)))
            .padding()
            .background(Theme.backgroundSecondary)
            .cornerRadius(16)
            .padding()
    }
}
