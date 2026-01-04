//
//  AppError.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 04.01.26.
//

import Foundation
import Sentry

/// Application-wide error hierarchy
///
/// **CRITICAL:** EVERY error must call `.report()` to ensure >99.5% crash-free rate target
///
/// Example usage:
/// ```swift
/// do {
///     try await operation()
/// } catch let error as AppError {
///     error.report()  // Logs to both analytics + Sentry
///     self.errorMessage = error.userMessage
/// } catch {
///     AppError.unknown(error).report()
/// }
/// ```
enum AppError: Error, LocalizedError {
    // MARK: - Database Errors

    case databaseInitializationFailed(underlying: Error)
    case databaseMigrationFailed(version: String, underlying: Error)
    case databaseQueryFailed(query: String, underlying: Error)
    case databaseWriteFailed(operation: String, underlying: Error)

    // MARK: - Network/Sync Errors

    case networkUnavailable
    case syncFailed(operation: String, underlying: Error)
    case authenticationFailed(reason: String)
    case serverError(statusCode: Int, message: String?)

    // MARK: - Validation Errors

    case invalidInput(field: String, reason: String)
    case missingRequiredField(field: String)
    case valueOutOfRange(field: String, min: Double?, max: Double?)

    // MARK: - Business Logic Errors

    case cycleNotStarted
    case cycleAlreadyActive
    case phaseTransitionFailed(reason: String)
    case mealLogInvalid(reason: String)

    // MARK: - Unknown/System Errors

    case unknown(Error)
    case notImplemented(feature: String)

    // MARK: - User-Facing Messages (German for POC)

    var userMessage: String {
        switch self {
        // Database
        case .databaseInitializationFailed:
            return "Die App-Datenbank konnte nicht initialisiert werden. Bitte starte die App neu."
        case .databaseMigrationFailed:
            return "Datenbankaktualisierung fehlgeschlagen. Bitte aktualisiere die App."
        case .databaseQueryFailed:
            return "Daten konnten nicht geladen werden. Bitte versuche es erneut."
        case .databaseWriteFailed:
            return "Daten konnten nicht gespeichert werden. Bitte versuche es erneut."

        // Network/Sync
        case .networkUnavailable:
            return "Keine Internetverbindung. Deine Daten werden lokal gespeichert und später synchronisiert."
        case .syncFailed:
            return "Synchronisation fehlgeschlagen. Deine Daten sind lokal gespeichert."
        case .authenticationFailed:
            return "Anmeldung fehlgeschlagen. Bitte überprüfe deine Zugangsdaten."
        case .serverError(let code, _):
            return "Serverfehler (\(code)). Bitte versuche es später erneut."

        // Validation
        case .invalidInput(let field, let reason):
            return "\(field): \(reason)"
        case .missingRequiredField(let field):
            return "\(field) ist erforderlich."
        case .valueOutOfRange(let field, let min, let max):
            if let min = min, let max = max {
                return "\(field) muss zwischen \(min) und \(max) liegen."
            } else if let min = min {
                return "\(field) muss mindestens \(min) sein."
            } else if let max = max {
                return "\(field) darf maximal \(max) sein."
            }
            return "\(field) ist außerhalb des gültigen Bereichs."

        // Business Logic
        case .cycleNotStarted:
            return "Kein aktiver Zyklus. Bitte starte einen neuen MATADOR-Zyklus."
        case .cycleAlreadyActive:
            return "Es läuft bereits ein aktiver Zyklus."
        case .phaseTransitionFailed(let reason):
            return "Phasenwechsel fehlgeschlagen: \(reason)"
        case .mealLogInvalid(let reason):
            return "Ungültige Mahlzeit: \(reason)"

        // Unknown
        case .unknown:
            return "Ein unerwarteter Fehler ist aufgetreten. Bitte versuche es erneut."
        case .notImplemented(let feature):
            return "\(feature) ist noch nicht verfügbar."
        }
    }

    // MARK: - Error Description (for logging)

    var errorDescription: String? {
        switch self {
        case .databaseInitializationFailed(let error):
            return "Database initialization failed: \(error.localizedDescription)"
        case .databaseMigrationFailed(let version, let error):
            return "Database migration \(version) failed: \(error.localizedDescription)"
        case .databaseQueryFailed(let query, let error):
            return "Database query '\(query)' failed: \(error.localizedDescription)"
        case .databaseWriteFailed(let operation, let error):
            return "Database write '\(operation)' failed: \(error.localizedDescription)"

        case .networkUnavailable:
            return "Network unavailable"
        case .syncFailed(let operation, let error):
            return "Sync '\(operation)' failed: \(error.localizedDescription)"
        case .authenticationFailed(let reason):
            return "Authentication failed: \(reason)"
        case .serverError(let code, let message):
            return "Server error \(code): \(message ?? "unknown")"

        case .invalidInput(let field, let reason):
            return "Invalid input for \(field): \(reason)"
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .valueOutOfRange(let field, let min, let max):
            return "Value out of range for \(field): min=\(min?.description ?? "nil"), max=\(max?.description ?? "nil")"

        case .cycleNotStarted:
            return "Cycle not started"
        case .cycleAlreadyActive:
            return "Cycle already active"
        case .phaseTransitionFailed(let reason):
            return "Phase transition failed: \(reason)"
        case .mealLogInvalid(let reason):
            return "Meal log invalid: \(reason)"

        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        case .notImplemented(let feature):
            return "Not implemented: \(feature)"
        }
    }

    // MARK: - Analytics Event Name

    /// Converts error to analytics event name (snake_case past tense)
    var analyticsEventName: String {
        switch self {
        case .databaseInitializationFailed:
            return "database_initialization_failed"
        case .databaseMigrationFailed:
            return "database_migration_failed"
        case .databaseQueryFailed:
            return "database_query_failed"
        case .databaseWriteFailed:
            return "database_write_failed"
        case .networkUnavailable:
            return "network_unavailable"
        case .syncFailed:
            return "sync_failed"
        case .authenticationFailed:
            return "authentication_failed"
        case .serverError:
            return "server_error_occurred"
        case .invalidInput:
            return "invalid_input_provided"
        case .missingRequiredField:
            return "required_field_missing"
        case .valueOutOfRange:
            return "value_out_of_range"
        case .cycleNotStarted:
            return "cycle_not_started_error"
        case .cycleAlreadyActive:
            return "cycle_already_active_error"
        case .phaseTransitionFailed:
            return "phase_transition_failed"
        case .mealLogInvalid:
            return "meal_log_invalid"
        case .unknown:
            return "unknown_error_occurred"
        case .notImplemented:
            return "not_implemented_error"
        }
    }

    // MARK: - Report to Analytics + Sentry

    /// Reports error to both analytics and Sentry
    ///
    /// **CRITICAL:** ALWAYS call this method when catching errors
    /// This ensures we meet the >99.5% crash-free rate target
    func report() {
        // 1. Log to Sentry with full context
        SentrySDK.capture(error: self) { scope in
            scope.setLevel(.error)
            scope.setContext(value: [
                "error_type": analyticsEventName,
                "user_message": userMessage,
                "description": errorDescription ?? "no description"
            ], key: "app_error")
        }

        // 2. Log to analytics (placeholder - integrate with actual analytics service)
        // TODO: Integrate with analytics service in Phase 1
        logToAnalytics(eventName: analyticsEventName, parameters: [
            "error_description": errorDescription ?? "unknown",
            "user_message": userMessage
        ])

        // 3. Log to console for development
        #if DEBUG
        print("🔴 AppError: \(analyticsEventName)")
        print("   Description: \(errorDescription ?? "no description")")
        print("   User Message: \(userMessage)")
        #endif
    }

    // MARK: - Analytics Helper (Placeholder)

    private func logToAnalytics(eventName: String, parameters: [String: String]) {
        // TODO: Replace with actual analytics service (Firebase, Amplitude, etc.)
        // For now, just log to console
        #if DEBUG
        print("📊 Analytics: \(eventName)")
        parameters.forEach { key, value in
            print("   \(key): \(value)")
        }
        #endif
    }
}
