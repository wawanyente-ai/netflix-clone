//
//  VideoDTO.swift
//  netflix-clone
//

import Foundation

/// TMDB Video DTO — trailer, teaser, clip, etc.
struct VideoDTO: Codable {
    let id: String
    let key: String          // ← YouTube video key (e.g. "dQw4w9WgXcQ")
    let name: String
    let site: String         // ← "YouTube" or "Vimeo"
    let type: String         // ← "Trailer", "Teaser", "Clip", "Featurette", "Behind the Scenes"
    let official: Bool?

    enum CodingKeys: String, CodingKey {
        case id, key, name, site, type, official
    }
}

/// TMDB Video list response.
struct VideoListResponse: Codable {
    let results: [VideoDTO]
}

/// TMDB Multi-search result — can be movie, TV, or person.
struct MultiSearchResultDTO: Codable {
    let mediaType: String    // ← "movie", "tv", "person"
    let id: Int
    let title: String?       // ← for movies
    let name: String?        // ← for TV and person
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?
    let releaseDate: String? // ← for movies
    let firstAirDate: String? // ← for TV
    let profilePath: String? // ← for person
    let knownForDepartment: String? // ← for person

    enum CodingKeys: String, CodingKey {
        case id, title, name, overview
        case mediaType = "media_type"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case profilePath = "profile_path"
        case knownForDepartment = "known_for_department"
    }

    /// Display name — title for movies, name for TV/person.
    var displayName: String { title ?? name ?? "Unknown" } // ← fallback nama
}

/// TMDB Multi-search list response.
struct MultiSearchResponse: Codable {
    let page: Int
    let results: [MultiSearchResultDTO]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
