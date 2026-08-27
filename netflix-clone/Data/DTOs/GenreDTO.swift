//
//  GenreDTO.swift
//  netflix-clone
//

import Foundation

/// TMDB Genre DTO — movie or TV genre.
struct GenreDTO: Codable {
    let id: Int
    let name: String
}

/// TMDB Genre list response.
struct GenreListResponse: Codable {
    let genres: [GenreDTO]
}
