//
//  w_dietApp.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 04.01.26.
//

import SwiftUI
import Sentry

@main
struct w_dietApp: App {
    /// Dark mode preference - synced with Settings toggle
    @AppStorage("isDarkMode") private var isDarkMode = false

    init() {
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

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
