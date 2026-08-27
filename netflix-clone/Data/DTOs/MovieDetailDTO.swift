//
//  MovieDetailDTO.swift
//  netflix-clone
//

import Foundation

/// TMDB Movie Detail DTO — extended movie data with credits, videos, recommendations.
struct MovieDetailDTO: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let releaseDate: String?
    let runtime: Int?
    let genres: [GenreDTO]?
    let credits: CreditsDTO?
    let videos: VideoListResponse?
    let recommendations: MovieListResponse?
    let similar: MovieListResponse?
    let tagline: String?
    let status: String?
    let homepage: String?

    enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, genres, credits, videos
        case recommendations, similar, tagline, status, homepage
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }
}

/// TMDB Credits DTO — cast and crew.
struct CreditsDTO: Codable {
    let cast: [CastDTO]?
    let crew: [CrewDTO]?
}

/// TMDB Cast member.
struct CastDTO: Codable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?
    let order: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, character, order
        case profilePath = "profile_path"
    }
}

/// TMDB Crew member.
struct CrewDTO: Codable {
    let id: Int
    let name: String
    let job: String?
    let department: String?
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id, name, job, department
        case profilePath = "profile_path"
    }
}
