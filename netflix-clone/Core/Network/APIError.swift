//
//  APIError.swift
//  netflix-clone
//

import Foundation

/// Errors that can occur during API requests.
enum APIError: Error, LocalizedError {
    case invalidURL               // ← URL tidak valid
    case networkError(Error)      // ← error jaringan
    case decodingError(Error)     // ← error decoding JSON
    case unauthorized             // ← token tidak valid / expired
    case notFound                 // ← resource tidak ditemukan
    case rateLimited              // ← terlalu banyak request
    case serverError(Int)         // ← server error (5xx)
    case unknown(String)          // ← error tidak diketahui

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL" // ← ubah pesan error
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized — check your TMDB access token" // ← ubah pesan
        case .notFound:
            return "Resource not found"
        case .rateLimited:
            return "Rate limited — try again later"
        case .serverError(let code):
            return "Server error (\(code))"
        case .unknown(let message):
            return message
        }
    }
}
