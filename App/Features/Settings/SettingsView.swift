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
    @State private var showDeleteAlert = false
    @State private var showExportSheet = false
    @State private var exportFileURL: URL?
    @State private var showDatenschutz = false
    @State private var showResetCycleAlert = false

    // Individual edit sheets
    @State private var showEditGoal = false
    @State private var showEditGender = false
    @State private var showEditHeight = false
    @State private var showEditWeight = false
    @State private var showEditActivity = false
    @State private var showEditEatingWindow = false

    /// Dark mode preference
    @AppStorage("isDarkMode") private var isDarkMode = true

    var body: some View {
        List {
            // MARK: - Profile Section
            Section {
                if let profile = viewModel.profile {
                    // Goal
                    Button {
                        showEditGoal = true
                    } label: {
                        HStack {
                            Label("Ziel", systemImage: "flame.fill")
                            Spacer()
                            Text(goalDisplayName(profile.goal))
                                .foregroundStyle(.secondary)
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(Theme.fireGold)
                        }
                    }
                    .buttonStyle(.plain)

                    // Gender
                    Button {
                        showEditGender = true
                    } label: {
                        HStack {
                            Label("Geschlecht", systemImage: "person.fill")
                            Spacer()
                            Text(profile.gender == "female" ? "Weiblich" : "Männlich")
                                .foregroundStyle(.secondary)
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(Theme.fireGold)
                        }
                    }
                    .buttonStyle(.plain)

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
                }
            } header: {
                Text("Profil")
            }

            // MARK: - Abnehmen Section (only for lose_weight goal)
            if viewModel.profile?.goal == "lose_weight" {
                Section {
                    // Reset MATADOR Cycle
                    Button {
                        showResetCycleAlert = true
                    } label: {
                        Label("MATADOR Zyklus neu starten", systemImage: "arrow.counterclockwise.circle")
                    }
                    .buttonStyle(.plain)

                    // Eating Window
                    Button {
                        showEditEatingWindow = true
                    } label: {
                        HStack {
                            Label("Essensfenster", systemImage: "clock")
                            Spacer()
                            if let profile = viewModel.profile,
                               let start = profile.eatingWindowStart,
                               let end = profile.eatingWindowEnd {
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
                } header: {
                    Text("Abnehmen")
                }
            }

            // MARK: - Appearance Section
            Section {
                Toggle(isOn: $isDarkMode) {
                    Label("Dark Mode", systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
                }
                .tint(Theme.fireGold)
            } header: {
                Text("Darstellung")
            }

            // MARK: - GDPR / Datenschutz Section
            Section {
                // Privacy Policy
                Button {
                    showDatenschutz = true
                } label: {
                    Label("Datenschutzerklärung", systemImage: "doc.text")
                }
                .buttonStyle(.plain)

                // Export Data
                Button {
                    Task {
                        if let url = await viewModel.exportUserData() {
                            exportFileURL = url
                            showExportSheet = true
                        }
                    }
                } label: {
                    Label("Daten exportieren", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
            } header: {
                Text("Datenschutz")
            }

            // MARK: - Language Section (Coming Soon)
            Section {
                HStack {
                    Label("Sprache", systemImage: "globe")
                        .foregroundColor(Theme.disabled)
                    Spacer()
                    Text("Deutsch")
                        .foregroundStyle(Theme.disabled)
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(Theme.disabled)
                }
            } header: {
                Text("Sprache")
            }

            // MARK: - Danger Zone
            Section {
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Label("Profil zurücksetzen", systemImage: "arrow.counterclockwise")
                }

                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("Konto löschen", systemImage: "trash")
                }
            } header: {
                Text("Gefahrenzone")
            }

            // MARK: - App Section (Version - always last)
            Section {
                HStack {
                    Label("Version", systemImage: "info.circle")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("App")
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
        .alert("Konto löschen?", isPresented: $showDeleteAlert) {
            Button("Abbrechen", role: .cancel) {}
            Button("Löschen", role: .destructive) {
                Task {
                    await viewModel.deleteAccount()
                }
            }
        } message: {
            Text("Alle deine Daten werden unwiderruflich gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.")
        }
        .alert("Zyklus neu starten?", isPresented: $showResetCycleAlert) {
            Button("Abbrechen", role: .cancel) {}
            Button("Neu starten", role: .destructive) {
                Task {
                    await viewModel.resetCycle()
                }
            }
        } message: {
            Text("Der MATADOR-Zyklus wird auf Tag 1 (Diätphase) zurückgesetzt.")
        }
        .sheet(isPresented: $showExportSheet) {
            if let url = exportFileURL {
                ShareSheet(activityItems: [url])
            }
        }
        // Individual edit sheets
        .sheet(isPresented: $showEditGoal) {
            EditGoalSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showEditGender) {
            EditGenderSheet(viewModel: viewModel)
        }
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
        .sheet(isPresented: $showDatenschutz) {
            DatenschutzView()
        }
    }

    // MARK: - Helper Functions

    private func goalDisplayName(_ goal: String?) -> String {
        switch goal {
        case "lose_weight": return "Abnehmen"
        case "maintain_weight": return "Gewicht halten"
        case "gain_muscle": return "Muskeln aufbauen"
        default: return "Abnehmen"
        }
    }
}

// MARK: - Edit Goal Sheet

struct EditGoalSheet: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGoal: String = "lose_weight"

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                // Goal Cards
                goalCard(
                    goal: "lose_weight",
                    title: "Abnehmen",
                    icon: "flame.fill",
                    isEnabled: true
                )

                goalCard(
                    goal: "maintain_weight",
                    title: "Gewicht halten",
                    icon: "scalemass.fill",
                    isEnabled: false
                )

                goalCard(
                    goal: "gain_muscle",
                    title: "Muskeln aufbauen",
                    icon: "dumbbell.fill",
                    isEnabled: false
                )

                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationTitle("Ziel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        viewModel.editGoal = selectedGoal
                        Task {
                            await viewModel.saveProfile()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                selectedGoal = viewModel.editGoal
            }
        }
        .presentationDetents([.fraction(0.5)])
    }

    private func goalCard(goal: String, title: String, icon: String, isEnabled: Bool) -> some View {
        let isSelected = selectedGoal == goal && isEnabled

        return Button(action: {
            if isEnabled {
                selectedGoal = goal
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(isEnabled ? (isSelected ? .white : Theme.fireGold) : Theme.disabled)
                    .frame(width: 40)

                Text(title)
                    .font(.headline)
                    .foregroundColor(isEnabled ? (isSelected ? .white : .primary) : Theme.disabled)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(isSelected ? Theme.fireGold : Theme.backgroundSecondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.clear : Theme.gray300, lineWidth: 1)
            )
            .overlay(alignment: .topTrailing) {
                if !isEnabled {
                    Text("Soon")
                        .font(.system(size: 11))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.fireGold)
                        .cornerRadius(6)
                        .offset(x: 8, y: -8)
                }
            }
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Edit Gender Sheet

struct EditGenderSheet: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGender: String = "male"

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Gender Cards - Side by Side
                HStack(spacing: 16) {
                    genderCard(gender: "male", icon: "♂")
                    genderCard(gender: "female", icon: "♀")
                }
                .padding(.horizontal, 32)

                Spacer()
                Spacer()
            }
            .navigationTitle("Geschlecht")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        viewModel.editGender = selectedGender
                        Task {
                            await viewModel.saveProfile()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                selectedGender = viewModel.editGender
            }
        }
        .presentationDetents([.fraction(0.4)])
    }

    private func genderCard(gender: String, icon: String) -> some View {
        let isSelected = selectedGender == gender

        return Button(action: {
            selectedGender = gender
        }) {
            ZStack {
                // Icon
                Text(icon)
                    .font(.system(size: 44))
                    .foregroundColor(isSelected ? .white : Theme.fireGold)

                // Checkmark overlay
                if isSelected {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(12)
                }
            }
            .frame(width: 120, height: 120)
            .background(isSelected ? Theme.fireGold : Theme.backgroundSecondary)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected ? Color.clear : Theme.gray300, lineWidth: 1)
            )
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
                ForEach(SettingsViewModel.activityLevels, id: \.key) { level in
                    Button {
                        selectedActivity = level.key
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(level.title)
                                    .foregroundColor(.primary)
                                Text(level.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if selectedActivity == level.key {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Theme.fireGold)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Aktivität")
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

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
