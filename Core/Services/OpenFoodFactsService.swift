//
//  OpenFoodFactsService.swift
//  w-diet
//
//  Service for searching Open Food Facts API
//

import Foundation

/// Service for interacting with Open Food Facts API
/// Free API with good German product coverage
actor OpenFoodFactsService {
    // MARK: - Singleton

    static let shared = OpenFoodFactsService()

    // MARK: - Constants

    private let baseURL = "https://world.openfoodfacts.org"
    private let searchEndpoint = "/cgi/search.pl"

    // MARK: - Types

    struct SearchResult: Sendable {
        let products: [FoodProduct]
        let totalCount: Int
    }

    struct FoodProduct: Identifiable, Sendable {
        let id: String
        let name: String
        let brand: String?
        let imageURL: String?
        let caloriesKcal: Int?
        let proteinG: Double?
        let carbsG: Double?
        let fatG: Double?
        let fiberG: Double?
        let servingSize: String?

        /// Whether this product has complete nutrition data
        var hasCompleteNutrition: Bool {
            caloriesKcal != nil && proteinG != nil && carbsG != nil && fatG != nil
        }
    }

    // MARK: - API Methods

    /// Search for food products by name
    /// - Parameters:
    ///   - query: Search term
    ///   - page: Page number (1-based)
    ///   - pageSize: Number of results per page
    /// - Returns: Search results with products
    func search(query: String, page: Int = 1, pageSize: Int = 20) async throws -> SearchResult {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return SearchResult(products: [], totalCount: 0)
        }

        // Build URL with query parameters
        var components = URLComponents(string: baseURL + searchEndpoint)!
        components.queryItems = [
            URLQueryItem(name: "search_terms", value: query),
            URLQueryItem(name: "search_simple", value: "1"),
            URLQueryItem(name: "action", value: "process"),
            URLQueryItem(name: "json", value: "1"),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "page_size", value: String(pageSize)),
            // Prioritize German products
            URLQueryItem(name: "countries_tags_de", value: "deutschland"),
            // Only products with nutrition data
            URLQueryItem(name: "nutriment_0", value: "energy-kcal"),
            URLQueryItem(name: "nutriment_compare_0", value: "gt"),
            URLQueryItem(name: "nutriment_value_0", value: "0")
        ]

        guard let url = components.url else {
            throw OpenFoodFactsError.invalidURL
        }

        // Make request
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenFoodFactsError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw OpenFoodFactsError.httpError(statusCode: httpResponse.statusCode)
        }

        // Parse response
        let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)

        let products = apiResponse.products.compactMap { parseProduct($0) }

        return SearchResult(
            products: products,
            totalCount: apiResponse.count
        )
    }

    /// Get product by barcode
    /// - Parameter barcode: Product barcode (EAN/UPC)
    /// - Returns: Product if found
    func getProduct(barcode: String) async throws -> FoodProduct? {
        let url = URL(string: "\(baseURL)/api/v0/product/\(barcode).json")!

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenFoodFactsError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw OpenFoodFactsError.httpError(statusCode: httpResponse.statusCode)
        }

        let apiResponse = try JSONDecoder().decode(SingleProductResponse.self, from: data)

        guard apiResponse.status == 1, let product = apiResponse.product else {
            return nil
        }

        return parseProduct(product)
    }

    // MARK: - Private Helpers

    private func parseProduct(_ raw: RawProduct) -> FoodProduct? {
        // Skip products without basic info
        guard let code = raw.code, !code.isEmpty else { return nil }

        let name = raw.product_name_de ?? raw.product_name ?? "Unbekanntes Produkt"

        // Parse nutriments (per 100g)
        let nutriments = raw.nutriments

        return FoodProduct(
            id: code,
            name: name,
            brand: raw.brands,
            imageURL: raw.image_front_small_url,
            caloriesKcal: nutriments?.energy_kcal_100g.flatMap { Int($0) },
            proteinG: nutriments?.proteins_100g,
            carbsG: nutriments?.carbohydrates_100g,
            fatG: nutriments?.fat_100g,
            fiberG: nutriments?.fiber_100g,
            servingSize: raw.serving_size
        )
    }
}

// MARK: - API Response Types

private struct APIResponse: Decodable {
    let count: Int
    let products: [RawProduct]
}

private struct SingleProductResponse: Decodable {
    let status: Int
    let product: RawProduct?
}

private struct RawProduct: Decodable {
    let code: String?
    let product_name: String?
    let product_name_de: String?
    let brands: String?
    let image_front_small_url: String?
    let serving_size: String?
    let nutriments: Nutriments?
}

private struct Nutriments: Decodable {
    let energy_kcal_100g: Double?
    let proteins_100g: Double?
    let carbohydrates_100g: Double?
    let fat_100g: Double?
    let fiber_100g: Double?

    private enum CodingKeys: String, CodingKey {
        case energy_kcal_100g = "energy-kcal_100g"
        case proteins_100g
        case carbohydrates_100g
        case fat_100g = "fat_100g"
        case fiber_100g
    }
}

// MARK: - Errors

enum OpenFoodFactsError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}
