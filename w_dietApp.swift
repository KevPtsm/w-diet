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
            RootView()
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
