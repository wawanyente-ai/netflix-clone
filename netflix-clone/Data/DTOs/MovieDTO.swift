//
//  MovieDTO.swift
//  netflix-clone
//

import Foundation

/// TMDB Movie DTO — matches movie list response structure.
/// Used for trending, popular, top rated, now playing, upcoming, discover, search results.
struct MovieDTO: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let releaseDate: String?
    let genreIds: [Int]?
    let mediaType: String? // ← "movie" from trending/search, nil from movie-specific endpoints
    let adult: Bool
    let originalLanguage: String?
    let popularity: Double?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, title, overview, adult, popularity
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case genreIds = "genre_ids"
        case mediaType = "media_type"
        case originalLanguage = "original_language"
        case voteCount = "vote_count"
    }
}

/// TMDB paginated list response for movies.
struct MovieListResponse: Codable {
    let page: Int
    let results: [MovieDTO]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
