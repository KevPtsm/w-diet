//
//  Step3AgeInputView.swift
//  w-diet
//
//  Step 3: Birthdate Input - collects user's birthdate for age calculation
//

import SwiftUI

/// Step 3: Birthdate Input - collects user's birthdate for age calculation
struct Step3AgeInputView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    private let months = [
        (1, "Januar"), (2, "Februar"), (3, "März"), (4, "April"),
        (5, "Mai"), (6, "Juni"), (7, "Juli"), (8, "August"),
        (9, "September"), (10, "Oktober"), (11, "November"), (12, "Dezember")
    ]

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    private var daysInMonth: Int {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = viewModel.selectedBirthYear
        components.month = viewModel.selectedBirthMonth
        if let date = calendar.date(from: components),
           let range = calendar.range(of: .day, in: .month, for: date) {
            return range.count
        }
        return 31
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Mascot with speech bubble
            VStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Theme.fireGold)

                Text("Wie alt bist du?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.gray100)
                    .cornerRadius(16)
            }
            .padding(.bottom, 24)

            // Birthdate Pickers
            HStack(spacing: 0) {
                // Day Picker
                Picker("Tag", selection: $viewModel.selectedBirthDay) {
                    ForEach(1...daysInMonth, id: \.self) { day in
                        Text("\(day)")
                            .font(.system(size: 22, weight: .semibold))
                            .tag(day)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 60, height: 150)
                .clipped()
                .onChange(of: viewModel.selectedBirthDay) { _, _ in
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }

                // Month Picker
                Picker("Monat", selection: $viewModel.selectedBirthMonth) {
                    ForEach(months, id: \.0) { month in
                        Text(month.1)
                            .font(.system(size: 22, weight: .semibold))
                            .tag(month.0)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 140, height: 150)
                .clipped()
                .onChange(of: viewModel.selectedBirthMonth) { _, newMonth in
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    // Adjust day if needed when month changes
                    let maxDays = daysInSelectedMonth(month: newMonth, year: viewModel.selectedBirthYear)
                    if viewModel.selectedBirthDay > maxDays {
                        viewModel.selectedBirthDay = maxDays
                    }
                }

                // Year Picker
                Picker("Jahr", selection: $viewModel.selectedBirthYear) {
                    ForEach((currentYear - 100)...(currentYear - 18), id: \.self) { year in
                        Text(String(year))
                            .font(.system(size: 22, weight: .semibold))
                            .tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 90, height: 150)
                .clipped()
                .onChange(of: viewModel.selectedBirthYear) { _, newYear in
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    // Adjust day if needed for leap years
                    let maxDays = daysInSelectedMonth(month: viewModel.selectedBirthMonth, year: newYear)
                    if viewModel.selectedBirthDay > maxDays {
                        viewModel.selectedBirthDay = maxDays
                    }
                }
            }
            .frame(height: 150)

            // Tip card
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.title3)
                    .foregroundColor(.yellow)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Tipp")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("Dies ist relevant für die Kalorienberechnung.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal, 32)
            .padding(.top, 16)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Helper

    private func daysInSelectedMonth(month: Int, year: Int) -> Int {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        if let date = calendar.date(from: components),
           let range = calendar.range(of: .day, in: .month, for: date) {
            return range.count
        }
        return 31
    }
}

// MARK: - Preview

#Preview {
    Step3AgeInputView(viewModel: OnboardingViewModel())
}
