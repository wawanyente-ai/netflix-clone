//
//  APIConfig.swift
//  netflix-clone
//

import Foundation

/// Central configuration for TMDB API.
/// Replace `accessToken` with your real token.
enum APIConfig {

    // MARK: - TMDB

    static let tmdbBaseURL = "https://api.themoviedb.org/3"  // ← ubah base URL API
    static let tmdbImageBaseURL = "https://image.tmdb.org/t/p/"  // ← ubah base URL gambar

    /// TMDB Bearer token. Replace with your real token.
    /// Get one at: https://www.themoviedb.org/settings/api
    static let accessToken =
        "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzMjAwOWZiZmVlMWY1YWY3MGNhZDRhMDMxYmM2MDNiOSIsIm5iZiI6MTc4NzcyNjI3NC4wMzAwMDAyLCJzdWIiOiI2YThlODljMjY1NGZiYjZjZTQxMTIwYmUiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.doMBQpujh033-b-hMi0MAYukOZ_0rjRaGPipLau-ZLA"  // ← MASUKKAN TOKEN TMDB KAMU DI SINI

    // MARK: - Image Sizes

    enum ImageSize {
        static let poster = "w500"  // ← ubah ukuran poster
        static let backdrop = "w1280"  // ← ubah ukuran backdrop
        static let profile = "w185"  // ← ubah ukuran profile
        static let logo = "w92"  // ← ubah ukuran logo
        static let thumbnail = "w342"  // ← ubah ukuran thumbnail
    }

    // MARK: - Headers

    static var authorizationHeader: String { "Bearer \(accessToken)" }  // ← jangan ubah format

    // MARK: - API Values

    enum TimeWindow {
        static let day = "day"  // ← trending harian
        static let week = "week"  // ← trending mingguan
    }

    enum MediaType {
        static let movie = "movie"  // ← tipe movie
        static let tv = "tv"  // ← tipe TV show
        static let person = "person"  // ← tipe person/actor
        static let all = "all"  // ← semua tipe
    }

    enum SortBy {
        static let popularityDesc = "popularity.desc"  // ← urut popularitas menurun
        static let voteAverageDesc = "vote_average.desc"  // ← urut rating menurun
        static let releaseDateDesc = "release_date.desc"  // ← urut tanggal rilis menurun
    }
}
