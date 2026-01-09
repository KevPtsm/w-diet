//
//  Step4MatadorExplainerView.swift
//  w-diet
//
//  Step 8: MATADOR Cycle Explainer
//

import SwiftUI

/// Step 8: MATADOR Cycle Explainer
struct Step4MatadorExplainerView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 20)

                // Mascot with speech bubble (consistent with other screens)
                VStack(spacing: 12) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Theme.fireGold)

                    Text("Das ist MATADOR")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Theme.gray100)
                        .cornerRadius(16)
                }
                .padding(.bottom, 20)

                // Comparison Card
                HStack(alignment: .top, spacing: 12) {
                    // Normal Diet Column
                    VStack(spacing: 12) {
                        Text("Normale Diät")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .frame(height: 16)

                        // Visual: all same color = constant deficit
                        HStack(spacing: 3) {
                            ForEach(0..<4, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.4))
                                    .frame(height: 24)
                            }
                        }

                        // Match 2-line height of right side
                        VStack(spacing: 2) {
                            Text("Konstantes")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("Defizit")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        VStack(spacing: 6) {
                            Image(systemName: "arrow.down")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Text("Stoffwechsel\ncrashed")
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)

                            Image(systemName: "arrow.down")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red.opacity(0.7))

                            Text("Jojo-Effekt")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // Divider
                    Rectangle()
                        .fill(Theme.gray300)
                        .frame(width: 1)

                    // MATADOR Column
                    VStack(spacing: 12) {
                        Text("MATADOR")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.fireGold)
                            .frame(height: 16)

                        // Visual: 4 weeks (2 diet + 2 maintenance)
                        HStack(spacing: 3) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Theme.deficitPhase)
                                .frame(height: 24)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Theme.deficitPhase)
                                .frame(height: 24)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Theme.maintenancePhase)
                                .frame(height: 24)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Theme.maintenancePhase)
                                .frame(height: 24)
                        }

                        VStack(spacing: 2) {
                            Text("2 Wochen Defizit")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("2 Wochen Erhalt")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        VStack(spacing: 6) {
                            Image(systemName: "arrow.down")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Text("Stoffwechsel\nbleibt aktiv")
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)

                            Image(systemName: "arrow.down")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)

                            Text("Gewichtsverlust")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Theme.backgroundSecondary)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Theme.gray300, lineWidth: 1)
                )
                .padding(.horizontal, 32)

                // Benefits Card
                VStack(alignment: .leading, spacing: 10) {
                    benefitRow(icon: "bolt.fill", text: "47% mehr Gewichtsverlust")
                    benefitRow(icon: "chart.line.uptrend.xyaxis", text: "Stoffwechsel bleibt aktiv")
                    benefitRow(icon: "checkmark.shield.fill", text: "Gewicht bleibt weg")
                }
                .padding(14)
                .background(Theme.backgroundSecondary)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Theme.gray300, lineWidth: 1)
                )
                .padding(.top, 12)
                .padding(.horizontal, 32)

                // Study Link
                Link(destination: URL(string: "https://www.nature.com/articles/ijo2017206")!) {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.body)
                        Text("MATADOR Studie lesen")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .padding(14)
                    .background(Theme.backgroundSecondary)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Theme.gray300, lineWidth: 1)
                    )
                }
                .padding(.top, 12)
                .padding(.horizontal, 32)

                Spacer()
                    .frame(height: 100)
            }
        }
    }

    // MARK: - Components

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(Theme.fireGold)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    Step4MatadorExplainerView(viewModel: OnboardingViewModel())
}
