//
//  Step0ConsentView.swift
//  w-diet
//
//  GDPR Consent Screen - Required before collecting health data
//  Must be shown BEFORE any other onboarding steps
//

import SwiftUI

/// Step 0: GDPR Consent for health data processing
/// Required under DSGVO Article 9 for German apps
struct Step0ConsentView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showDatenschutz = false
    @State private var sliderOffset: CGFloat = 0
    @State private var hasConfirmed = false
    @State private var celebrationScale: CGFloat = 1.0

    private let sliderWidth: CGFloat = 320
    private let thumbSize: CGFloat = 56

    /// Progress percentage for the fill (0.0 to 1.0)
    private var progress: CGFloat {
        sliderOffset / (sliderWidth - thumbSize)
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Fire Icon (Mascot-style)
            Image(systemName: "flame.fill")
                .font(.system(size: 70))
                .foregroundColor(Theme.fireGold)
                .scaleEffect(celebrationScale)

            // Casual Header
            VStack(spacing: 8) {
                Text("Bevor's losgeht...")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Deine Daten bleiben bei dir.")
                    .font(.body)
                    .foregroundStyle(.secondary)

                // Privacy Policy Link
                Button("Datenschutzerklärung") {
                    showDatenschutz = true
                }
                .font(.subheadline)
                .foregroundColor(Theme.fireGold)
                .padding(.top, 4)
            }

            Spacer()
            Spacer()

            // Slide to confirm
            ZStack(alignment: .leading) {
                // Track background
                RoundedRectangle(cornerRadius: thumbSize / 2)
                    .fill(Theme.gray100)
                    .frame(width: sliderWidth, height: thumbSize)

                // Progress fill (orange)
                RoundedRectangle(cornerRadius: thumbSize / 2)
                    .fill(Theme.fireGold.opacity(0.3))
                    .frame(width: sliderOffset + thumbSize, height: thumbSize)

                // Label
                if !hasConfirmed {
                    Text("Zum Bestätigen schieben")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(width: sliderWidth, height: thumbSize)
                } else {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark")
                            .font(.headline)
                            .foregroundColor(Theme.fireGold)
                        Spacer()
                    }
                    .frame(width: sliderWidth, height: thumbSize)
                }

                // Thumb
                Circle()
                    .fill(Theme.fireGold)
                    .frame(width: thumbSize - 8, height: thumbSize - 8)
                    .overlay(
                        Image(systemName: hasConfirmed ? "checkmark" : "arrow.right")
                            .font(.headline)
                            .foregroundColor(.white)
                    )
                    .padding(4)
                    .offset(x: sliderOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard !hasConfirmed else { return }
                                let newOffset = min(max(0, value.translation.width), sliderWidth - thumbSize)
                                sliderOffset = newOffset
                            }
                            .onEnded { value in
                                guard !hasConfirmed else { return }
                                if sliderOffset > sliderWidth - thumbSize - 20 {
                                    // Confirmed!
                                    withAnimation(.spring(response: 0.3)) {
                                        sliderOffset = sliderWidth - thumbSize
                                        hasConfirmed = true
                                        viewModel.healthDataConsentGiven = true
                                    }
                                    // Celebration animation
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                        celebrationScale = 1.3
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            celebrationScale = 1.0
                                        }
                                    }
                                    // Auto-advance to next step after celebration
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        viewModel.nextStep()
                                    }
                                } else {
                                    // Reset
                                    withAnimation(.spring(response: 0.3)) {
                                        sliderOffset = 0
                                    }
                                }
                            }
                    )
            }
            .padding(.bottom, 32)
        }
        .sheet(isPresented: $showDatenschutz) {
            DatenschutzView()
        }
    }
}

// MARK: - Preview

#Preview {
    Step0ConsentView(viewModel: OnboardingViewModel())
}
