//
//  w_dietApp.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 04.01.26.
//

import SwiftUI
import Sentry
import Supabase

@main
struct w_dietApp: App {
    /// Dark mode preference - initialized from system setting on first launch
    @AppStorage("isDarkMode") private var isDarkMode = true

    init() {
        // On first launch, detect system appearance and set isDarkMode accordingly
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            // Get system color scheme
            let systemIsDark = UITraitCollection.current.userInterfaceStyle == .dark
            UserDefaults.standard.set(systemIsDark, forKey: "isDarkMode")
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }

        // Initialize Sentry BEFORE views render (only if DSN is configured)
        // CRITICAL: Must happen before any view creation
        if !AppConfiguration.sentryDSN.isEmpty {
            SentrySDK.start { options in
                options.dsn = AppConfiguration.sentryDSN

                // Trace sample rate: 100% in dev, 10% in prod
                // Controls performance monitoring overhead
                options.tracesSampleRate = AppConfiguration.isProduction ? 0.1 : 1.0

                // Environment tag for filtering in Sentry dashboard
                options.environment = AppConfiguration.environment

                // Enable automatic crash handler
                options.enableCrashHandler = true
            }
        }
    }

    /// Color scheme based on user preference
    private var colorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }

    var body: some Scene {
        WindowGroup {
            AppLaunchView()
                .preferredColorScheme(colorScheme)
                .onOpenURL { url in
                    // Handle OAuth callback from Supabase
                    Task {
                        await AuthManager.shared.handleOAuthCallback(url: url)
                    }
                }
        }
    }
}

/// Manages splash screen display and transition to main app
struct AppLaunchView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            // Main app (always rendered underneath)
            RootView()
                .opacity(showSplash ? 0 : 1)

            // Splash overlay
            if showSplash {
                SplashView()
                    .transition(AnyTransition.opacity)
            }
        }
        .onAppear {
            // Show splash for minimum 2 seconds, then fade out
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showSplash = false
                }
            }
        }
    }
}

/// Animated splash screen with pulsing flame
struct SplashView: View {
    @State private var isAnimating = false
    @State private var flameScale: CGFloat = 0.8
    @State private var flameOpacity: Double = 0.6
    @State private var glowOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // Background
            Theme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Animated flame
                ZStack {
                    // Glow effect behind flame
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Theme.fireGold.opacity(0.4),
                                    Theme.fireGold.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .opacity(glowOpacity)
                        .scaleEffect(isAnimating ? 1.2 : 0.9)

                    // Main flame icon
                    Image(systemName: "flame.fill")
                        .font(.system(size: 80, weight: .regular))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Theme.fireGold,
                                    Theme.energyOrange,
                                    Theme.error
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(flameScale)
                        .opacity(flameOpacity)
                }
            }
        }
        .onAppear {
            // Start animations
            withAnimation(.easeInOut(duration: 0.6)) {
                flameScale = 1.0
                flameOpacity = 1.0
                glowOpacity = 1.0
            }

            // Pulse animation
            withAnimation(
                .easeInOut(duration: 0.8)
                .repeatForever(autoreverses: true)
                .delay(0.3)
            ) {
                isAnimating = true
            }
        }
    }
}
