//
//  AuthError.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 06.01.26.
//

import Foundation

/// Authentication-specific errors
///
/// **Usage:**
/// ```swift
/// throw AppError.auth(.invalidCredentials)
/// throw AppError.auth(.signInFailed("Details..."))
/// ```
enum AuthError: Error {
    case signInFailed(String)
    case invalidCredentials
    case notAuthenticated
    case tokenExpired
    case tokenStorageFailed
    case tokenRetrievalFailed
    case tokenClearFailed
    case networkError(underlying: Error)
    case unknown(Error)

    // MARK: - User-Facing Messages

    var userMessage: String {
        switch self {
        case .signInFailed(let details):
            return "Anmeldung fehlgeschlagen. \(details)"
        case .invalidCredentials:
            return "Ungültige Anmeldedaten. Bitte überprüfen Sie Ihre Eingabe."
        case .notAuthenticated:
            return "Sie sind nicht angemeldet. Bitte melden Sie sich an."
        case .tokenExpired:
            return "Ihre Sitzung ist abgelaufen. Bitte melden Sie sich erneut an."
        case .tokenStorageFailed:
            return "Fehler beim Speichern der Anmeldeinformationen."
        case .tokenRetrievalFailed:
            return "Fehler beim Laden der Anmeldeinformationen."
        case .tokenClearFailed:
            return "Fehler beim Abmelden."
        case .networkError:
            return "Netzwerkfehler. Bitte überprüfen Sie Ihre Internetverbindung."
        case .unknown:
            return "Ein unbekannter Fehler ist aufgetreten."
        }
    }

    // MARK: - Analytics Metadata

    var eventName: String {
        "auth_error"
    }

    var metadata: [String: Any] {
        switch self {
        case .signInFailed(let details):
            return ["error_type": "sign_in_failed", "details": details]
        case .invalidCredentials:
            return ["error_type": "invalid_credentials"]
        case .notAuthenticated:
            return ["error_type": "not_authenticated"]
        case .tokenExpired:
            return ["error_type": "token_expired"]
        case .tokenStorageFailed:
            return ["error_type": "token_storage_failed"]
        case .tokenRetrievalFailed:
            return ["error_type": "token_retrieval_failed"]
        case .tokenClearFailed:
            return ["error_type": "token_clear_failed"]
        case .networkError(let underlying):
            return ["error_type": "network_error", "underlying": String(describing: underlying)]
        case .unknown(let underlying):
            return ["error_type": "unknown", "underlying": String(describing: underlying)]
        }
    }
}
