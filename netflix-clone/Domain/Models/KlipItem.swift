//
//  KlipItem.swift
//  netflix-clone
//

import Foundation

/// Model for Klip tab clip items.
struct KlipItem: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let category: String
    let posterPath: String

    /// Poster image URL for AsyncImage.
    var posterURL: URL? {
        ImageURLBuilder.posterURL(from: posterPath)
    }
}
