//
//  MealHistoryView.swift
//  w-diet
//
//  Daily meal history view with sequence-based meal emojis
//  Mirrors Dashboard layout for seamless tab switching
//

import SwiftUI
import GRDB

/// Groups meals logged within 30 minutes of each other (chaining logic)
struct MealGroup: Identifiable {
    let id: UUID
    let meals: [MealLog]
    let emoji: String

    /// First meal's name becomes the group name
    var name: String {
        meals.first?.mealName ?? "Mahlzeit"
    }

    /// Time of first meal in group
    var timeString: String {
        meals.first?.timeString ?? ""
    }

    /// Total calories for the group
    var totalCalories: Int {
        meals.reduce(0) { $0 + $1.caloriesKcal }
    }

    /// Total protein for the group
    var totalProtein: Double {
        meals.reduce(0) { $0 + $1.proteinG }
    }

    /// Total carbs for the group
    var totalCarbs: Double {
        meals.reduce(0) { $0 + $1.carbsG }
    }

    /// Total fat for the group
    var totalFat: Double {
        meals.reduce(0) { $0 + $1.fatG }
    }

    /// Time of first meal (for sorting)
    var sortTime: Date {
        meals.first?.loggedAt ?? Date()
    }
}

/// View showing today's meals with calorie/macro progress matching Dashboard layout
struct MealHistoryView: View {
    // MARK: - State

    /// Shared ViewModel for macro data - matches Dashboard exactly
    @StateObject private var viewModel = DashboardViewModel()

    @State private var meals: [MealLog] = []
    @State private var selectedGroup: MealGroup?
    @State private var selectedDate: Date = Date()
    @State private var isLoading = true
    @State private var showAddFood = false
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var showAnalysisResults = false
    @State private var analysisResult: FoodAnalysisResponse?
    @State private var isAnalyzing = false
    @State private var scannedFoodPrefill: ManualEntryPrefill?
    @State private var showScannedEntry = false

    private let calendar = Calendar.current
    private let authManager: AuthManager

    @MainActor init(authManager: AuthManager = .shared) {
        self.authManager = authManager
    }

    // MARK: - Constants

    /// Earliest date allowed for navigation (Jan 1, 2026)
    private var minDate: Date {
        calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)) ?? Date()
    }

    // MARK: - Computed

    /// Check if date is "Vorgestern" (day before yesterday)
    private var isVorgestern: Bool {
        guard let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date()) else { return false }
        return calendar.isDate(selectedDate, inSameDayAs: twoDaysAgo)
    }

    /// Whether we're showing a relative date (HEUTE/GESTERN/VORGESTERN)
    private var isRelativeDate: Bool {
        calendar.isDateInToday(selectedDate) || calendar.isDateInYesterday(selectedDate) || isVorgestern
    }

    /// Can navigate to previous day (not before Jan 1, 2026)
    private var canGoBack: Bool {
        guard let previousDay = calendar.date(byAdding: .day, value: -1, to: selectedDate) else { return false }
        return previousDay >= minDate
    }

    /// Label for relative dates (HEUTE/GESTERN/VORGESTERN) or nil for other dates
    private var relativeDateLabel: String? {
        if calendar.isDateInToday(selectedDate) {
            return "HEUTE"
        } else if calendar.isDateInYesterday(selectedDate) {
            return "GESTERN"
        } else if isVorgestern {
            return "VORGESTERN"
        }
        return nil
    }

    /// Full date string (always shown)
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d. MMM"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: selectedDate)
    }

    /// Groups meals within 30 minutes of each other (chaining logic)
    /// Each group gets an emoji based on: Late night (22-05) → 🌙, Snack (<300) → 🍌, Breakfast 🥐, Meals 🍲/🥗
    private var mealGroups: [MealGroup] {
        // Sort ascending first for grouping calculation
        let sortedMealsAsc = meals.sorted { $0.loggedAt < $1.loggedAt }

        guard !sortedMealsAsc.isEmpty else { return [] }

        // Group meals within 30 minutes of each other (chaining)
        var groups: [[MealLog]] = []
        var currentGroup: [MealLog] = [sortedMealsAsc[0]]

        for i in 1..<sortedMealsAsc.count {
            let previousMeal = currentGroup.last!
            let currentMeal = sortedMealsAsc[i]

            // Check if within 30 minutes of the previous meal in the group
            let timeDiff = currentMeal.loggedAt.timeIntervalSince(previousMeal.loggedAt)
            if timeDiff <= 30 * 60 { // 30 minutes in seconds
                currentGroup.append(currentMeal)
            } else {
                groups.append(currentGroup)
                currentGroup = [currentMeal]
            }
        }
        groups.append(currentGroup)

        // Assign emojis based on group's first meal characteristics
        var substantialGroupIndex = 0
        var result: [MealGroup] = []

        for group in groups {
            guard let firstMeal = group.first else { continue }

            let hour = calendar.component(.hour, from: firstMeal.loggedAt)
            let isLateNight = hour >= 22 || hour < 5
            let totalCalories = group.reduce(0) { $0 + $1.caloriesKcal }
            let isSnack = totalCalories < 300

            let emoji: String
            if isLateNight {
                emoji = "🌙"
            } else if isSnack {
                emoji = "🍌"
            } else {
                let isBreakfastWindow = hour >= 5 && hour < 12

                if substantialGroupIndex == 0 && isBreakfastWindow {
                    emoji = "🥐"
                } else if substantialGroupIndex == 0 {
                    emoji = "🍲"
                } else {
                    emoji = substantialGroupIndex % 2 == 1 ? "🥗" : "🍲"
                }
                substantialGroupIndex += 1
            }

            result.append(MealGroup(
                id: UUID(),
                meals: group,
                emoji: emoji
            ))
        }

        // Reverse for display: newest on top
        return result.reversed()
    }

    @State private var showCalendar = false
    @State private var showWeightHistory = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // ZStack: Invisible weight stats (maintains height) + Visible date nav
                ZStack {
                    // Invisible weight stats card - maintains exact same height as Dashboard
                    if viewModel.currentWeight != nil {
                        weightStatsCard
                            .opacity(0)
                            .allowsHitTesting(false)
                    }

                    // Visible date navigation overlay
                    dateNavigationOverlay
                }

                // Macro Progress Section - EXACT COPY from Dashboard
                macroProgressSection
                    .padding(.top, 10)

                // Meal list (replaces MATADOR calendar)
                if meals.isEmpty {
                    emptyStateView
                } else {
                    mealsList
                }
            }
            .padding()
            .padding(.bottom, 70) // Space for fixed buttons
        }
        .safeAreaInset(edge: .bottom) {
            // Fixed Add Food Buttons - EXACT COPY from Dashboard
            HStack(spacing: 12) {
                // Left: Add Food manually
                Button {
                    showAddFood = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Essen hinzufügen")
                            .font(.subheadline).fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.fireGold.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Theme.lightModeBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                // Right: Scan Food with AI
                Button {
                    showCamera = true
                } label: {
                    HStack {
                        Image(systemName: "camera.viewfinder")
                        Text("Teller scannen")
                            .font(.subheadline).fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.fireGold.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Theme.lightModeBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.bottom, 38)
            .background(
                Theme.backgroundPrimary
                    .ignoresSafeArea()
            )
        }
        .navigationBarHidden(true)
        .task {
            await loadData()
        }
        .sheet(isPresented: $showCalendar) {
            MealCalendarView(
                selectedDate: $selectedDate,
                onDateSelected: {
                    Task {
                        await loadMeals()
                    }
                }
            )
        }
        .sheet(isPresented: $showWeightHistory) {
            WeightHistoryView()
        }
        .sheet(isPresented: $showAddFood) {
            FoodSearchView(onFoodAdded: {
                Task {
                    await loadMeals()
                    await viewModel.loadData()
                }
            })
        }
        .sheet(isPresented: $showCamera) {
            CameraView(image: $capturedImage)
                .ignoresSafeArea()
        }
        .onChange(of: capturedImage) { _, newImage in
            if let image = newImage {
                isAnalyzing = true
                showAnalysisResults = true
                Task {
                    do {
                        let result = try await GeminiService.shared.analyzeFood(image: image)
                        await MainActor.run {
                            analysisResult = result
                            isAnalyzing = false
                        }
                    } catch {
                        await MainActor.run {
                            isAnalyzing = false
                            showAnalysisResults = false
                            capturedImage = nil
                            print("Analysis error: \(error)")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAnalysisResults, onDismiss: {
            capturedImage = nil
            analysisResult = nil
        }) {
            PlateAnalysisResultsView(
                image: capturedImage,
                result: analysisResult,
                isAnalyzing: isAnalyzing
            ) { scannedItem in
                scannedFoodPrefill = ManualEntryPrefill(from: scannedItem)
                showAnalysisResults = false
                showScannedEntry = true
            }
        }
        .sheet(isPresented: $showScannedEntry) {
            if let prefill = scannedFoodPrefill {
                ManualEntryView(prefill: prefill) { meal in
                    Task {
                        do {
                            try await GRDBManager.shared.write { db in
                                try meal.insert(db)
                            }
                            await loadMeals()
                            await viewModel.loadData()
                        } catch {
                            print("Error saving scanned meal: \(error)")
                        }
                    }
                }
            }
        }
        .onChange(of: selectedDate) { _, _ in
            Task {
                await loadMeals()
            }
        }
        .sheet(item: $selectedGroup) { group in
            MealGroupDetailView(
                meals: group.meals,
                emoji: group.emoji,
                onDataChanged: {
                    await loadMeals()
                    await viewModel.loadData()
                }
            )
            .presentationDetents([.large])
        }
    }

    // MARK: - Macro Progress Section (EXACT COPY from Dashboard)

    private var macroProgressSection: some View {
        VStack(spacing: 35) {
            // Circular Progress Ring
            ZStack {
                // Center text
                VStack(spacing: 4) {
                    Text(viewModel.caloriesConsumed, format: .number.grouping(.never))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(viewModel.caloriesConsumed > 0 ? Theme.fireGold : Theme.gray400)
                    Text("/ \(viewModel.caloriesTarget.formatted(.number.grouping(.never)))")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Circular ring
                CircularMacroRing(
                    proteinCalories: viewModel.proteinConsumed * 4, // 4 kcal per gram
                    carbsCalories: viewModel.carbsConsumed * 4, // 4 kcal per gram
                    fatCalories: viewModel.fatConsumed * 9, // 9 kcal per gram
                    targetCalories: Double(viewModel.caloriesTarget)
                )
                .frame(width: 200, height: 200)
            }

            // Three macros side by side
            HStack(spacing: 16) {
                macroColumn(
                    title: "Eiweiß",
                    consumed: viewModel.proteinConsumed,
                    target: viewModel.proteinTarget,
                    color: Theme.macroProtein
                )

                macroColumn(
                    title: "Kohlenhydrate",
                    consumed: viewModel.carbsConsumed,
                    target: viewModel.carbsTarget,
                    color: Theme.warning
                )

                macroColumn(
                    title: "Fett",
                    consumed: viewModel.fatConsumed,
                    target: viewModel.fatTarget,
                    color: Theme.macroFat
                )
            }
        }
    }

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

    // MARK: - Weight Stats Card (EXACT COPY from Dashboard)

    private var weightStatsCard: some View {
        Button {
            showWeightHistory = true
        } label: {
            HStack(spacing: 0) {
                // Left: 7-Day Average + Trend (PRIMARY)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(Theme.fireGold)
                        Text("Ø 7 Tage")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 6) {
                        if let avg = viewModel.averageWeight7Days {
                            Text("\(avg, specifier: "%.1f") kg")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        } else {
                            Text("--")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                        }

                        Image(systemName: viewModel.weightTrend.icon)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(viewModel.weightTrend.color)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Center: Streak Indicator
                VStack(spacing: 2) {
                    Text("\(viewModel.streakDays)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.todayHasActivity ? Theme.fireGold : Theme.disabled)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundColor(viewModel.todayHasActivity ? Theme.fireGold : Theme.disabled)
                }

                // Right: Current Weight + Chevron (SECONDARY)
                HStack(spacing: 8) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Heute")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let weight = viewModel.currentWeight {
                            Text("\(weight, specifier: "%.1f") kg")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        } else {
                            Text("--")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Date Navigation Overlay (sits on top of invisible weight stats)

    private var dateNavigationOverlay: some View {
        HStack {
            // Previous day button (limited to Jan 1, 2026)
            Button {
                selectedDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(canGoBack ? Theme.fireGold : Theme.disabled)
            }
            .disabled(!canGoBack)

            Spacer()

            // Center: Date text (truly centered) with calendar icon next to it
            Button {
                showCalendar = true
            } label: {
                VStack(spacing: 2) {
                    // Show HEUTE/GESTERN/VORGESTERN label if applicable
                    if let label = relativeDateLabel {
                        Text(label)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.textSecondary)
                    }
                    // Always show the date
                    Text(dateString)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .overlay(alignment: .trailing) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(Theme.fireGold)
                        .offset(x: 20)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            // Right: Next day button (hidden if today)
            if !calendar.isDateInToday(selectedDate) {
                Button {
                    selectedDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(Theme.fireGold)
                }
            } else {
                // Invisible placeholder to maintain layout
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.clear)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Components

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 48))
                .foregroundColor(Theme.disabled)

            Text("Noch keine Mahlzeiten")
                .font(.headline)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var mealsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(mealGroups) { group in
                mealGroupRow(group: group)
                    .background(Theme.backgroundSecondary)
                    .cornerRadius(12)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedGroup = group
                    }
            }
        }
    }

    private func mealGroupRow(group: MealGroup) -> some View {
        HStack(spacing: 12) {
            // Emoji + Time
            VStack(spacing: 2) {
                Text(group.emoji)
                    .font(.title2)
                Text(group.timeString)
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)
            }
            .frame(width: 44)

            // Meal info
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text("\(Int(group.totalProtein))g P • \(Int(group.totalCarbs))g K • \(Int(group.totalFat))g F")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            // Calories
            Text("\(group.totalCalories) kcal")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Theme.fireGold)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Theme.disabled)
        }
        .padding()
    }

    // MARK: - Data Loading

    private func loadData() async {
        await viewModel.loadData()
        await loadMeals()
    }

    private func loadMeals() async {
        isLoading = true

        guard let userId = authManager.currentUserId else {
            isLoading = false
            return
        }

        do {
            let loadedMeals = try await GRDBManager.shared.read { db in
                try MealLog.fetchForDate(db, userId: userId, date: selectedDate)
            }
            meals = loadedMeals
        } catch {
            print("Error loading meals: \(error)")
        }

        isLoading = false
    }

    // MARK: - Delete Functions

    /// Delete a single meal from the database by ID
    private func deleteMealById(_ mealId: Int64) async {
        print("🗑️ deleteMealById called with ID: \(mealId)")
        do {
            try await GRDBManager.shared.write { db in
                let deleteCount = try MealLog
                    .filter(Column("id") == mealId)
                    .deleteAll(db)
                print("✅ DB delete completed, rows deleted: \(deleteCount)")
            }
            print("🔄 Reloading data...")
            await loadMeals()
            await viewModel.loadData()
            print("✅ Data reloaded")
        } catch {
            print("❌ Error deleting meal: \(error)")
        }
    }

    /// Delete all meals in a group
    private func deleteGroup(_ group: MealGroup) async {
        do {
            try await GRDBManager.shared.write { db in
                for meal in group.meals {
                    if let mealId = meal.id {
                        _ = try MealLog
                            .filter(Column("id") == mealId)
                            .deleteAll(db)
                    }
                }
            }
            await loadMeals()
            await viewModel.loadData()
        } catch {
            print("Error deleting group: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MealHistoryView()
    }
}

// MARK: - MealGroupDetailView

/// Detail view for editing a meal group - delete items
struct MealGroupDetailView: View {
    let initialMeals: [MealLog]
    let emoji: String
    let onDataChanged: () async -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showDeleteAllConfirmation = false
    @State private var meals: [MealLog] = []

    // Add food states
    @State private var showAddFood = false
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var showAnalysisResults = false
    @State private var analysisResult: FoodAnalysisResponse?
    @State private var isAnalyzing = false
    @State private var scannedFoodPrefill: ManualEntryPrefill?
    @State private var showScannedEntry = false

    init(meals: [MealLog], emoji: String, onDataChanged: @escaping () async -> Void) {
        self.initialMeals = meals
        self.emoji = emoji
        self.onDataChanged = onDataChanged
    }

    /// Target date for new meals (uses first meal's loggedAt to group together)
    private var targetDate: Date {
        initialMeals.first?.loggedAt ?? Date()
    }

    // Direct database delete - no closure needed
    private func deleteMealFromDB(_ mealId: Int64) async {
        do {
            try await GRDBManager.shared.write { db in
                _ = try MealLog
                    .filter(Column("id") == mealId)
                    .deleteAll(db)
            }
            await onDataChanged()
        } catch {
            print("❌ Error deleting meal: \(error)")
        }
    }

    private func deleteAllMealsFromDB() async {
        do {
            try await GRDBManager.shared.write { db in
                for meal in initialMeals {
                    if let mealId = meal.id {
                        _ = try MealLog
                            .filter(Column("id") == mealId)
                            .deleteAll(db)
                    }
                }
            }
            await onDataChanged()
        } catch {
            print("❌ Error deleting meals: \(error)")
        }
    }

    private var groupName: String {
        meals.first?.mealName ?? "Mahlzeit"
    }

    private var totalCalories: Int {
        meals.reduce(0) { $0 + $1.caloriesKcal }
    }

    private var totalProtein: Double {
        meals.reduce(0) { $0 + $1.proteinG }
    }

    private var totalCarbs: Double {
        meals.reduce(0) { $0 + $1.carbsG }
    }

    private var totalFat: Double {
        meals.reduce(0) { $0 + $1.fatG }
    }

    private var timeRange: String {
        guard let first = meals.first, let last = meals.last else { return "" }
        if meals.count == 1 {
            return first.timeString
        }
        return "\(first.timeString) - \(last.timeString)"
    }

    @ViewBuilder
    private func mealItemRow(_ meal: MealLog) -> some View {
        let mealId = meal.id
        HStack(spacing: 8) {
            // Item info card - takes remaining space
            HStack {
                Text(meal.mealName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(meal.caloriesKcal) kcal")
                        .font(.subheadline)
                        .foregroundColor(Theme.fireGold)

                    Text("\(Int(meal.proteinG))g P • \(Int(meal.carbsG))g K • \(Int(meal.fatG))g F")
                        .font(.caption2)
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Theme.backgroundSecondary)
            .cornerRadius(10)

            // Delete button (separate from card)
            Button {
                guard let id = mealId else { return }
                withAnimation {
                    meals.removeAll { $0.id == id }
                }
                Task {
                    await deleteMealFromDB(id)
                }
                if meals.isEmpty {
                    dismiss()
                }
            } label: {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundColor(Theme.error)
                    .padding(10)
                    .background(Theme.error.opacity(0.1))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // FIXED HEADER: Summary + Macros
                VStack(spacing: 8) {
                    // Summary row
                    GeometryReader { geometry in
                        HStack {
                            Text(emoji)
                                .font(.largeTitle)
                            Text(groupName)
                                .font(.headline)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Spacer()
                            Text("\(totalCalories) kcal")
                                .font(.headline)
                                .foregroundColor(Theme.fireGold)
                                .layoutPriority(1)
                        }
                        .frame(width: geometry.size.width * 0.8)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(height: 40)

                    // Macro bars
                    HStack(spacing: 16) {
                        mealMacroBar(title: "Eiweiß", value: totalProtein, target: viewModel.proteinTarget, color: Theme.macroProtein)
                        mealMacroBar(title: "Kohlenhydrate", value: totalCarbs, target: viewModel.carbsTarget, color: Theme.warning)
                        mealMacroBar(title: "Fett", value: totalFat, target: viewModel.fatTarget, color: Theme.macroFat)
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 32)

                // SCROLLABLE ITEMS LIST (fixed height for ~5 items)
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(meals, id: \.id) { meal in
                            mealItemRow(meal)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 280) // ~5 items at ~56px each

                // FIXED BOTTOM: Delete all + Action buttons
                VStack(spacing: 55) {
                    // Delete all button
                    if initialMeals.count > 1 {
                        Button(role: .destructive) {
                            showDeleteAllConfirmation = true
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "trash")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.error)
                                Spacer()
                            }
                            .padding(.vertical, 12)
                            .background(Theme.error.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }

                    // Add food buttons
                    HStack(spacing: 12) {
                        Button {
                            showAddFood = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Essen hinzufügen")
                                    .font(.subheadline).fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Theme.fireGold.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Theme.lightModeBorder, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            showCamera = true
                        } label: {
                            HStack {
                                Image(systemName: "camera.viewfinder")
                                Text("Teller scannen")
                                    .font(.subheadline).fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Theme.fireGold.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Theme.lightModeBorder, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 40)
                .padding(.bottom, 20)

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(Theme.fireGold)
                    }
                }
            }
            .alert("Alle Einträge löschen?", isPresented: $showDeleteAllConfirmation) {
                Button("Abbrechen", role: .cancel) {}
                Button("Alle löschen", role: .destructive) {
                    Task {
                        await deleteAllMealsFromDB()
                        dismiss()
                    }
                }
            } message: {
                Text("Alle \(meals.count) Einträge in dieser Mahlzeit werden gelöscht.")
            }
            .sheet(isPresented: $showAddFood) {
                FoodSearchView(onFoodAdded: {
                    Task {
                        await onDataChanged()
                        // Reload local meals list
                        do {
                            let userId = AuthManager.shared.currentUserId ?? ""
                            let reloaded = try await GRDBManager.shared.read { db in
                                try MealLog.fetchForDate(db, userId: userId, date: targetDate)
                            }
                            // Filter to meals within 30 min of our target
                            meals = reloaded.filter { meal in
                                abs(meal.loggedAt.timeIntervalSince(targetDate)) <= 30 * 60
                            }
                        } catch {
                            print("Error reloading meals: \(error)")
                        }
                    }
                }, targetDate: targetDate)
            }
            .sheet(isPresented: $showCamera) {
                CameraView(image: $capturedImage)
                    .ignoresSafeArea()
            }
            .onChange(of: capturedImage) { _, newImage in
                if let image = newImage {
                    isAnalyzing = true
                    showAnalysisResults = true
                    Task {
                        do {
                            let result = try await GeminiService.shared.analyzeFood(image: image)
                            await MainActor.run {
                                analysisResult = result
                                isAnalyzing = false
                            }
                        } catch {
                            await MainActor.run {
                                isAnalyzing = false
                                showAnalysisResults = false
                                capturedImage = nil
                                print("Analysis error: \(error)")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showAnalysisResults, onDismiss: {
                capturedImage = nil
                analysisResult = nil
            }) {
                PlateAnalysisResultsView(
                    image: capturedImage,
                    result: analysisResult,
                    isAnalyzing: isAnalyzing
                ) { scannedItem in
                    scannedFoodPrefill = ManualEntryPrefill(from: scannedItem)
                    showAnalysisResults = false
                    showScannedEntry = true
                }
            }
            .sheet(isPresented: $showScannedEntry) {
                if let prefill = scannedFoodPrefill {
                    ManualEntryView(prefill: prefill, targetDate: targetDate) { meal in
                        Task { @MainActor in
                            do {
                                try await GRDBManager.shared.write { db in
                                    try meal.insert(db)
                                }
                                await onDataChanged()
                                // Reload local meals list
                                let userId = AuthManager.shared.currentUserId ?? ""
                                let reloaded = try await GRDBManager.shared.read { db in
                                    try MealLog.fetchForDate(db, userId: userId, date: targetDate)
                                }
                                meals = reloaded.filter { meal in
                                    abs(meal.loggedAt.timeIntervalSince(targetDate)) <= 30 * 60
                                }
                            } catch {
                                print("Error saving scanned meal: \(error)")
                            }
                        }
                    }
                }
            }
            .onAppear {
                meals = initialMeals
            }
            .task {
                await viewModel.loadData()
            }
        }
    }

    private func macroLabel(value: Double, label: String, unit: String) -> some View {
        VStack(spacing: 2) {
            Text("\(Int(value))\(unit)")
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func mealMacroBar(title: String, value: Double, target: Double, color: Color) -> some View {
        let progress = target > 0 ? min(value / target, 1.0) : 0

        return VStack(spacing: 8) {
            // Title
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            // Value
            Text("\(Int(value))g")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Progress bar (fills based on daily target)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.gray100)
                        .frame(height: 6)

                    // Fill based on progress toward daily target
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 6)

                    // Border
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
