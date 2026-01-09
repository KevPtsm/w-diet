//
//  NutritionLabelService.swift
//  w-diet
//
//  Apple Vision OCR for nutrition label scanning
//

import Foundation
import UIKit
import Vision

/// Extracted nutrition values per 100g
struct NutritionLabelResult {
    var calories: Int = 0
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
    var rawText: String = ""

    var isValid: Bool {
        // At least calories or one macro should be found
        calories > 0 || protein > 0 || carbs > 0 || fat > 0
    }
}

/// Service for extracting nutrition info from label images using Apple Vision
actor NutritionLabelService {
    static let shared = NutritionLabelService()

    private init() {}

    /// Analyze a nutrition label image and extract values
    func analyzeLabel(image: UIImage) async throws -> NutritionLabelResult {
        guard let cgImage = image.cgImage else {
            throw NutritionLabelError.imageConversionFailed
        }

        // Perform text recognition
        let recognizedText = try await recognizeText(in: cgImage)

        // Parse nutrition values from text
        let result = parseNutritionValues(from: recognizedText)

        return result
    }

    /// Use Vision framework to recognize text in image
    private func recognizeText(in cgImage: CGImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }

                // Combine all recognized text
                let text = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")

                continuation.resume(returning: text)
            }

            // Configure for accurate recognition
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["de-DE", "en-US"]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Parse nutrition values from recognized text using regex
    private func parseNutritionValues(from text: String) -> NutritionLabelResult {
        var result = NutritionLabelResult()
        result.rawText = text

        // Normalize text: lowercase, normalize spaces
        let normalizedText = text
            .lowercased()
            .replacingOccurrences(of: ",", with: ".")  // German decimal separator

        // Extract calories (kcal)
        // Patterns: "energie 245 kcal", "brennwert 245 kcal", "245 kcal", "kalorien 245"
        let caloriePatterns = [
            #"(?:energie|brennwert|energy|kalorien|calories)[:\s]*(\d+)\s*kcal"#,
            #"(\d+)\s*kcal"#,
            #"(?:energie|brennwert|energy)[:\s]*(\d+)"#
        ]

        for pattern in caloriePatterns {
            if let match = matchFirst(pattern: pattern, in: normalizedText) {
                result.calories = Int(match) ?? 0
                if result.calories > 0 { break }
            }
        }

        // Extract protein (Eiweiß)
        // Patterns: "eiweiß 12g", "protein 12 g", "eiweiß: 12,5 g"
        let proteinPatterns = [
            #"(?:eiweiß|eiweiss|protein|proteine)[:\s]*(\d+\.?\d*)\s*g"#,
            #"(?:eiweiß|eiweiss|protein)[:\s]*(\d+\.?\d*)"#
        ]

        for pattern in proteinPatterns {
            if let match = matchFirst(pattern: pattern, in: normalizedText) {
                result.protein = Double(match) ?? 0
                if result.protein > 0 { break }
            }
        }

        // Extract carbohydrates (Kohlenhydrate)
        // Patterns: "kohlenhydrate 30g", "carbohydrates 30 g", "carbs 30g"
        let carbPatterns = [
            #"(?:kohlenhydrate|carbohydrates|carbs|glucides)[:\s]*(\d+\.?\d*)\s*g"#,
            #"(?:kohlenhydrate|carbohydrates)[:\s]*(\d+\.?\d*)"#
        ]

        for pattern in carbPatterns {
            if let match = matchFirst(pattern: pattern, in: normalizedText) {
                result.carbs = Double(match) ?? 0
                if result.carbs > 0 { break }
            }
        }

        // Extract fat (Fett)
        // Patterns: "fett 8g", "fat 8 g", "fett: 8,5 g"
        // Be careful not to match "gesättigte fettsäuren" (saturated fat)
        let fatPatterns = [
            #"(?:^|\n)fett[:\s]*(\d+\.?\d*)\s*g"#,
            #"(?:total\s+)?fat[:\s]*(\d+\.?\d*)\s*g"#,
            #"(?:^|\n)fett[:\s]*(\d+\.?\d*)"#
        ]

        for pattern in fatPatterns {
            if let match = matchFirst(pattern: pattern, in: normalizedText) {
                result.fat = Double(match) ?? 0
                if result.fat > 0 { break }
            }
        }

        return result
    }

    /// Helper to find first regex match
    private func matchFirst(pattern: String, in text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }

        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range),
              match.numberOfRanges > 1,
              let valueRange = Range(match.range(at: 1), in: text) else {
            return nil
        }

        return String(text[valueRange])
    }
}

// MARK: - Errors

enum NutritionLabelError: LocalizedError {
    case imageConversionFailed
    case noTextFound
    case parsingFailed

    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Bild konnte nicht verarbeitet werden"
        case .noTextFound:
            return "Kein Text erkannt"
        case .parsingFailed:
            return "Nährwerte konnten nicht extrahiert werden"
        }
    }
}
