//
//  APIClient.swift
//  netflix-clone
//

import Foundation

/// Generic HTTP client for TMDB API.
/// Handles request building, authentication, response decoding, and error handling.
actor APIClient {

    static let shared = APIClient() // ← singleton shared instance

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15 // ← ubah timeout request (detik)
        config.timeoutIntervalForResource = 30 // ← ubah timeout resource (detik)
        self.session = URLSession(configuration: config)
    }

    // MARK: - Generic Request

    /// Execute a request and decode the response.
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let url = try endpoint.url() // ← build URL dari endpoint

        var request = URLRequest(url: url)
        request.httpMethod = "GET" // ← ubah HTTP method
        request.setValue(APIConfig.authorizationHeader, forHTTPHeaderField: "Authorization") // ← auth header
        request.setValue("application/json", forHTTPHeaderField: "Accept") // ← accept header

        let (data, response) = try await session.data(for: request) // ← execute request

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown("Invalid response type") // ← response bukan HTTP
        }

        // ← handle HTTP status codes
        switch httpResponse.statusCode {
        case 200...299:
            break // success
        case 401:
            throw APIError.unauthorized // ← token tidak valid
        case 404:
            throw APIError.notFound // ← resource tidak ditemukan
        case 429:
            throw APIError.rateLimited // ← rate limited
        case 500...599:
            throw APIError.serverError(httpResponse.statusCode) // ← server error
        default:
            throw APIError.unknown("HTTP \(httpResponse.statusCode)") // ← status code lain
        }

        do {
            let decoder = JSONDecoder() // ← ubah decoder config kalau perlu
            return try decoder.decode(T.self, from: data) // ← decode JSON
        } catch {
            throw APIError.decodingError(error) // ← decode gagal
        }
    }

    // MARK: - Convenience

    /// Fetch with optional query parameters.
    func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        try await request(endpoint)
    }
}
