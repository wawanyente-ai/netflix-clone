//
//  TVShowDetailDTO.swift
//  netflix-clone
//

import Foundation

/// TMDB TV Show Detail DTO — extended TV data with seasons, episodes, credits.
struct TVShowDetailDTO: Codable {
    let id: Int
    let name: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let firstAirDate: String?
    let genres: [GenreDTO]?
    let seasons: [SeasonDTO]?
    let credits: CreditsDTO?
    let videos: VideoListResponse?
    let recommendations: TVShowListResponse?
    let similar: TVShowListResponse?
    let tagline: String?
    let status: String?
    let numberOfSeasons: Int?
    let numberOfEpisodes: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, overview, genres, seasons, credits, videos
        case recommendations, similar, tagline, status
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case firstAirDate = "first_air_date"
        case numberOfSeasons = "number_of_seasons"
        case numberOfEpisodes = "number_of_episodes"
    }
}

/// TMDB Season DTO.
struct SeasonDTO: Codable {
    let id: Int
    let name: String
    let overview: String?
    let seasonNumber: Int
    let episodeCount: Int?
    let airDate: String?
    let posterPath: String?

    enum CodingKeys: String, CodingKey {
        case id, name, overview
        case seasonNumber = "season_number"
        case episodeCount = "episode_count"
        case airDate = "air_date"
        case posterPath = "poster_path"
    }
}

/// TMDB Season Detail DTO — includes episodes.
struct SeasonDetailDTO: Codable {
    let id: Int
    let name: String
    let seasonNumber: Int
    let episodes: [TMDBEpisodeDTO]

    enum CodingKeys: String, CodingKey {
        case id, name, episodes
        case seasonNumber = "season_number"
    }
}
