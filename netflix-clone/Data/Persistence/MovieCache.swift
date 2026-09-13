//
//  MovieCache.swift
//  netflix-clone
//
//  Persistence layer for cached movie data with TTL metadata.
//
import Foundation

// MARK: - Cache Policy

/// Centralized TTL configuration.
struct CachePolicy {
    /// How long home-section data remains fresh (seconds).
    static let homeTTL: TimeInterval = 15 * 60 // 15 minutes

    /// How long individual item details remain fresh.
    static let detailTTL: TimeInterval = 7 * 24 * 60 * 60 // 7 days

    /// Returns true if age is within TTL.
    static func isFresh(_ cachedAt: Date, ttl: TimeInterval = homeTTL) -> Bool {
        Date().timeIntervalSince(cachedAt) < ttl
    }
}

// MARK: - Movie Cache Model

struct CachedMovieData: Codable {
    let mediaId: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let rating: Double
    let releaseDate: String?
    let genreIds: [Int]
    let mediaType: String  // "movie" | "tv"

    init(from mediaItem: MediaItem) {
        self.mediaId = mediaItem.id
        self.title = mediaItem.title
        self.overview = mediaItem.overview
        self.posterPath = mediaItem.posterPath
        self.backdropPath = mediaItem.backdropPath
        self.rating = mediaItem.voteAverage
        self.releaseDate = mediaItem.releaseDate
        self.genreIds = mediaItem.genreIds
        self.mediaType = mediaItem.mediaType.rawValue
    }

    func toMediaItem() -> MediaItem {
        MediaItem(
            id: mediaId,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            voteAverage: rating,
            releaseDate: releaseDate ?? "",
            mediaType: mediaType == "tv" ? .tv : .movie,
            genreIds: genreIds,
            runtime: nil
        )
    }
}

// MARK: - Cache Entry with Metadata

struct CacheEntry<T: Codable>: Codable {
    let data: T
    let cachedAt: Date

    func isFresh(ttl: TimeInterval = CachePolicy.homeTTL) -> Bool {
        CachePolicy.isFresh(cachedAt, ttl: ttl)
    }
}

// MARK: - Local Data Source

actor LocalMovieDataSource {
    private let userDefaults = UserDefaults.standard
    private let cacheKeyPrefix = "netflix_cache_"

    private nonisolated func cacheKey(for section: String) -> String {
        "\(cacheKeyPrefix)\(section)"
    }

    /// Retrieve cached movies for a section.
    /// Mengembalikan data walau sudah stale (stale-while-revalidate) — nil hanya
    /// kalau belum pernah disimpan. Cache tidak dihapus saat expired, biar bisa
    /// langsung ditampilkan dan di-refresh di background.
    func cachedMovies(for section: String) -> [MediaItem]? {
        let key = cacheKey(for: section)
        guard let data = userDefaults.data(forKey: key),
              let entry = try? JSONDecoder().decode(CacheEntry<[CachedMovieData]>.self, from: data) else {
            return nil
        }
        return entry.data.map { $0.toMediaItem() }
    }

    /// True kalau section punya cache yang sudah melewati TTL (perlu revalidate).
    func isStale(for section: String) -> Bool {
        let key = cacheKey(for: section)
        guard let data = userDefaults.data(forKey: key),
              let entry = try? JSONDecoder().decode(CacheEntry<[CachedMovieData]>.self, from: data) else {
            return false
        }
        return !entry.isFresh()
    }

    /// Save movies for a section with current timestamp.
    func saveMovies(_ movies: [MediaItem], for section: String) {
        let key = cacheKey(for: section)
        let cachedData = movies.map { CachedMovieData(from: $0) }
        let entry = CacheEntry(data: cachedData, cachedAt: Date())

        do {
            let data = try JSONEncoder().encode(entry)
            userDefaults.set(data, forKey: key)
        } catch {
            // Silently fail
        }
    }

    /// Clear cache for a section.
    func clearCache(for section: String) {
        let key = cacheKey(for: section)
        userDefaults.removeObject(forKey: key)
    }
}