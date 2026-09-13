//
//  MovieRepository.swift
//  netflix-clone
//
// Repository pattern implementing Stale-While-Revalidate (SWR) caching.
//  - Cache ada: return data cache langsung (stale/fresh), refresh di background kalau stale
//  - Belum ada cache: fetch network (loading state)
//
import Foundation

// MARK: - Repository Protocol

protocol MovieRepository: Sendable {
    /// Home data dari cache (stale atau fresh). Nil kalau belum pernah fetch.
    func getCachedHomeData() async -> HomeData?

    /// True kalau cache pernah tersimpan tapi sudah melewati TTL (perlu revalidate).
    func isCacheStale() async -> Bool

    /// Force refresh dari network, tulis ulang cache, return data terbaru.
    func refreshHome() async throws -> HomeData
}

// MARK: - Home Data Model

struct HomeData: Sendable {
    let trending: [MediaItem]
    let popularMovies: [MediaItem]
    let topRatedMovies: [MediaItem]
    let popularTV: [MediaItem]

    var heroItem: MediaItem? { trending.first }
}

// MARK: - Live Repository with SWR

actor LiveMovieRepository: MovieRepository {
    // MARK: - Dependencies

    private let tmdbService: TMDBService
    private let localDataSource: LocalMovieDataSource

    // MARK: - In-Flight Request Tracking

    private var ongoingRefresh: Task<HomeData, Error>?

    // MARK: - Init

    init(
        tmdbService: TMDBService = .shared,
        localDataSource: LocalMovieDataSource = LocalMovieDataSource()
    ) {
        self.tmdbService = tmdbService
        self.localDataSource = localDataSource
    }

    // MARK: - Cached Data (stale-ok)

    func getCachedHomeData() async -> HomeData? {
        async let trending = localDataSource.cachedMovies(for: "trending")
        async let popular = localDataSource.cachedMovies(for: "popular")
        async let topRated = localDataSource.cachedMovies(for: "topRated")
        async let popularTV = localDataSource.cachedMovies(for: "popularTV")

        let (trendingData, popularData, topRatedData, popularTVData) = await (
            trending, popular, topRated, popularTV
        )
        guard let trendingData, let popularData, let topRatedData, let popularTVData else {
            return nil
        }

        return HomeData(
            trending: trendingData,
            popularMovies: popularData,
            topRatedMovies: topRatedData,
            popularTV: popularTVData
        )
    }

    func isCacheStale() async -> Bool {
        async let trending = localDataSource.isStale(for: "trending")
        async let popular = localDataSource.isStale(for: "popular")
        async let topRated = localDataSource.isStale(for: "topRated")
        async let popularTV = localDataSource.isStale(for: "popularTV")

        let stale = await (trending, popular, topRated, popularTV)
        return stale.0 || stale.1 || stale.2 || stale.3
    }

    // MARK: - Force Refresh

    func refreshHome() async throws -> HomeData {
        // Prevent duplicate simultaneous refreshes
        if let ongoing = ongoingRefresh {
            return try await ongoing.value
        }

        let refreshTask = Task {
            try await performRefresh()
        }

        ongoingRefresh = refreshTask

        defer {
            ongoingRefresh = nil
        }

        return try await refreshTask.value
    }

    // MARK: - Private: Actual Fetch

    private func performRefresh() async throws -> HomeData {
        // Fetch all sections in parallel
        async let trendingDTOs = tmdbService.fetchTrending()
        async let popularDTOs = tmdbService.fetchPopularMovies()
        async let topRatedDTOs = tmdbService.fetchTopRatedMovies()
        async let popularTVDTOs = tmdbService.fetchPopularTV()

        let (trending, popular, topRated, popularTV) = try await (
            trendingDTOs,
            popularDTOs,
            topRatedDTOs,
            popularTVDTOs
        )

        // Map DTOs to domain models
        let trendingItems = MediaItemMapper.fromSearchResults(trending)
        let popularItems = MediaItemMapper.fromMovies(popular)
        let topRatedItems = MediaItemMapper.fromMovies(topRated)
        let popularTVItems = MediaItemMapper.fromTVShows(popularTV)

        // Persist to cache
        await localDataSource.saveMovies(trendingItems, for: "trending")
        await localDataSource.saveMovies(popularItems, for: "popular")
        await localDataSource.saveMovies(topRatedItems, for: "topRated")
        await localDataSource.saveMovies(popularTVItems, for: "popularTV")

        return HomeData(
            trending: trendingItems,
            popularMovies: popularItems,
            topRatedMovies: topRatedItems,
            popularTV: popularTVItems
        )
    }
}