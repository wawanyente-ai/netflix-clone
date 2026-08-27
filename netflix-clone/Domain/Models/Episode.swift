//
//  Episode.swift
//  netflix-clone
//

import Foundation

/// Model for episode list items.
/// Extended with TMDB fields: still image, air date, episode number.
struct Episode: Identifiable {
    let id: String                         // ← ID (String untuk backward compat)
    let tmdbId: Int?                       // ← TMDB episode ID
    let title: String                      // ← judul episode
    let duration: String                   // ← durasi (formatted)
    let synopsis: String                   // ← sinopsis
    let stillPath: String?                 // ← path gambar still (untuk AsyncImage)
    let airDate: String?                   // ← tanggal tayang
    let episodeNumber: Int?                // ← nomor episode
    let seasonNumber: Int?                 // ← nomor season

    /// Still image URL for AsyncImage.
    var stillURL: URL? {
        ImageURLBuilder.thumbnailURL(from: stillPath) // ← build still URL
    }
}
