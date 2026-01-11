//
//  AddFoodButtonBar.swift
//  w-diet
//
//  Shared component for Add Food / Scan Food buttons
//

import SwiftUI

/// A horizontal bar with "Essen hinzufügen" and "Teller scannen" buttons
struct AddFoodButtonBar: View {
    // MARK: - Properties

    var onAddFood: () -> Void
    var onScanFood: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            // Left: Add Food manually
            Button {
                onAddFood()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(Strings.MealLogging.addFood)
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
                onScanFood()
            } label: {
                HStack {
                    Image(systemName: "camera.viewfinder")
                    Text(Strings.MealLogging.scanPlate)
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
}
