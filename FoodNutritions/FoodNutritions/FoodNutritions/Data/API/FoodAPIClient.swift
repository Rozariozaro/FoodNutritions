import Foundation

protocol FoodAPIClientProtocol {
    func searchFoods(query: String, limit: Int, filters: SearchFilters) async throws -> [FoodSearchResult]
    func autocomplete(query: String, limit: Int) async throws -> [AutocompleteSuggestion]
    func bulkNutrition(items: [MealItemRequest]) async throws -> NutritionResponse
}

final class FoodAPIClient: FoodAPIClientProtocol {
    private let baseURL = URL(string: "https://foodapi.rapheal.in")!
    private let session: URLSession

    private var apiKey: String {
        Bundle.main.infoDictionary?["FOOD_API_KEY"] as? String ?? ""
    }

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchFoods(query: String, limit: Int = 20, filters: SearchFilters) async throws -> [FoodSearchResult] {
        var components = URLComponents(url: baseURL.appendingPathComponent("search"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "protein_min", value: String(filters.proteinMin)),
            URLQueryItem(name: "calories_max", value: String(filters.caloriesMax)),
            URLQueryItem(name: "carbs_max", value: String(filters.carbsMax)),
            URLQueryItem(name: "sodium_max_mg", value: String(filters.sodiumMaxMg)),
            URLQueryItem(name: "protein_density_min", value: String(filters.proteinDensityMin)),
            URLQueryItem(name: "fiber_density_min", value: String(filters.fiberDensityMin))
        ]
        guard let url = components.url else { throw FoodError.invalidResponse }
        return try await performRequest([FoodSearchResult].self, url: url, method: "GET", body: nil)
    }

    func autocomplete(query: String, limit: Int = 10) async throws -> [AutocompleteSuggestion] {
        var components = URLComponents(url: baseURL.appendingPathComponent("autocomplete"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        guard let url = components.url else { throw FoodError.invalidResponse }
        return try await performRequest([AutocompleteSuggestion].self, url: url, method: "GET", body: nil)
    }

    func bulkNutrition(items: [MealItemRequest]) async throws -> NutritionResponse {
        let url = baseURL.appendingPathComponent("nutrition/bulk")
        let body = try JSONEncoder().encode(items)
        return try await performRequest(NutritionResponse.self, url: url, method: "POST", body: body)
    }

    private func performRequest<T: Decodable>(_ type: T.Type, url: URL, method: String, body: Data?) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw FoodError.networkUnavailable
        }

        guard let http = response as? HTTPURLResponse else { throw FoodError.invalidResponse }

        switch http.statusCode {
        case 200...299:
            break
        case 422:
            let detail = (try? JSONDecoder().decode([String: String].self, from: data))?["detail"] ?? "Validation error"
            throw FoodError.validationError(message: detail)
        default:
            throw FoodError.serverError(statusCode: http.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw FoodError.invalidResponse
        }
    }
}
