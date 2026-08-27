//
//  TVShowDTO.swift
//  netflix-clone
//

import Foundation

/// TMDB TV Show DTO — matches TV list response structure.
/// Used for trending TV, popular, top rated, airing today, on the air.
struct TVShowDTO: Codable {
    let id: Int
    let name: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let firstAirDate: String?
    let genreIds: [Int]?
    let mediaType: String? // ← "tv" from trending/search
    let originCountry: [String]?
    let originalLanguage: String?
    let popularity: Double?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, overview, popularity
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case firstAirDate = "first_air_date"
        case genreIds = "genre_ids"
        case mediaType = "media_type"
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
        case voteCount = "vote_count"
    }
}

/// TMDB paginated list response for TV shows.
struct TVShowListResponse: Codable {
    let page: Int
    let results: [TVShowDTO]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
