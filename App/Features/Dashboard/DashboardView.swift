//
//  DashboardView.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 04.01.26.
//

import GRDB
import SwiftUI

/// Main dashboard view showing cycle status and macro progress
struct DashboardView: View {
    // MARK: - State

    /// ViewModel - CRITICAL: Initialize directly, NOT in init()!
    @StateObject private var viewModel = DashboardViewModel()

    /// Currently selected tab
    @State private var selectedTab: Tab = .home

    /// Show weight logging sheet
    @State private var showWeightLogging = false

    /// Show add food sheet
    @State private var showAddFood = false

    /// Show camera directly for plate scanning
    @State private var showCamera = false

    /// Captured image from camera
    @State private var capturedImage: UIImage?

    /// Show analysis results after scanning
    @State private var showAnalysisResults = false

    /// Analysis result from Gemini
    @State private var analysisResult: FoodAnalysisResponse?

    /// Analysis in progress
    @State private var isAnalyzing = false

    /// Pre-filled data from plate scanner
    @State private var scannedFoodPrefill: ManualEntryPrefill?

    /// Show manual entry with pre-filled data from scan
    @State private var showScannedEntry = false

    /// Show weight history
    @State private var showWeightHistory = false


    // MARK: - Tab enum

    enum Tab {
        case home
        case logging
        case learning
        case community
        case settings
    }

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack {
                ScrollView {
                    VStack(spacing: 32) {
                        // Weight Reminder Card (top priority - shown daily until weight logged)
                        if viewModel.showWeightReminder {
                            weightReminderCard
                        }

                        // Weight Stats Card
                        if viewModel.currentWeight != nil {
                            weightStatsCard
                        }

                        // Macro Progress (Hero element - shows daily progress)
                        macroProgressSection
                            .padding(.top, 10)

                        // Cycle Status Card (MATADOR Calendar - secondary navigation)
                        cycleStatusCard
                    }
                    .padding()
                    .padding(.bottom, 70) // Space for fixed button
                }
                .safeAreaInset(edge: .bottom) {
                    AddFoodButtonBar(
                        onAddFood: { showAddFood = true },
                        onScanFood: { showCamera = true }
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 38)
                    .background(
                        Theme.backgroundPrimary
                            .ignoresSafeArea()
                    )
                }
                .navigationBarHidden(true)
                .task {
                    await viewModel.loadData()
                }
                .overlay {
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }
                .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil)) {
                    Button("OK") {
                        viewModel.errorMessage = nil
                    }
                } message: {
                    if let error = viewModel.errorMessage {
                        Text(error)
                    }
                }
            }
            .tabItem {
                Image(systemName: selectedTab == .home ? "house.fill" : "house")
            }
            .tag(Tab.home)

            // Mahlzeiten Tab (Meal History)
            NavigationStack {
                MealHistoryView()
            }
            .tabItem {
                Image(systemName: selectedTab == .logging ? "fork.knife.circle.fill" : "fork.knife.circle")
            }
            .tag(Tab.logging)

            // Learning Tab (Coming Soon)
            NavigationStack {
                ComingSoonView(
                    title: "Lernen",
                    icon: "book.fill",
                    description: "Tipps und Wissen rund um Ernährung und MATADOR"
                )
            }
            .tabItem {
                Image(systemName: selectedTab == .learning ? "book.fill" : "book")
            }
            .tag(Tab.learning)

            // Community Tab (Coming Soon)
            NavigationStack {
                ComingSoonView(
                    title: "Community",
                    icon: "bubble.left.and.bubble.right.fill",
                    description: "Tausche dich mit anderen aus"
                )
            }
            .tabItem {
                Image(systemName: selectedTab == .community ? "bubble.left.and.bubble.right.fill" : "bubble.left.and.bubble.right")
            }
            .tag(Tab.community)

            // Settings Tab
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image(systemName: selectedTab == .settings ? "gearshape.fill" : "gearshape")
            }
            .tag(Tab.settings)
        }
        .tint(Theme.fireGold)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(Theme.backgroundSecondary, for: .tabBar)
        .sheet(isPresented: $showWeightLogging) {
            WeightLoggingSheet(
                isPresented: $showWeightLogging,
                onWeightSaved: {
                    // Reload dashboard data after weight is saved
                    Task {
                        await viewModel.loadData()
                    }
                }
            )
        }
        .sheet(isPresented: $showAddFood) {
            FoodSearchView(onFoodAdded: {
                // Reload dashboard data after food is added
                Task {
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
                // Analyze the captured image
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
                            viewModel.errorMessage = "Analyse fehlgeschlagen: \(error.localizedDescription)"
                            #if DEBUG
                            print("Analysis error: \(error)")
                            #endif
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAnalysisResults, onDismiss: {
            // Clean up when results dismissed
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
                    // Save the meal
                    Task {
                        do {
                            try await GRDBManager.shared.write { db in
                                try meal.insert(db)
                            }
                            await viewModel.loadData()
                        } catch {
                            viewModel.errorMessage = "Speichern fehlgeschlagen: \(error.localizedDescription)"
                            #if DEBUG
                            print("Error saving scanned meal: \(error)")
                            #endif
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showWeightHistory) {
            WeightHistoryView()
        }
    }

    // MARK: - View Components

    private var weightReminderCard: some View {
        Button {
            showWeightLogging = true
        } label: {
            HStack(spacing: 16) {
                // Fire icon (matches MATADOR calendar)
                Image(systemName: "flame.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Theme.fireGold)
                    .frame(width: 40)

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text("Auf die Waage!")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Dein täglicher Check-in")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Theme.backgroundSecondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Theme.fireGold, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var cycleStatusCard: some View {
        VStack(spacing: 16) {
            // MATADOR Cycle Calendar
            MatadorCycleCalendar(currentDay: viewModel.currentDay, cycleStartDate: viewModel.cycleStartDate)

            // Status text below calendar
            if viewModel.currentDay == 0 {
                Text("Kein aktiver Zyklus")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Theme.backgroundSecondary)
        .cornerRadius(12)
    }

    private var weightStatsCard: some View {
        Button {
            showWeightHistory = true
        } label: {
            HeroHeaderView {
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
            } center: {
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
            } right: {
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
            }
        }
        .buttonStyle(.plain)
    }

    private var macroProgressSection: some View {
        MacroProgressView(
            caloriesConsumed: viewModel.caloriesConsumed,
            caloriesTarget: viewModel.caloriesTarget,
            proteinConsumed: viewModel.proteinConsumed,
            proteinTarget: viewModel.proteinTarget,
            carbsConsumed: viewModel.carbsConsumed,
            carbsTarget: viewModel.carbsTarget,
            fatConsumed: viewModel.fatConsumed,
            fatTarget: viewModel.fatTarget
        )
    }

}

// MARK: - Circular Macro Ring Component

struct CircularMacroRing: View {
    let proteinCalories: Double
    let carbsCalories: Double
    let fatCalories: Double
    let targetCalories: Double

    private var totalConsumed: Double {
        proteinCalories + carbsCalories + fatCalories
    }

    private var proteinPercentage: Double {
        guard targetCalories > 0 else { return 0 }
        return proteinCalories / targetCalories
    }

    private var carbsPercentage: Double {
        guard targetCalories > 0 else { return 0 }
        return carbsCalories / targetCalories
    }

    private var fatPercentage: Double {
        guard targetCalories > 0 else { return 0 }
        return fatCalories / targetCalories
    }

    private var remainingPercentage: Double {
        guard targetCalories > 0 else { return 0 }
        let remaining = max(0, targetCalories - totalConsumed)
        return remaining / targetCalories
    }

    var body: some View {
        ZStack {
            // Outer border for light mode visibility
            Circle()
                .stroke(Theme.lightModeBorder, lineWidth: 1)
                .padding(-10)  // Position at outer edge of ring

            // Background ring (full circle)
            Circle()
                .stroke(Theme.gray100, lineWidth: 20)

            // Inner border for light mode visibility
            Circle()
                .stroke(Theme.lightModeBorder, lineWidth: 1)
                .padding(10)  // Position at inner edge of ring

            // Protein segment
            Circle()
                .trim(from: 0, to: min(proteinPercentage, 1.0))
                .stroke(Theme.macroProtein, style: StrokeStyle(lineWidth: 20, lineCap: .butt))
                .rotationEffect(.degrees(-90))

            // Carbs segment
            Circle()
                .trim(from: 0, to: min(carbsPercentage, 1.0))
                .stroke(Theme.warning, style: StrokeStyle(lineWidth: 20, lineCap: .butt))
                .rotationEffect(.degrees(-90 + proteinPercentage * 360))

            // Fat segment
            Circle()
                .trim(from: 0, to: min(fatPercentage, 1.0))
                .stroke(Theme.macroFat, style: StrokeStyle(lineWidth: 20, lineCap: .butt))
                .rotationEffect(.degrees(-90 + (proteinPercentage + carbsPercentage) * 360))

            // Separator lines between segments
            // Line between Protein and Carbs
            if proteinPercentage > 0.01 && carbsPercentage > 0.01 {
                SeparatorLine(angle: -90 + proteinPercentage * 360)
            }

            // Line between Carbs and Fat
            if carbsPercentage > 0.01 && fatPercentage > 0.01 {
                SeparatorLine(angle: -90 + (proteinPercentage + carbsPercentage) * 360)
            }

            // Line between Fat and remaining/start (if fat exists)
            if fatPercentage > 0.01 && remainingPercentage > 0.01 {
                SeparatorLine(angle: -90 + (proteinPercentage + carbsPercentage + fatPercentage) * 360)
            }
        }
    }
}

// MARK: - Separator Line Component

struct SeparatorLine: View {
    let angle: Double

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2

            Path { path in
                let radians = angle * .pi / 180
                let innerRadius = radius - 12 // Inside the ring
                let outerRadius = radius + 12 // Outside the ring

                let innerPoint = CGPoint(
                    x: center.x + innerRadius * cos(radians),
                    y: center.y + innerRadius * sin(radians)
                )
                let outerPoint = CGPoint(
                    x: center.x + outerRadius * cos(radians),
                    y: center.y + outerRadius * sin(radians)
                )

                path.move(to: innerPoint)
                path.addLine(to: outerPoint)
            }
            .stroke(Color(UIColor.systemBackground), style: StrokeStyle(lineWidth: 2, lineCap: .round))
        }
    }
}

// MARK: - HeroHeaderView (shared layout component)

/// A header component with left-center-right layout that maintains consistent height
/// Used above the calorie ring on both Dashboard and MealHistory tabs
struct HeroHeaderView<Left: View, Center: View, Right: View>: View {
    let left: Left
    let center: Center
    let right: Right

    init(
        @ViewBuilder left: () -> Left,
        @ViewBuilder center: () -> Center,
        @ViewBuilder right: () -> Right
    ) {
        self.left = left()
        self.center = center()
        self.right = right()
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left section
            left
                .frame(maxWidth: .infinity, alignment: .leading)

            // Center section
            center

            // Right section
            right
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
}
