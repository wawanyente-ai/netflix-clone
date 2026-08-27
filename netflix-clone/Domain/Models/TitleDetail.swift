//
//  TitleDetail.swift
//  netflix-clone
//

import Foundation

/// Model for title detail / deep-dive screen.
/// Extended with TMDB fields: poster, backdrop, rating, trailer, genres, cast.
struct TitleDetail: Identifiable {
    let id: String                         // ← ID (String untuk backward compat)
    let tmdbId: Int?                       // ← TMDB ID (Int, untuk API calls)
    let title: String                      // ← judul
    let year: String                       // ← tahun rilis
    let rating: String                     // ← content rating (TV-MA, PG-13, dll)
    let seasonCount: String                // ← jumlah season (TV) atau durasi (movie)
    let synopsis: String                   // ← sinopsis
    let episodes: [Episode]                // ← daftar episode

    // MARK: - TMDB Fields

    let posterPath: String?                // ← path poster (untuk AsyncImage)
    let backdropPath: String?              // ← path backdrop (untuk hero)
    let voteAverage: Double                // ← rating TMDB (0-10)
    let genres: [Genre]                    // ← daftar genre
    let cast: [CastMember]                 // ← daftar cast
    let trailerKey: String?                // ← YouTube video key untuk trailer

    /// Poster image URL for AsyncImage.
    var posterURL: URL? {
        ImageURLBuilder.posterURL(from: posterPath) // ← build poster URL
    }

    /// Backdrop image URL for AsyncImage.
    var backdropURL: URL? {
        ImageURLBuilder.backdropURL(from: backdropPath) // ← build backdrop URL
    }

    /// Formatted rating string.
    var voteAverageString: String {
        String(format: "%.1f", voteAverage) // ← format rating 1 decimal
    }
}

/// Genre model.
struct Genre: Identifiable {
    let id: Int                            // ← TMDB genre ID
    let name: String                       // ← nama genre
}

/// Cast member model.
struct CastMember: Identifiable {
    let id: Int                            // ← TMDB person ID
    let name: String                       // ← nama aktor
    let character: String?                 // ← nama karakter
    let profilePath: String?               // ← path foto profil

    /// Profile image URL for AsyncImage.
    var profileURL: URL? {
        ImageURLBuilder.profileURL(from: profilePath) // ← build profile URL
    }
}
