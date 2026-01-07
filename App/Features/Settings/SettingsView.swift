//
//  SettingsView.swift
//  w-diet
//
//  Settings screen with profile editing and reset options
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showResetAlert = false

    // Individual edit sheets
    @State private var showEditHeight = false
    @State private var showEditWeight = false
    @State private var showEditActivity = false
    @State private var showEditEatingWindow = false

    /// Dark mode preference stored in UserDefaults
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        List {
            // MARK: - Profile Section
            Section {
                if let profile = viewModel.profile {
                    // Height
                    Button {
                        showEditHeight = true
                    } label: {
                        HStack {
                            Label("Größe", systemImage: "ruler")
                            Spacer()
                            Text(profile.heightCm != nil ? String(format: "%.2f m", profile.heightCm! / 100.0) : "--")
                                .foregroundStyle(.secondary)
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(Theme.fireGold)
                        }
                    }
                    .buttonStyle(.plain)

                    // Weight
                    Button {
                        showEditWeight = true
                    } label: {
                        HStack {
                            Label("Gewicht", systemImage: "scalemass")
                            Spacer()
                            Text(profile.weightKg != nil ? "\(profile.weightKg!, specifier: "%.1f") kg" : "--")
                                .foregroundStyle(.secondary)
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(Theme.fireGold)
                        }
                    }
                    .buttonStyle(.plain)

                    // Activity Level
                    Button {
                        showEditActivity = true
                    } label: {
                        HStack {
                            Label("Aktivität", systemImage: "figure.run")
                            Spacer()
                            Text(viewModel.activityLevelDisplayName)
                                .foregroundStyle(.secondary)
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(Theme.fireGold)
                        }
                    }
                    .buttonStyle(.plain)

                    // Eating Window
                    Button {
                        showEditEatingWindow = true
                    } label: {
                        HStack {
                            Label("Essensfenster", systemImage: "clock")
                            Spacer()
                            if let start = profile.eatingWindowStart, let end = profile.eatingWindowEnd {
                                Text("\(start) - \(end)")
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("--")
                                    .foregroundStyle(.secondary)
                            }
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(Theme.fireGold)
                        }
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("Profil")
            }

            // MARK: - Appearance Section
            Section {
                Toggle(isOn: $isDarkMode) {
                    Label("Dark Mode", systemImage: isDarkMode ? "moon.fill" : "moon")
                }
                .tint(Theme.fireGold)
            } header: {
                Text("Darstellung")
            }

            // MARK: - App Section
            Section {
                // App Version
                HStack {
                    Label("Version", systemImage: "info.circle")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("App")
            }

            // MARK: - Danger Zone
            Section {
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Label("Profil zurücksetzen", systemImage: "arrow.counterclockwise")
                }
            } header: {
                Text("Gefahrenzone")
            } footer: {
                Text("Setzt dein Profil zurück und startet das Onboarding neu. Deine Gewichtsdaten bleiben erhalten.")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                EmptyView()
            }
        }
        .task {
            await viewModel.loadProfile()
        }
        .alert("Profil zurücksetzen?", isPresented: $showResetAlert) {
            Button("Abbrechen", role: .cancel) {}
            Button("Zurücksetzen", role: .destructive) {
                Task {
                    await viewModel.resetProfile()
                }
            }
        } message: {
            Text("Dein Profil wird zurückgesetzt und du musst das Onboarding erneut durchlaufen.")
        }
        // Individual edit sheets
        .sheet(isPresented: $showEditHeight) {
            EditHeightSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showEditWeight) {
            EditWeightSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showEditActivity) {
            EditActivitySheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showEditEatingWindow) {
            EditEatingWindowSheet(viewModel: viewModel)
        }
    }
}

// MARK: - Edit Height Sheet

struct EditHeightSheet: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedHeightCm: Int = 170

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Picker("Height", selection: $selectedHeightCm) {
                    ForEach(100...220, id: \.self) { heightCm in
                        let meters = Double(heightCm) / 100.0
                        Text(String(format: "%.2f m", meters))
                            .tag(heightCm)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                Spacer()
            }
            .navigationTitle("Größe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        viewModel.editHeight = Double(selectedHeightCm)
                        Task {
                            await viewModel.saveProfile()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                selectedHeightCm = Int(viewModel.editHeight)
                if selectedHeightCm < 100 { selectedHeightCm = 100 }
                if selectedHeightCm > 220 { selectedHeightCm = 220 }
            }
        }
        .presentationDetents([.fraction(0.35)])
    }
}

// MARK: - Edit Weight Sheet

struct EditWeightSheet: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedWeightWhole: Int = 70
    @State private var selectedWeightDecimal: Int = 0

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    Picker("Weight", selection: $selectedWeightWhole) {
                        ForEach(40...200, id: \.self) { weight in
                            Text("\(weight)").tag(weight)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 150)
                    .clipped()

                    Text(".")
                        .font(.title)
                        .fontWeight(.semibold)

                    Picker("Decimal", selection: $selectedWeightDecimal) {
                        ForEach(0...9, id: \.self) { decimal in
                            Text("\(decimal)").tag(decimal)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60, height: 150)
                    .clipped()

                    Text("kg")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding(.leading, 8)
                }
                Spacer()
            }
            .navigationTitle("Gewicht")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        viewModel.editWeight = Double(selectedWeightWhole) + Double(selectedWeightDecimal) / 10.0
                        Task {
                            await viewModel.saveProfile()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                selectedWeightWhole = Int(viewModel.editWeight)
                selectedWeightDecimal = Int((viewModel.editWeight - Double(Int(viewModel.editWeight))) * 10)
                if selectedWeightWhole < 40 { selectedWeightWhole = 40 }
                if selectedWeightWhole > 200 { selectedWeightWhole = 200 }
            }
        }
        .presentationDetents([.fraction(0.35)])
    }
}

// MARK: - Edit Activity Sheet

struct EditActivitySheet: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedActivity: String = "moderately_active"

    var body: some View {
        NavigationStack {
            List {
                ForEach(SettingsViewModel.activityLevels, id: \.0) { level in
                    Button {
                        selectedActivity = level.0
                    } label: {
                        HStack {
                            Text(level.1)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedActivity == level.0 {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Theme.fireGold)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Aktivitätslevel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        viewModel.editActivityLevel = selectedActivity
                        Task {
                            await viewModel.saveProfile()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                selectedActivity = viewModel.editActivityLevel
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Edit Eating Window Sheet

struct EditEatingWindowSheet: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStartHour: Int = 12

    private var selectedEndHour: Int {
        (selectedStartHour + 6) % 24
    }

    private var formattedTimeRange: String {
        "\(String(format: "%02d:00", selectedStartHour)) - \(String(format: "%02d:00", selectedEndHour))"
    }

    private var isRecommendedTime: Bool {
        selectedStartHour >= 11 && selectedStartHour <= 13
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Time display
                Text(formattedTimeRange)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(isRecommendedTime ? Theme.fireGold : .primary)
                    .padding(.top)

                // Recommended badge
                if isRecommendedTime {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Empfohlene Zeit")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.fireGold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Theme.fireGold.opacity(0.15))
                    .cornerRadius(16)
                }

                Picker("Start", selection: $selectedStartHour) {
                    ForEach(0..<24, id: \.self) { hour in
                        let isRecommended = hour >= 11 && hour <= 13
                        Text(String(format: "%02d:00", hour))
                            .foregroundColor(isRecommended ? Theme.fireGold : .primary)
                            .tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)

                Spacer()
            }
            .padding()
            .navigationTitle("Essensfenster")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        viewModel.editEatingWindowStart = String(format: "%02d:00", selectedStartHour)
                        viewModel.editEatingWindowEnd = String(format: "%02d:00", selectedEndHour)
                        Task {
                            await viewModel.saveProfile()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                if let startStr = viewModel.editEatingWindowStart.split(separator: ":").first,
                   let startHour = Int(startStr) {
                    selectedStartHour = startHour
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
