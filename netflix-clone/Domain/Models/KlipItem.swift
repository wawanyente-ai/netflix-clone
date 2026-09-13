//
//  KlipItem.swift
//  netflix-clone
//

import Foundation

/// Model for Klip tab clip items.
struct KlipItem: Identifiable {
    let id: Int
    let mediaId: Int        // ← TMDB id (buat My List / detail / progress)
    let mediaType: String   // ← "movie" | "tv"
    let title: String
    let subtitle: String
    let category: String
    let posterPath: String

    /// Poster image URL for AsyncImage.
    var posterURL: URL? {
        ImageURLBuilder.posterURL(from: posterPath)
    }

    /// Convert ke MediaItem untuk navigasi detail/player + My List backend.
    var mediaItem: MediaItem {
        MediaItem(
            id: mediaId,
            title: title,
            overview: "",
            posterPath: posterPath.isEmpty ? nil : posterPath,
            backdropPath: nil,
            voteAverage: 0,
            releaseDate: subtitle,
            mediaType: mediaType == "tv" ? .tv : .movie,
            genreIds: [],
            runtime: nil
        )
    }
}
