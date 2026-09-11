//
//  APIConfig.swift
//  netflix-clone
//

import Foundation

/// Central configuration for TMDB API.
/// Replace `accessToken` with your real token.
enum APIConfig {

    // MARK: - TMDB

    static let tmdbBaseURL = "https://api.themoviedb.org/3"  // ← base URL API (tidak dipakai langsung; diproxy backend)
    static let tmdbImageBaseURL = "https://image.tmdb.org/t/p/"  // ← ubah base URL gambar

    // MARK: - Image Sizes

    enum ImageSize {
        static let poster = "w500"  // ← ubah ukuran poster
        static let backdrop = "w1280"  // ← ubah ukuran backdrop
        static let profile = "w185"  // ← ubah ukuran profile
        static let logo = "w92"  // ← ubah ukuran logo
        static let thumbnail = "w342"  // ← ubah ukuran thumbnail
    }

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
