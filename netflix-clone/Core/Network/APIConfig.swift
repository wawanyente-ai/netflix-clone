//
//  APIConfig.swift
//  netflix-clone
//

import Foundation

/// Konfigurasi shared untuk penyusun URL gambar TMDB + konstanta API.
/// Semua request data API lewat backend (`/v1/content/...`), jadi token TMDB
/// tidak pernah ada di binary iOS. Yang dipakai langsung cuma CDN image TMDB.
enum APIConfig {

    // MARK: - TMDB Image CDN

    static let tmdbImageBaseURL = "https://image.tmdb.org/t/p/"  // ← ubah base URL gambar

    // MARK: - Image Sizes

    enum ImageSize {
        static let poster = "w500"  // ← ubah ukuran poster
        static let backdrop = "w1280"  // ← ubah ukuran backdrop
        static let profile = "w185"  // ← ubah ukuran profile
        static let thumbnail = "w342"  // ← ubah ukuran thumbnail
    }

    // MARK: - API Values

    enum TimeWindow {
        static let week = "week"  // ← trending mingguan
    }

    enum SortBy {
        static let popularityDesc = "popularity.desc"  // ← urut popularitas menurun
    }
}