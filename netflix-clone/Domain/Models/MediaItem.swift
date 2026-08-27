//
//  MediaItem.swift
//  netflix-clone
//

import Foundation

/// Unified model for movies and TV shows displayed in rails/grids.
/// Maps from `MovieDTO` or `TVShowDTO` via mappers.
struct MediaItem: Identifiable, Equatable {
    let id: Int                            // ← TMDB ID (Int, bukan String)
    let title: String                      // ← judul film/TV
    let overview: String                   // ← sinopsis
    let posterPath: String?                // ← path gambar poster (untuk AsyncImage)
    let backdropPath: String?              // ← path gambar backdrop (untuk hero)
    let voteAverage: Double                // ← rating (0-10)
    let releaseDate: String                // ← tanggal rilis / first air date
    let mediaType: MediaType               // ← "movie" atau "tv"
    let genreIds: [Int]                    // ← ID genre
    let runtime: Int?                      // ← durasi menit (movie only)

    /// Media type enum.
    enum MediaType: String {
        case movie
        case tv
    }

    /// Poster image URL for AsyncImage.
    var posterURL: URL? {
        ImageURLBuilder.posterURL(from: posterPath) // ← build poster URL
    }

    /// Backdrop image URL for AsyncImage.
    var backdropURL: URL? {
        ImageURLBuilder.backdropURL(from: backdropPath) // ← build backdrop URL
    }

    /// Formatted year from release date.
    var year: String {
        String(releaseDate.prefix(4)) // ← ambil 4 karakter pertama (tahun)
    }

    /// Formatted rating string.
    var ratingString: String {
        String(format: "%.1f", voteAverage) // ← format rating 1 decimal
    }

    /// Formatted runtime string.
    var runtimeString: String {
        guard let runtime else { return "" }
        let hours = runtime / 60 // ← hitung jam
        let minutes = runtime % 60 // ← hitung sisa menit
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m" // ← format durasi
    }
}
