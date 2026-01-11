//
//  WeightHistoryView.swift
//  w-diet
//
//  Weight history with calendar and trend visualization
//

import Charts
import GRDB
import SwiftUI

/// View showing weight history with calendar grid and trend chart
struct WeightHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var weightLogs: [WeightLog] = []
    @State private var isLoading = true
    @State private var currentMonth: Date = Date()
    @State private var showWeightEntry = false
    @State private var selectedDate: Date?

    private let calendar = Calendar.current

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
        // Adjust for Monday start (1 = Sunday in Calendar, so Monday = 2)
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        return (weekday + 5) % 7 // Convert to Monday=0
    }

    private var logsForCurrentMonth: [WeightLog] {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)),
              let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return []
        }
        return weightLogs.filter { $0.loggedAt >= startOfMonth && $0.loggedAt < endOfMonth }
    }

    private var logsDict: [String: WeightLog] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var dict: [String: WeightLog] = [:]
        // weightLogs is sorted DESC, so first entry per day is the most recent
        for log in weightLogs {
            let key = formatter.string(from: log.loggedAt)
            if dict[key] == nil {
                dict[key] = log  // Only keep the most recent (first) entry per day
            }
        }
        return dict
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Month navigation
                    monthNavigationHeader

                    // Calendar grid (full width)
                    calendarGrid
                        .padding(.horizontal)

                    // Stats section
                    statsSection
                        .padding(.horizontal)

                    // Trend chart below stats
                    miniTrendChart
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Gewichtsverlauf")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadWeightHistory()
            }
            .sheet(isPresented: $showWeightEntry) {
                if let date = selectedDate {
                    WeightEntrySheet(
                        date: date,
                        existingWeight: getExistingWeight(for: date),
                        onSave: {
                            Task {
                                await loadWeightHistory()
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Helpers

    private func getExistingWeight(for date: Date) -> Double? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: date)
        return logsDict[key]?.weightKg
    }

    // MARK: - Components

    private var monthNavigationHeader: some View {
        HStack {
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
            .disabled(isAtMinMonth)
            .opacity(isAtMinMonth ? 0.3 : 1)

            Spacer()

            Text(monthYearString)
                .font(.headline)

            Spacer()

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
            .disabled(calendar.isDate(currentMonth, equalTo: Date(), toGranularity: .month))
            .opacity(calendar.isDate(currentMonth, equalTo: Date(), toGranularity: .month) ? 0.3 : 1)
        }
        .padding(.horizontal)
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
                        // Only allow tapping on dates that aren't in the future
                        if date <= Date() {
                            selectedDate = date
                            showWeightEntry = true
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: date)
        let log = logsDict[key]
        let isToday = calendar.isDateInToday(date)
        let isFuture = date > Date()

        return VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.caption)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isFuture ? .secondary.opacity(0.5) : (isToday ? Theme.fireGold : .primary))

            if let weight = log?.weightKg {
                Text(String(format: "%.1f", weight))
                    .font(.system(size: 8))
                    .fontWeight(.medium)
                    .foregroundColor(Theme.fireGold)
            } else {
                Text("--")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary.opacity(0.3))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(log != nil ? Theme.fireGold.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(isToday ? Theme.fireGold : Color.clear, lineWidth: 1)
        )
    }

    private var miniTrendChart: some View {
        VStack(spacing: 12) {
            // Header with title and change indicator
            HStack {
                Text("Trend")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                // Month change indicator
                if let first = logsForCurrentMonth.sorted(by: { $0.loggedAt < $1.loggedAt }).first,
                   let last = logsForCurrentMonth.sorted(by: { $0.loggedAt < $1.loggedAt }).last,
                   first.id != last.id {
                    let change = last.weightKg - first.weightKg
                    Text(String(format: "%+.1f kg", change))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(change < 0 ? Theme.success : Theme.warning)
                }
            }

            if logsForCurrentMonth.count >= 2 {
                let weights = logsForCurrentMonth.map(\.weightKg)
                let minW = weights.min() ?? 0
                let maxW = weights.max() ?? 100
                let range = maxW - minW
                // Add padding but ensure at least 1kg range for visual impact
                let padding = max(range * 0.3, 0.5)
                let yMin = minW - padding
                let yMax = maxW + padding

                Chart {
                    ForEach(logsForCurrentMonth.sorted(by: { $0.loggedAt < $1.loggedAt }), id: \.id) { log in
                        AreaMark(
                            x: .value("Tag", log.loggedAt),
                            y: .value("kg", log.weightKg)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.fireGold.opacity(0.4), Theme.fireGold.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        LineMark(
                            x: .value("Tag", log.loggedAt),
                            y: .value("kg", log.weightKg)
                        )
                        .foregroundStyle(Theme.fireGold)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Tag", log.loggedAt),
                            y: .value("kg", log.weightKg)
                        )
                        .foregroundStyle(Theme.fireGold)
                        .symbolSize(60)
                    }
                }
                .chartYScale(domain: yMin...yMax)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 100)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title3)
                        .foregroundColor(Theme.disabled)
                    Text("Mehr Daten benötigt")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 60)
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Theme.backgroundSecondary)
        .cornerRadius(12)
    }

    private var statsSection: some View {
        let monthLogs = logsForCurrentMonth
        let avgWeight = monthLogs.isEmpty ? nil : monthLogs.map(\.weightKg).reduce(0, +) / Double(monthLogs.count)
        let minWeight = monthLogs.map(\.weightKg).min()
        let maxWeight = monthLogs.map(\.weightKg).max()

        return HStack(spacing: 12) {
            statCard(
                title: "Maximum",
                value: maxWeight.map { String(format: "%.1f kg", $0) } ?? "--",
                icon: "arrow.up.circle.fill",
                color: Theme.warning
            )

            statCard(
                title: "Durchschnitt",
                value: avgWeight.map { String(format: "%.1f kg", $0) } ?? "--",
                icon: "equal.circle.fill",
                color: Theme.fireGold
            )

            statCard(
                title: "Minimum",
                value: minWeight.map { String(format: "%.1f kg", $0) } ?? "--",
                icon: "arrow.down.circle.fill",
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

    // MARK: - Data Loading

    private func loadWeightHistory() async {
        isLoading = true

        do {
            let logs = try await GRDBManager.shared.read { db in
                try WeightLog
                    .order(Column("logged_at").desc)
                    .fetchAll(db)
            }
            weightLogs = logs
        } catch {
            #if DEBUG
            print("Error loading weight history: \(error)")
            #endif
        }

        isLoading = false
    }
}

// MARK: - Preview

#Preview {
    WeightHistoryView()
}

// MARK: - Weight Entry Sheet

/// Sheet for entering weight for a specific date
struct WeightEntrySheet: View {
    @Environment(\.dismiss) private var dismiss

    let date: Date
    let existingWeight: Double?
    let onSave: () -> Void

    @State private var selectedWeightWhole: Int = 70
    @State private var selectedWeightDecimal: Int = 0
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d. MMMM yyyy"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: date)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gewicht für \(dateString)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)

                    if existingWeight != nil {
                        Text("Vorhandenen Eintrag bearbeiten")
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer()

                // Picker
                HStack(spacing: 0) {
                    Picker("Weight", selection: $selectedWeightWhole) {
                        ForEach(40...200, id: \.self) { weight in
                            Text("\(weight)")
                                .font(.system(size: 26, weight: .semibold))
                                .tag(weight)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100, height: 150)
                    .clipped()

                    Text(".")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)

                    Picker("Decimal", selection: $selectedWeightDecimal) {
                        ForEach(0...9, id: \.self) { decimal in
                            Text("\(decimal)")
                                .font(.system(size: 26, weight: .semibold))
                                .tag(decimal)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60, height: 150)
                    .clipped()

                    Text("kg")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                        .padding(.leading, 8)
                }

                Spacer()

                // Save Button
                Button {
                    Task {
                        await saveWeight()
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    } else {
                        Text("Speichern")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
                .background(Theme.fireGold)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 40)
                .disabled(isLoading)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
            .alert("Fehler", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
            .onAppear {
                if let weight = existingWeight {
                    selectedWeightWhole = Int(weight)
                    selectedWeightDecimal = Int((weight - Double(Int(weight))) * 10)
                }
            }
        }
    }

    private func saveWeight() async {
        isLoading = true
        defer { isLoading = false }

        do {
            guard let userId = AuthManager.shared.currentUserId else {
                errorMessage = "Nicht angemeldet"
                return
            }

            let weightKg = Double(selectedWeightWhole) + Double(selectedWeightDecimal) / 10.0

            // Set the time to noon on the selected date
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = 12
            let logDate = calendar.date(from: components) ?? date

            // Check if an entry already exists for this date
            let existingLog = try await GRDBManager.shared.read { db -> WeightLog? in
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

                return try WeightLog
                    .filter(Column("user_id") == userId)
                    .filter(Column("logged_at") >= startOfDay)
                    .filter(Column("logged_at") < endOfDay)
                    .fetchOne(db)
            }

            // Calculate 7-day average
            let average7Days = try await GRDBManager.shared.read { db in
                try WeightLog.calculateAverage(db, userId: userId, days: 7, referenceDate: date)
            }

            if let existing = existingLog {
                // Update existing entry
                try await GRDBManager.shared.write { db in
                    let updated = WeightLog(
                        id: existing.id,
                        userId: existing.userId,
                        weightKg: weightKg,
                        loggedAt: existing.loggedAt,
                        createdAt: existing.createdAt,
                        updatedAt: Date(),
                        syncedAt: nil,
                        averageWeight7Days: average7Days
                    )
                    try updated.update(db)
                }
            } else {
                // Create new entry
                let newLog = WeightLog(
                    userId: userId,
                    weightKg: weightKg,
                    loggedAt: logDate,
                    averageWeight7Days: average7Days
                )
                try await GRDBManager.shared.write { db in
                    try newLog.insert(db)
                }
            }

            dismiss()
            onSave()

        } catch {
            errorMessage = "Fehler beim Speichern: \(error.localizedDescription)"
        }
    }
}
