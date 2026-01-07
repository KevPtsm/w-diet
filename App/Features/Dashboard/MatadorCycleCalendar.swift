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
/// - Completed days: Checkmark
struct MatadorCycleCalendar: View {
    /// Current day in cycle (1-28), 0 if no active cycle
    let currentDay: Int

    /// Whether to show template (no active cycle) or progress
    var isTemplate: Bool {
        currentDay == 0
    }

    private let daysPerWeek = 7
    private let totalWeeks = 4

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
            // Phase label (Diät for weeks 1-2, Erhalt for weeks 3-4)
            Text(week < 2 ? "Diät" : "Erhalt")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)

            // 7 day circles
            ForEach(1...daysPerWeek, id: \.self) { dayInWeek in
                let dayNumber = week * daysPerWeek + dayInWeek
                dayCircle(dayNumber: dayNumber, week: week)
            }
        }
    }

    // MARK: - Day Circle

    private func dayCircle(dayNumber: Int, week: Int) -> some View {
        let isDietPhase = week < 2  // Week 1-2 are diet phase
        let isCurrentDay = dayNumber == currentDay
        let isCompleted = !isTemplate && dayNumber < currentDay

        return ZStack {
            // Background circle
            Circle()
                .fill(isCompleted ? Color.clear : (isDietPhase ? Theme.fireGold.opacity(0.2) : Theme.maintenancePhase))
                .frame(width: 28, height: 28)

            // Border for current day
            if isCurrentDay {
                Circle()
                    .strokeBorder(Theme.fireGold, lineWidth: 2)
                    .frame(width: 28, height: 28)
            }

            // Content
            if isCompleted {
                // Ashes/smoke for completed days (burned out, no background)
                Image(systemName: "smoke.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary.opacity(0.5))
            } else if isCurrentDay {
                // Fire icon for current day
                Image(systemName: "flame.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Theme.fireGold)
            } else if isTemplate {
                // Empty circle for template
                Circle()
                    .fill(isDietPhase ? Theme.fireGold : Theme.maintenanceAccent)
                    .frame(width: 8, height: 8)
            } else {
                // Future day - smaller dot
                Circle()
                    .fill(isDietPhase ? Theme.fireGold.opacity(0.4) : Theme.maintenanceAccent)
                    .frame(width: 6, height: 6)
            }
        }
    }
}

// MARK: - Preview

#Preview("Active Cycle - Day 5") {
    VStack {
        MatadorCycleCalendar(currentDay: 5)
            .padding()
            .background(Theme.backgroundSecondary)
            .cornerRadius(16)
            .padding()
    }
}

#Preview("No Active Cycle") {
    VStack {
        MatadorCycleCalendar(currentDay: 0)
            .padding()
            .background(Theme.backgroundSecondary)
            .cornerRadius(16)
            .padding()
    }
}

#Preview("Maintenance Phase - Day 18") {
    VStack {
        MatadorCycleCalendar(currentDay: 18)
            .padding()
            .background(Theme.backgroundSecondary)
            .cornerRadius(16)
            .padding()
    }
}
