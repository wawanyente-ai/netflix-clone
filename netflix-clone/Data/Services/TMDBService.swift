//
//  TMDBService.swift
//  netflix-clone
//

import Foundation

/// Service layer for all TMDB API calls.
/// Uses APIClient for networking and returns raw DTOs.
/// Mappers convert DTOs → Domain Models at the ViewModel layer.
actor TMDBService {

    static let shared = TMDBService() // ← singleton shared instance

    private let client = APIClient.shared

    // MARK: - Trending

    /// Fetch trending content (movies + TV mixed).
    func fetchTrending(timeWindow: String = APIConfig.TimeWindow.week) async throws -> [MultiSearchResultDTO] {
        let response: MultiSearchResponse = try await client.fetch(
            .trending(mediaType: APIConfig.MediaType.all, timeWindow: timeWindow)
        )
        return response.results // ← list trending items
    }

    // MARK: - Movies

    /// Fetch popular movies.
    func fetchPopularMovies() async throws -> [MovieDTO] {
        let response: MovieListResponse = try await client.fetch(.popularMovies)
        return response.results // ← list movie populer
    }

    /// Fetch top rated movies.
    func fetchTopRatedMovies() async throws -> [MovieDTO] {
        let response: MovieListResponse = try await client.fetch(.topRatedMovies)
        return response.results // ← list movie top rated
    }

    /// Fetch now playing movies.
    func fetchNowPlayingMovies() async throws -> [MovieDTO] {
        let response: MovieListResponse = try await client.fetch(.nowPlayingMovies)
        return response.results // ← list movie now playing
    }

    /// Fetch upcoming movies.
    func fetchUpcomingMovies() async throws -> [MovieDTO] {
        let response: MovieListResponse = try await client.fetch(.upcomingMovies)
        return response.results // ← list movie upcoming
    }

    /// Fetch movie detail with credits, videos, recommendations.
    func fetchMovieDetail(id: Int) async throws -> MovieDetailDTO {
        try await client.fetch(.movieDetail(movieId: id)) // ← detail movie
    }

    /// Fetch movie credits (cast + crew).
    func fetchMovieCredits(id: Int) async throws -> CreditsDTO {
        try await client.fetch(.movieCredits(movieId: id)) // ← cast & crew
    }

    /// Fetch movie videos (trailers, teasers).
    func fetchMovieVideos(id: Int) async throws -> [VideoDTO] {
        let response: VideoListResponse = try await client.fetch(.movieVideos(movieId: id))
        return response.results // ← list video
    }

    /// Fetch movie recommendations.
    func fetchMovieRecommendations(id: Int) async throws -> [MovieDTO] {
        let response: MovieListResponse = try await client.fetch(.movieRecommendations(movieId: id))
        return response.results // ← rekomendasi movie
    }

    /// Fetch similar movies.
    func fetchMovieSimilar(id: Int) async throws -> [MovieDTO] {
        let response: MovieListResponse = try await client.fetch(.movieSimilar(movieId: id))
        return response.results // ← movie serupa
    }

    // MARK: - TV Shows

    /// Fetch popular TV shows.
    func fetchPopularTV() async throws -> [TVShowDTO] {
        let response: TVShowListResponse = try await client.fetch(.popularTV)
        return response.results // ← list TV populer
    }

    /// Fetch top rated TV shows.
    func fetchTopRatedTV() async throws -> [TVShowDTO] {
        let response: TVShowListResponse = try await client.fetch(.topRatedTV)
        return response.results // ← list TV top rated
    }

    /// Fetch TV show detail.
    func fetchTVDetail(id: Int) async throws -> TVShowDetailDTO {
        try await client.fetch(.tvDetail(seriesId: id)) // ← detail TV
    }

    /// Fetch TV season detail with episodes.
    func fetchTVSeason(seriesId: Int, seasonNumber: Int) async throws -> SeasonDetailDTO {
        try await client.fetch(.tvSeason(seriesId: seriesId, seasonNumber: seasonNumber)) // ← detail season
    }

    /// Fetch TV videos (trailers).
    func fetchTVVideos(id: Int) async throws -> [VideoDTO] {
        let response: VideoListResponse = try await client.fetch(.tvVideos(seriesId: id))
        return response.results // ← list video TV
    }

    /// Fetch TV recommendations.
    func fetchTVRecommendations(id: Int) async throws -> [TVShowDTO] {
        let response: TVShowListResponse = try await client.fetch(.tvRecommendations(seriesId: id))
        return response.results // ← rekomendasi TV
    }

    // MARK: - Search

    /// Multi-search (movies, TV, person).
    func searchMulti(query: String) async throws -> [MultiSearchResultDTO] {
        let response: MultiSearchResponse = try await client.fetch(.searchMulti(query: query))
        return response.results // ← hasil pencarian
    }

    // MARK: - Discover

    /// Discover movies with optional genre filter.
    func discoverMovies(genreId: Int? = nil, sortBy: String = APIConfig.SortBy.popularityDesc) async throws -> [MovieDTO] {
        let response: MovieListResponse = try await client.fetch(.discoverMovie(genreId: genreId, sortBy: sortBy))
        return response.results // ← hasil discover
    }

    // MARK: - Genres

    /// Fetch movie genres.
    func fetchMovieGenres() async throws -> [GenreDTO] {
        let response: GenreListResponse = try await client.fetch(.movieGenres)
        return response.genres // ← list genre movie
    }

    /// Fetch TV genres.
    func fetchTVGenres() async throws -> [GenreDTO] {
        let response: GenreListResponse = try await client.fetch(.tvGenres)
        return response.genres // ← list genre TV
    }
}
