//
//  AppConfiguration.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 06.01.26.
//

import Foundation

/// Application configuration loaded from .xcconfig files
///
/// **Usage:**
/// ```swift
/// let url = AppConfiguration.supabaseURL
/// let dsn = AppConfiguration.sentryDSN
/// ```
///
/// **Configuration Files:**
/// - Dev.xcconfig: Development environment (gitignored)
/// - Production.xcconfig: Production environment (gitignored)
/// - Secrets.xcconfig.template: Template for developers (git-tracked)
struct AppConfiguration {
    /// Supabase project URL (from SUPABASE_URL in .xcconfig)
    static let supabaseURL: String = {
        Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? ""
    }()

    /// Supabase anonymous key (from SUPABASE_ANON_KEY in .xcconfig)
    static let supabaseAnonKey: String = {
        Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String ?? ""
    }()

    /// Sentry DSN for crash reporting (from SENTRY_DSN in .xcconfig)
    static let sentryDSN: String = {
        Bundle.main.infoDictionary?["SENTRY_DSN"] as? String ?? ""
    }()

    /// Current app environment (from APP_ENVIRONMENT in .xcconfig)
    static let environment: String = {
        Bundle.main.infoDictionary?["APP_ENVIRONMENT"] as? String ?? "development"
    }()

    /// Whether running in production
    static var isProduction: Bool {
        environment == "production"
    }

    /// Whether running in development
    static var isDevelopment: Bool {
        environment == "development"
    }

    /// Gemini API key for food scanning (from GEMINI_API_KEY in .xcconfig)
    static let geminiAPIKey: String = {
        Bundle.main.infoDictionary?["GEMINI_API_KEY"] as? String ?? ""
    }()
}
