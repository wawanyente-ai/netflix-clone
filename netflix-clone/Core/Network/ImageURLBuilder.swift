//
//  ImageURLBuilder.swift
//  netflix-clone
//

import Foundation

/// Helper to build TMDB image URLs from poster_path / backdrop_path / profile_path.
enum ImageURLBuilder {

    /// Build image URL from path and size.
    /// - Parameters:
    ///   - path: TMDB image path (e.g. "/abc123.jpg")
    ///   - size: Image size (e.g. "w500", "w1280", "original")
    /// - Returns: Full URL string, or nil if path is empty
    static func url(path: String?, size: String = APIConfig.ImageSize.poster) -> URL? {
        guard let path, !path.isEmpty else { return nil } // ← path kosong = nil
        return URL(string: APIConfig.tmdbImageBaseURL + size + path) // ← build URL
    }

    // MARK: - Convenience

    /// Poster image URL (w500).
    static func posterURL(from path: String?) -> URL? {
        url(path: path, size: APIConfig.ImageSize.poster) // ← ubah ukuran poster
    }

    /// Backdrop image URL (w1280).
    static func backdropURL(from path: String?) -> URL? {
        url(path: path, size: APIConfig.ImageSize.backdrop) // ← ubah ukuran backdrop
    }

    /// Profile image URL (w185).
    static func profileURL(from path: String?) -> URL? {
        url(path: path, size: APIConfig.ImageSize.profile) // ← ubah ukuran profile
    }

    /// Thumbnail image URL (w342).
    static func thumbnailURL(from path: String?) -> URL? {
        url(path: path, size: APIConfig.ImageSize.thumbnail) // ← ubah ukuran thumbnail
    }
}
