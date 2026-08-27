//
//  APIEndpoint.swift
//  netflix-clone
//

import Foundation

/// Defines all TMDB API endpoints.
enum APIEndpoint {

    // MARK: - Trending

    case trending(mediaType: String, timeWindow: String) // ← /trending/{media_type}/{time_window}

    // MARK: - Movie

    case popularMovies                        // ← /movie/popular
    case topRatedMovies                       // ← /movie/top_rated
    case nowPlayingMovies                     // ← /movie/now_playing
    case upcomingMovies                       // ← /movie/upcoming
    case movieDetail(movieId: Int)            // ← /movie/{movie_id}
    case movieCredits(movieId: Int)           // ← /movie/{movie_id}/credits
    case movieVideos(movieId: Int)            // ← /movie/{movie_id}/videos
    case movieRecommendations(movieId: Int)   // ← /movie/{movie_id}/recommendations
    case movieSimilar(movieId: Int)           // ← /movie/{movie_id}/similar

    // MARK: - TV

    case popularTV                            // ← /tv/popular
    case topRatedTV                           // ← /tv/top_rated
    case airingTodayTV                        // ← /tv/airing_today
    case onTheAirTV                           // ← /tv/on_the_air
    case tvDetail(seriesId: Int)              // ← /tv/{series_id}
    case tvCredits(seriesId: Int)             // ← /tv/{series_id}/credits
    case tvVideos(seriesId: Int)              // ← /tv/{series_id}/videos
    case tvRecommendations(seriesId: Int)     // ← /tv/{series_id}/recommendations
    case tvSimilar(seriesId: Int)             // ← /tv/{series_id}/similar
    case tvSeason(seriesId: Int, seasonNumber: Int) // ← /tv/{series_id}/season/{season_number}

    // MARK: - Search

    case searchMulti(query: String)           // ← /search/multi?query=
    case searchMovie(query: String)           // ← /search/movie?query=
    case searchTV(query: String)              // ← /search/tv?query=

    // MARK: - Discover

    case discoverMovie(genreId: Int?, sortBy: String?) // ← /discover/movie

    // MARK: - Genre

    case movieGenres                          // ← /genre/movie/list
    case tvGenres                             // ← /genre/tv/list

    // MARK: - Path Builder

    var path: String {
        switch self {
        // Trending
        case .trending(let mediaType, let timeWindow):
            return "/trending/\(mediaType)/\(timeWindow)"

        // Movie
        case .popularMovies: return "/movie/popular"
        case .topRatedMovies: return "/movie/top_rated"
        case .nowPlayingMovies: return "/movie/now_playing"
        case .upcomingMovies: return "/movie/upcoming"
        case .movieDetail(let id): return "/movie/\(id)"
        case .movieCredits(let id): return "/movie/\(id)/credits"
        case .movieVideos(let id): return "/movie/\(id)/videos"
        case .movieRecommendations(let id): return "/movie/\(id)/recommendations"
        case .movieSimilar(let id): return "/movie/\(id)/similar"

        // TV
        case .popularTV: return "/tv/popular"
        case .topRatedTV: return "/tv/top_rated"
        case .airingTodayTV: return "/tv/airing_today"
        case .onTheAirTV: return "/tv/on_the_air"
        case .tvDetail(let id): return "/tv/\(id)"
        case .tvCredits(let id): return "/tv/\(id)/credits"
        case .tvVideos(let id): return "/tv/\(id)/videos"
        case .tvRecommendations(let id): return "/tv/\(id)/recommendations"
        case .tvSimilar(let id): return "/tv/\(id)/similar"
        case .tvSeason(let seriesId, let season): return "/tv/\(seriesId)/season/\(season)"

        // Search
        case .searchMulti: return "/search/multi"
        case .searchMovie: return "/search/movie"
        case .searchTV: return "/search/tv"

        // Discover
        case .discoverMovie: return "/discover/movie"

        // Genre
        case .movieGenres: return "/genre/movie/list"
        case .tvGenres: return "/genre/tv/list"
        }
    }

    // MARK: - Query Parameters

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []

        // ← tambah parameter query per endpoint
        switch self {
        case .trending:
            break // no query params needed

        case .popularMovies, .topRatedMovies, .nowPlayingMovies, .upcomingMovies:
            items.append(URLQueryItem(name: "language", value: "en-US")) // ← ubah bahasa
            items.append(URLQueryItem(name: "page", value: "1")) // ← ubah halaman

        case .movieDetail, .movieCredits, .movieVideos, .movieRecommendations, .movieSimilar:
            break // path-only

        case .popularTV, .topRatedTV, .airingTodayTV, .onTheAirTV:
            items.append(URLQueryItem(name: "language", value: "en-US"))
            items.append(URLQueryItem(name: "page", value: "1"))

        case .tvDetail, .tvCredits, .tvVideos, .tvRecommendations, .tvSimilar, .tvSeason:
            break

        case .searchMulti(let query), .searchMovie(let query), .searchTV(let query):
            items.append(URLQueryItem(name: "query", value: query))
            items.append(URLQueryItem(name: "language", value: "en-US"))
            items.append(URLQueryItem(name: "page", value: "1"))

        case .discoverMovie(let genreId, let sortBy):
            items.append(URLQueryItem(name: "sort_by", value: sortBy ?? APIConfig.SortBy.popularityDesc))
            items.append(URLQueryItem(name: "page", value: "1"))
            if let genreId {
                items.append(URLQueryItem(name: "with_genres", value: "\(genreId)"))
            }

        case .movieGenres, .tvGenres:
            items.append(URLQueryItem(name: "language", value: "en-US"))
        }

        return items
    }

    // MARK: - Full URL

    func url() throws -> URL {
        var components = URLComponents(string: APIConfig.tmdbBaseURL + path) // ← build URL
        components?.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components?.url else {
            throw APIError.invalidURL // ← URL gagal dibuat
        }
        return url
    }
}
