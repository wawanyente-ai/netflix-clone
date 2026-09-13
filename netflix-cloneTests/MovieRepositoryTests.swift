//
//  MovieRepositoryTests.swift
//  netflix-cloneTests
//
//  Tests for SWR caching behavior, TTL, and repository logic.
//
import Testing
@testable import netflix_clone

@Suite("MovieRepository SWR Behavior")
struct MovieRepositoryTests {
    // MARK: - Mock Dependencies

    actor MockTMDBService: TMDBService {
        var callCount = 0
        var shouldFail = false

        func fetchTrending(timeWindow: String = APIConfig.TimeWindow.week) async throws -> [MultiSearchResultDTO] {
            callCount += 1
            if shouldFail {
                throw BackendError.unknown("Mock error")
            }
            return mockSearchResults()
        }

        func fetchPopularMovies() async throws -> [MovieDTO] {
            callCount += 1
            if shouldFail {
                throw BackendError.unknown("Mock error")
            }
            return mockMovieResults()
        }

        func fetchTopRatedMovies() async throws -> [MovieDTO] {
            callCount += 1
            if shouldFail {
                throw BackendError.unknown("Mock error")
            }
            return mockMovieResults()
        }

        func fetchPopularTV() async throws -> [TVShowDTO] {
            callCount += 1
            if shouldFail {
                throw BackendError.unknown("Mock error")
            }
            return mockTVResults()
        }

        private func mockSearchResults() -> [MultiSearchResultDTO] {
            [
                MultiSearchResultDTO(id: 1, title: "Test Movie", overview: "Overview", posterPath: "/path", backdropPath: "/backdrop", voteAverage: 7.5, releaseDate: "2026-01-01", mediaType: "movie", genreIds: [1, 2])
            ]
        }

        private func mockMovieResults() -> [MovieDTO] {
            [
                MovieDTO(id: 1, title: "Test", overview: "Desc", posterPath: "/p", backdropPath: "/b", voteAverage: 7.0, releaseDate: "2026-01-01", genreIds: [1], runtime: 120)
            ]
        }

        private func mockTVResults() -> [TVShowDTO] {
            [
                TVShowDTO(id: 1, name: "Test TV", overview: "Desc", posterPath: "/p", backdropPath: "/b", voteAverage: 7.0, firstAirDate: "2026-01-01", genreIds: [1])
            ]
        }
    }

    actor MockLocalDataSource: LocalMovieDataSource {
        var storage: [String: [MediaItem]] = [:]

        func cachedMovies(for section: String) -> [MediaItem]? {
            storage[section]
        }

        func saveMovies(_ movies: [MediaItem], for section: String) {
            storage[section] = movies
        }

        func clearCache(for section: String) {
            storage.removeValue(forKey: section)
        }

        func hasFreshCache() -> Bool {
            !storage.isEmpty
        }
    }

    // MARK: - Tests

    @Test("Fresh cache returns without network request")
    async func testFreshCacheNoNetworkRequest() async throws {
        let mockService = MockTMDBService()
        let mockLocalSource = MockLocalDataSource()

        // Pre-populate cache with fresh data
        let testData = MediaItem(
            id: 1, title: "Test", overview: "Desc",
            posterPath: "/p", backdropPath: "/b",
            voteAverage: 7.0, releaseDate: "2026-01-01",
            mediaType: .movie, genreIds: [1], runtime: nil
        )
        await mockLocalSource.saveMovies([testData], for: "trending")
        await mockLocalSource.saveMovies([testData], for: "popular")
        await mockLocalSource.saveMovies([testData], for: "topRated")
        await mockLocalSource.saveMovies([testData], for: "popularTV")

        // Create repository with mock service
        let repo = LiveMovieRepository(
            tmdbService: mockService,
            localDataSource: mockLocalSource
        )

        // Call getHomeData
        let result = try await repo.getHomeData()

        // Verify: network NOT called (SWR returns cache)
        #expect(await mockService.callCount == 0)
        #expect(!result.trending.isEmpty)
    }

    @Test("No cache triggers network request")
    async func testNoCacheTriggersNetwork() async throws {
        let mockService = MockTMDBService()
        let mockLocalSource = MockLocalDataSource()

        let repo = LiveMovieRepository(
            tmdbService: mockService,
            localDataSource: mockLocalSource
        )

        // Call getHomeData with empty cache
        let result = try await repo.getHomeData()

        // Verify: network WAS called (no cache)
        #expect(await mockService.callCount == 4) // 4 parallel requests
        #expect(!result.trending.isEmpty)
    }

    @Test("Force refresh always hits network")
    async func testForceRefreshBypassesCache() async throws {
        let mockService = MockTMDBService()
        let mockLocalSource = MockLocalDataSource()

        // Pre-populate cache
        let testData = MediaItem(
            id: 1, title: "Test", overview: "Desc",
            posterPath: "/p", backdropPath: "/b",
            voteAverage: 7.0, releaseDate: "2026-01-01",
            mediaType: .movie, genreIds: [1], runtime: nil
        )
        await mockLocalSource.saveMovies([testData], for: "trending")
        await mockLocalSource.saveMovies([testData], for: "popular")
        await mockLocalSource.saveMovies([testData], for: "topRated")
        await mockLocalSource.saveMovies([testData], for: "popularTV")

        let repo = LiveMovieRepository(
            tmdbService: mockService,
            localDataSource: mockLocalSource
        )

        // Call refreshHome (force refresh)
        let result = try await repo.refreshHome()

        // Verify: network WAS called
        #expect(await mockService.callCount == 4)
        #expect(!result.trending.isEmpty)
    }

    @Test("Cache persists data across calls")
    async func testCachePersistence() async throws {
        let mockService = MockTMDBService()
        let mockLocalSource = MockLocalDataSource()

        let repo = LiveMovieRepository(
            tmdbService: mockService,
            localDataSource: mockLocalSource
        )

        // First call - network
        let result1 = try await repo.getHomeData()
        let callCount1 = await mockService.callCount

        // Second call - should use cache
        let result2 = try await repo.getHomeData()
        let callCount2 = await mockService.callCount

        // Verify: only first call hit network
        #expect(callCount1 == 4)
        #expect(callCount2 == 4) // No additional calls
    }
}