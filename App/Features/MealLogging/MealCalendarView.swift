//
//  MealCalendarView.swift
//  w-diet
//
//  Monthly calendar view for meal history
//

import SwiftUI
import Charts
import GRDB

/// Calendar view showing monthly meal logging overview with stats
struct MealCalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    let onDateSelected: () -> Void

    @State private var mealLogs: [MealLog] = []
    @State private var currentMonth: Date = Date()
    @State private var isLoading = true

    private let calendar = Calendar.current
    private let authManager: AuthManager

    @MainActor init(
        selectedDate: Binding<Date>,
        onDateSelected: @escaping () -> Void,
        authManager: AuthManager = .shared
    ) {
        self._selectedDate = selectedDate
        self.onDateSelected = onDateSelected
        self.authManager = authManager
    }

    // App launch date - can't go before this
    private var minMonth: Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 1
        return calendar.date(from: components) ?? Date()
    }

    private var isAtMinMonth: Bool {
        guard let currentStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)),
              let minStart = calendar.date(from: calendar.dateComponents([.year, .month], from: minMonth)) else {
            return false
        }
        return currentStart <= minStart
    }

    // MARK: - Computed

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: currentMonth)
    }

    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }

        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
        }
    }

    private var firstWeekday: Int {
        guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return 0
        }
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        return (weekday + 5) % 7 // Convert to Monday=0
    }

    private var logsForCurrentMonth: [MealLog] {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)),
              let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return []
        }
        return mealLogs.filter { $0.loggedAt >= startOfMonth && $0.loggedAt < endOfMonth }
    }

    /// Dictionary of day -> total calories for that day
    private var caloriesByDay: [Int: Int] {
        var dict: [Int: Int] = [:]
        for log in logsForCurrentMonth {
            let day = calendar.component(.day, from: log.loggedAt)
            dict[day, default: 0] += log.caloriesKcal
        }
        return dict
    }

    /// Days with at least one meal logged
    private var daysWithMeals: Set<Int> {
        Set(caloriesByDay.keys)
    }

    /// Total calories for the month
    private var monthTotalCalories: Int {
        logsForCurrentMonth.reduce(0) { $0 + $1.caloriesKcal }
    }

    /// Average calories per day (only counting days with logs)
    private var averageCaloriesPerDay: Int {
        guard !daysWithMeals.isEmpty else { return 0 }
        return monthTotalCalories / daysWithMeals.count
    }

    /// Daily calorie data for trend chart
    private var dailyCalorieData: [(day: Int, calories: Int)] {
        caloriesByDay.map { ($0.key, $0.value) }.sorted { $0.day < $1.day }
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Month navigation with Fertig button
                monthNavigationHeader

                // Calendar grid
                calendarGrid
                    .padding(.horizontal)

                // Stats section
                statsSection
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .task {
            await loadMealHistory()
        }
        .onChange(of: currentMonth) { _, _ in
            Task {
                await loadMealHistory()
            }
        }
    }

    // MARK: - Components

    private var monthNavigationHeader: some View {
        VStack(spacing: 16) {
            // Fertig button row
            HStack {
                Spacer()
                Button("Fertig") {
                    dismiss()
                }
                .foregroundColor(Theme.fireGold)
                .fontWeight(.semibold)
            }
            .padding(.horizontal)

            // Month navigation row
            HStack {
                // Previous month button (hidden for January 2026)
                if isAtMinMonth {
                    // Invisible placeholder
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.clear)
                        .padding(8)
                } else {
                    Button {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(Theme.fireGold)
                            .padding(8)
                    }
                }

                Spacer()

                Text(monthYearString)
                    .font(.headline)

                Spacer()

                // Next month button (hidden for current month)
                if calendar.isDate(currentMonth, equalTo: Date(), toGranularity: .month) {
                    // Invisible placeholder
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(.clear)
                        .padding(8)
                } else {
                    Button {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(Theme.fireGold)
                            .padding(8)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var calendarGrid: some View {
        VStack(spacing: 4) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 4) {
                // Empty cells for offset
                ForEach(0..<firstWeekday, id: \.self) { _ in
                    Color.clear
                        .frame(height: 44)
                }

                // Day cells
                ForEach(daysInMonth, id: \.self) { date in
                    Button {
                        if date <= Date() {
                            // Animate selection
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedDate = date
                            }
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            // Delay dismiss to show selection
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                dismiss()
                                onDateSelected()
                            }
                        }
                    } label: {
                        dayCell(for: date)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(Theme.backgroundSecondary)
        .cornerRadius(12)
    }

    private func dayCell(for date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        let hasMeals = daysWithMeals.contains(day)
        let isToday = calendar.isDateInToday(date)
        let isFuture = date > Date()
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)

        return VStack(spacing: 2) {
            Text("\(day)")
                .font(.caption)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isFuture ? .secondary.opacity(0.5) : (isToday ? Theme.fireGold : .primary))

            // Indicator dot for days with meals
            Circle()
                .fill(hasMeals ? Theme.fireGold : Color.clear)
                .frame(width: 6, height: 6)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Theme.fireGold.opacity(0.2) : (hasMeals ? Theme.fireGold.opacity(0.05) : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(isToday ? Theme.fireGold : Color.clear, lineWidth: 1)
        )
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            statCard(
                title: "Gesamt",
                value: formatCalories(monthTotalCalories),
                icon: "flame.fill",
                color: Theme.fireGold
            )

            statCard(
                title: "Ø / Tag",
                value: formatCalories(averageCaloriesPerDay),
                icon: "chart.bar.fill",
                color: Theme.fireGold
            )

            statCard(
                title: "Tage",
                value: "\(daysWithMeals.count)",
                icon: "calendar",
                color: Theme.success
            )
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.caption)
                .fontWeight(.semibold)

            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Theme.backgroundSecondary)
        .cornerRadius(10)
    }

    private var trendChart: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Kalorien Trend")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()
            }

            let calories = dailyCalorieData.map(\.calories)
            let minC = calories.min() ?? 0
            let maxC = calories.max() ?? 2000
            let range = maxC - minC
            let padding = max(range / 4, 200)
            let yMin = max(0, minC - padding)
            let yMax = maxC + padding

            Chart {
                ForEach(dailyCalorieData, id: \.day) { data in
                    AreaMark(
                        x: .value("Tag", data.day),
                        y: .value("kcal", data.calories)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.fireGold.opacity(0.4), Theme.fireGold.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    LineMark(
                        x: .value("Tag", data.day),
                        y: .value("kcal", data.calories)
                    )
                    .foregroundStyle(Theme.fireGold)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Tag", data.day),
                        y: .value("kcal", data.calories)
                    )
                    .foregroundStyle(Theme.fireGold)
                    .symbolSize(40)
                }
            }
            .chartYScale(domain: yMin...yMax)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 100)
        }
        .padding()
        .background(Theme.backgroundSecondary)
        .cornerRadius(12)
    }

    // MARK: - Helpers

    private func formatCalories(_ calories: Int) -> String {
        if calories >= 10000 {
            return String(format: "%.1fk", Double(calories) / 1000)
        } else {
            return "\(calories)"
        }
    }

    // MARK: - Data Loading

    private func loadMealHistory() async {
        isLoading = true

        guard let userId = authManager.currentUserId else {
            isLoading = false
            return
        }

        do {
            let logs = try await GRDBManager.shared.read { db in
                try MealLog
                    .filter(Column("user_id") == userId)
                    .order(Column("logged_at").desc)
                    .fetchAll(db)
            }
            mealLogs = logs
        } catch {
            print("Error loading meal history: \(error)")
        }

        isLoading = false
    }
}

// MARK: - Preview

#Preview {
    MealCalendarView(
        selectedDate: .constant(Date()),
        onDateSelected: {}
    )
}
