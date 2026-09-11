//
//  TMDBService.swift
//  netflix-clone
//

import Foundation

/// Service layer for all TMDB API calls.
/// Routes through the Go backend proxy (`/v1/content/...`) server-side, keeping
/// the TMDB access token out of the iOS binary. Returns the same DTOs as TMDB
/// because the backend passes through raw TMDB JSON.
actor TMDBService {

    static let shared = TMDBService() // ← singleton shared instance

    private let client = BackendClient.shared

    // MARK: - Trending

    /// Fetch trending content (movies + TV mixed).
    func fetchTrending(timeWindow: String = APIConfig.TimeWindow.week) async throws -> [MultiSearchResultDTO] {
        let response: MultiSearchResponse = try await client.request(
            "GET",
            "/v1/content/trending",
            query: ["time_window": timeWindow]
        )
        return response.results // ← list trending items
    }

    // MARK: - Movies

    /// Fetch popular movies.
    func fetchPopularMovies() async throws -> [MovieDTO] {
        let response: MovieListResponse = try await client.request("GET", "/v1/content/movie/list/popular")
        return response.results // ← list movie populer
    }

    /// Fetch top rated movies.
    func fetchTopRatedMovies() async throws -> [MovieDTO] {
        let response: MovieListResponse = try await client.request("GET", "/v1/content/movie/list/top_rated")
        return response.results // ← list movie top rated
    }

    /// Fetch now playing movies.
    func fetchNowPlayingMovies() async throws -> [MovieDTO] {
        let response: MovieListResponse = try await client.request("GET", "/v1/content/movie/list/now_playing")
        return response.results // ← list movie now playing
    }

    /// Fetch upcoming movies.
    func fetchUpcomingMovies() async throws -> [MovieDTO] {
        let response: MovieListResponse = try await client.request("GET", "/v1/content/movie/list/upcoming")
        return response.results // ← list movie upcoming
    }

    /// Fetch movie detail (includes credits + videos + recommendations).
    func fetchMovieDetail(id: Int) async throws -> MovieDetailDTO {
        try await client.request("GET", "/v1/content/movie/data/\(id)") // ← detail movie
    }

    /// Fetch movie credits via detail (backend merges credits into detail response).
    func fetchMovieCredits(id: Int) async throws -> CreditsDTO {
        let detail: MovieDetailDTO = try await client.request("GET", "/v1/content/movie/data/\(id)")
        return detail.credits ?? CreditsDTO(cast: nil, crew: nil) // ← cast & crew dari detail
    }

    /// Fetch movie videos (trailers, teasers).
    func fetchMovieVideos(id: Int) async throws -> [VideoDTO] {
        let response: VideoListResponse = try await client.request("GET", "/v1/content/movie/data/\(id)/videos")
        return response.results // ← list video
    }

    /// Fetch movie recommendations.
    func fetchMovieRecommendations(id: Int) async throws -> [MovieDTO] {
        let response: MovieListResponse = try await client.request("GET", "/v1/content/movie/data/\(id)/recommendations")
        return response.results // ← rekomendasi movie
    }

    /// Fetch similar movies (via recommendations proxy).
    func fetchMovieSimilar(id: Int) async throws -> [MovieDTO] {
        let response: MovieListResponse = try await client.request("GET", "/v1/content/movie/data/\(id)/recommendations")
        return response.results // ← movie serupa (routed ke recommendations)
    }

    // MARK: - TV Shows

    /// Fetch popular TV shows.
    func fetchPopularTV() async throws -> [TVShowDTO] {
        let response: TVShowListResponse = try await client.request("GET", "/v1/content/tv/list/popular")
        return response.results // ← list TV populer
    }

    /// Fetch top rated TV shows.
    func fetchTopRatedTV() async throws -> [TVShowDTO] {
        let response: TVShowListResponse = try await client.request("GET", "/v1/content/tv/list/top_rated")
        return response.results // ← list TV top rated
    }

    /// Fetch TV show detail (includes credits + videos + recommendations).
    func fetchTVDetail(id: Int) async throws -> TVShowDetailDTO {
        try await client.request("GET", "/v1/content/tv/data/\(id)") // ← detail TV
    }

    /// Fetch TV season detail with episodes.
    func fetchTVSeason(seriesId: Int, seasonNumber: Int) async throws -> SeasonDetailDTO {
        try await client.request("GET", "/v1/content/tv/data/\(seriesId)/season/\(seasonNumber)") // ← detail season
    }

    /// Fetch TV videos (trailers).
    func fetchTVVideos(id: Int) async throws -> [VideoDTO] {
        let response: VideoListResponse = try await client.request("GET", "/v1/content/tv/data/\(id)/videos")
        return response.results // ← list video TV
    }

    /// Fetch TV recommendations.
    func fetchTVRecommendations(id: Int) async throws -> [TVShowDTO] {
        let response: TVShowListResponse = try await client.request("GET", "/v1/content/tv/data/\(id)/recommendations")
        return response.results // ← rekomendasi TV
    }

    // MARK: - Search

    /// Multi-search (movies, TV, person).
    func searchMulti(query: String) async throws -> [MultiSearchResultDTO] {
        let response: MultiSearchResponse = try await client.request(
            "GET",
            "/v1/content/search",
            query: ["query": query]
        )
        return response.results // ← hasil pencarian
    }

    // MARK: - Discover

    /// Discover movies with optional genre filter.
    func discoverMovies(genreId: Int? = nil, sortBy: String = APIConfig.SortBy.popularityDesc) async throws -> [MovieDTO] {
        var query: [String: String] = ["sort": sortBy]
        if let genreId {
            query["genre"] = "\(genreId)" // ← filter genre
        }
        let response: MovieListResponse = try await client.request("GET", "/v1/content/discover", query: query)
        return response.results // ← hasil discover
    }

    // MARK: - Genres

    /// Fetch movie genres.
    func fetchMovieGenres() async throws -> [GenreDTO] {
        let response: GenreListResponse = try await client.request("GET", "/v1/content/genres/movie")
        return response.genres // ← list genre movie
    }

    /// Fetch TV genres.
    func fetchTVGenres() async throws -> [GenreDTO] {
        let response: GenreListResponse = try await client.request("GET", "/v1/content/genres/tv")
        return response.genres // ← list genre TV
    }
}