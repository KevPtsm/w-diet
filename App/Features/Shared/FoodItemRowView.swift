//
//  FoodItemRowView.swift
//  w-diet
//
//  Shared component for displaying a food item row from AI analysis
//

import SwiftUI

/// A tappable row displaying a food item with nutrition info
struct FoodItemRowView: View {
    // MARK: - Properties

    let item: FoodAnalysisResponse.FoodItem
    let onSelect: () -> Void

    // MARK: - Body

    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(item.portion)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(item.calories) kcal")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.fireGold)
                    Text("E:\(Int(item.proteinG))g K:\(Int(item.carbsG))g F:\(Int(item.fatG))g")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(Theme.fireGold)
            }
            .padding()
            .background(Theme.backgroundSecondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Theme.lightModeBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
