//
//  MealLoggingView.swift
//  w-diet
//
//  Main meal logging tab showing today's meals and add options
//

import SwiftUI

/// Main view for the Logging tab
struct MealLoggingView: View {
    // MARK: - State

    @StateObject private var viewModel = MealLoggingViewModel()
    @State private var showAddFood = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Today's Meals List
                    if viewModel.todaysMeals.isEmpty {
                        emptyStateView
                    } else {
                        mealsListSection
                    }

                    // Add Food Button (same position as Dashboard)
                    addFoodButton

                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    EmptyView()
                }
            }
            .task {
                await viewModel.loadTodaysMeals()
            }
            .refreshable {
                await viewModel.loadTodaysMeals()
            }
            .sheet(isPresented: $showAddFood) {
                FoodSearchView(onFoodAdded: {
                    Task {
                        await viewModel.loadTodaysMeals()
                    }
                })
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
    }

    // MARK: - Components

    private var addFoodButton: some View {
        Button {
            showAddFood = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Essen hinzufügen")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.fireGold)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Noch keine Mahlzeiten")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Tippe auf \"Essen hinzufügen\" um deine erste Mahlzeit zu loggen.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }

    private var mealsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mahlzeiten")
                .font(.headline)

            ForEach(viewModel.todaysMeals) { meal in
                mealRow(meal)
            }
        }
    }

    private func mealRow(_ meal: MealLog) -> some View {
        HStack {
            Text(meal.mealName)
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(meal.caloriesKcal) kcal")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.fireGold)

                HStack(spacing: 8) {
                    Text("E: \(Int(meal.proteinG))g")
                    Text("K: \(Int(meal.carbsG))g")
                    Text("F: \(Int(meal.fatG))g")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Theme.backgroundSecondary)
        .cornerRadius(8)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                Task {
                    await viewModel.deleteMeal(meal)
                }
            } label: {
                Label("Löschen", systemImage: "trash")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MealLoggingView()
}
