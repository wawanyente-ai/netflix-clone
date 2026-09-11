//
//  BackendClient.swift
//  netflix-clone
//

import Foundation

/// HTTP client untuk backend Go (`backend/`). Support GET/POST/PUT/PATCH/DELETE,
/// JSON body + response, dan error terstruktur (`BackendError`).
actor BackendClient {

    static let shared = BackendClient() // ← singleton

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20 // ← ubah timeout request (detik)
        config.timeoutIntervalForResource = 40 // ← ubah timeout resource (detik)
        self.session = URLSession(configuration: config)
    }

    // MARK: - Request

    /// Execute request, decode response menjadi `T`, atau throw BackendError.
    func request<T: Decodable>(
        _ method: String,
        _ path: String,
        query: [String: String] = [:],
body: (any Encodable)? = nil
    ) async throws -> T {
        var components = URLComponents(
            url: BackendConfig.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )
        if !query.isEmpty {
            components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components?.url else {
            throw BackendError.invalidURL // ← URL gagal dibangun
        }

        var request = URLRequest(url: url)
        request.httpMethod = method // ← ubah method HTTP
        request.setValue("application/json", forHTTPHeaderField: "Accept") // ← accept header
        if let token = BackendConfig.idToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // ← auth header
        }
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type") // ← body JSON
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw BackendError.unknown("invalid response type")
        }

        guard (200...299).contains(http.statusCode) else {
            throw error(fromHTTP: http.statusCode, data: data)
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom(Self.decodeRFC3339Date) // ← tanggal RFC3339 (dengan/utan fraksi detik) dari Go
            return try decoder.decode(T.self, from: data)
        } catch {
            throw BackendError.decoding(String(describing: error))
        }
    }

    // MARK: - RFC3339 Decoding

    /// Go `time.Time` emit RFC3339: "2026-09-08T06:17:35.217954Z" (fraksi
    /// detik opsional). `.iso8601` bawaan gagal kalau ada mikrodetik, jadi parse
    /// manual dengan dua formatter (dengan/utan fraksi).
    private static let rfc3339Full: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // ← dengan fraksi
        return f
    }()
    private static let rfc3339Plain: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter() // ← default withInternetDateTime (tanpa fraksi)
        return f
    }()

    private static func decodeRFC3339Date(_ decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        if let date = rfc3339Full.date(from: raw) ?? rfc3339Plain.date(from: raw) {
            return date
        }
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Cannot decode date: \(raw)"
        )
    }

    /// Request tanpa response body (contoh: delete/toggle), kembalikan status sukses.
    func requestNoBody(_ method: String, _ path: String, query: [String: String] = [:], body: (any Encodable)? = nil) async throws {
        let _: EmptyResponse = try await request(method, path, query: query, body: body)
    }

    // MARK: - Error Mapping

    private func error(fromHTTP status: Int, data: Data) -> BackendError {
        let message = (try? JSONDecoder().decode(ErrorBody.self, from: data).error) ?? "HTTP \(status)"
        switch status {
        case 400: return .badRequest(message)
        case 401, 403: return .unauthorized(message)
        case 404: return .notFound(message)
        case 409: return .conflict(message)
        case 500...599: return .server(status)
        default: return .unknown(message)
        }
    }
}

// MARK: - Error Type

enum BackendError: LocalizedError {
    case invalidURL
    case badRequest(String)
    case unauthorized(String)
    case notFound(String)
    case conflict(String)
    case server(Int)
    case decoding(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL tidak valid"
        case .badRequest(let m), .unauthorized(let m), .notFound(let m), .conflict(let m), .unknown(let m):
            return m
        case .server(let code): return "Server error (\(code))"
        case .decoding(let d): return "Gagal decode respons: \(d)"
        }
    }
}

// MARK: - Helpers

private struct ErrorBody: Decodable {
    let error: String
}

private struct EmptyResponse: Decodable {}