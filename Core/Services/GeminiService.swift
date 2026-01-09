//
//  GeminiService.swift
//  w-diet
//
//  Gemini AI service for food image analysis
//

import Foundation
import UIKit

/// Response structure for food analysis
struct FoodAnalysisResponse: Codable {
    let items: [FoodItem]
    let totals: NutritionTotals
    let confidence: String

    struct FoodItem: Codable, Identifiable {
        var id: String { name + String(calories) }
        let name: String
        let portion: String
        let calories: Int
        let proteinG: Double
        let carbsG: Double
        let fatG: Double

        enum CodingKeys: String, CodingKey {
            case name, portion, calories
            case proteinG = "protein_g"
            case carbsG = "carbs_g"
            case fatG = "fat_g"
        }
    }

    struct NutritionTotals: Codable {
        let calories: Int
        let proteinG: Double
        let carbsG: Double
        let fatG: Double

        enum CodingKeys: String, CodingKey {
            case calories
            case proteinG = "protein_g"
            case carbsG = "carbs_g"
            case fatG = "fat_g"
        }
    }
}

/// Service for analyzing food images using Gemini AI
actor GeminiService {
    static let shared = GeminiService()

    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

    private init() {}

    /// Analyze a food image and return nutritional information
    func analyzeFood(image: UIImage) async throws -> FoodAnalysisResponse {
        guard !AppConfiguration.geminiAPIKey.isEmpty else {
            throw GeminiError.missingAPIKey
        }

        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw GeminiError.imageConversionFailed
        }
        let base64Image = imageData.base64EncodedString()

        // Build request
        let url = URL(string: "\(baseURL)?key=\(AppConfiguration.geminiAPIKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Build prompt
        let prompt = """
        Analyze this meal photo. Return ONLY valid JSON with this exact structure, no markdown:
        {
          "items": [
            {"name": "Food name", "portion": "estimated portion", "calories": 0, "protein_g": 0.0, "carbs_g": 0.0, "fat_g": 0.0}
          ],
          "totals": {"calories": 0, "protein_g": 0.0, "carbs_g": 0.0, "fat_g": 0.0},
          "confidence": "low/medium/high"
        }

        Rules:
        - Estimate portions visually based on typical serving sizes
        - Use German food names when recognizable (e.g., "Schnitzel", "Brötchen")
        - Include ALL visible food items
        - Be conservative with calorie estimates
        - Return valid JSON only, no explanation text
        """

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.1,
                "maxOutputTokens": 1024
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        // Make request
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw GeminiError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
        }

        // Parse Gemini response
        let geminiResponse = try JSONDecoder().decode(GeminiAPIResponse.self, from: data)

        guard let textContent = geminiResponse.candidates.first?.content.parts.first?.text else {
            throw GeminiError.noContentReturned
        }

        // Extract JSON from response (might be wrapped in markdown code blocks)
        let jsonString = extractJSON(from: textContent)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw GeminiError.jsonParsingFailed
        }

        let foodAnalysis = try JSONDecoder().decode(FoodAnalysisResponse.self, from: jsonData)
        return foodAnalysis
    }

    /// Extract JSON from text that might contain markdown code blocks
    private func extractJSON(from text: String) -> String {
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove markdown code blocks if present
        if result.hasPrefix("```json") {
            result = String(result.dropFirst(7))
        } else if result.hasPrefix("```") {
            result = String(result.dropFirst(3))
        }

        if result.hasSuffix("```") {
            result = String(result.dropLast(3))
        }

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Gemini API Response Models

private struct GeminiAPIResponse: Codable {
    let candidates: [Candidate]

    struct Candidate: Codable {
        let content: Content
    }

    struct Content: Codable {
        let parts: [Part]
    }

    struct Part: Codable {
        let text: String?
    }
}

// MARK: - Errors

enum GeminiError: LocalizedError {
    case missingAPIKey
    case imageConversionFailed
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    case noContentReturned
    case jsonParsingFailed

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Gemini API Key nicht konfiguriert"
        case .imageConversionFailed:
            return "Bild konnte nicht verarbeitet werden"
        case .invalidResponse:
            return "Ungültige Antwort vom Server"
        case .apiError(let code, let message):
            return "API Fehler (\(code)): \(message)"
        case .noContentReturned:
            return "Keine Analyse erhalten"
        case .jsonParsingFailed:
            return "Antwort konnte nicht verarbeitet werden"
        }
    }
}
