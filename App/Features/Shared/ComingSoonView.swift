//
//  ComingSoonView.swift
//  w-diet
//
//  Placeholder view for upcoming features
//

import SwiftUI

/// Placeholder view for features that are coming soon
struct ComingSoonView: View {
    let title: String
    let icon: String
    let description: String

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(Theme.fireGold)

            // Title
            Text(title)
                .font(.title)
                .fontWeight(.bold)

            // Coming Soon Badge
            Text("Kommt bald")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Theme.fireGold)
                .cornerRadius(20)

            // Description
            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.backgroundPrimary)
    }
}

// MARK: - Preview

#Preview {
    ComingSoonView(
        title: "Lernen",
        icon: "book.fill",
        description: "Tipps und Wissen rund um Ernährung und MATADOR"
    )
}
