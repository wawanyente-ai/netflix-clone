//
//  HomeViewModel.swift
//  netflix-clone
//

import Foundation

/// Manages Home screen data: trending, popular, top rated rails + hero.
/// Loads from TMDB API, falls back to dummy data if API fails.
@Observable
final class HomeViewModel {

    // MARK: - Published State

    var trending: [MediaItem] = []             // ← trending movies + TV
    var popularMovies: [MediaItem] = []        // ← popular movies rail
    var topRatedMovies: [MediaItem] = []       // ← top rated movies rail
    var popularTV: [MediaItem] = []            // ← popular TV shows rail
    var heroItem: MediaItem?                   // ← hero backdrop (first trending)
    var isLoading = false                      // ← loading state
    var errorMessage: String?                  // ← error message

    // MARK: - Top Bar State

    enum ContentType { case all, movies, tvShows } // ← tipe konten untuk filter
    var selectedContentType: ContentType = .all    // ← filter aktif (all/movies/tvShows)
    var showCategorySheet = false                  // ← toggle sheet kategori

    // MARK: - Init

    init() {
        Task { await loadData() }
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true                        // ← mulai loading
        errorMessage = nil

        do {
            let service = TMDBService.shared

            // ← fetch semua data secara parallel
            async let trendingResult = service.fetchTrending()
            async let popularResult = service.fetchPopularMovies()
            async let topRatedResult = service.fetchTopRatedMovies()
            async let popularTVResult = service.fetchPopularTV()

            let (trendingDTOs, popularDTOs, topRatedDTOs, popularTVDTOs) = try await (
                trendingResult,
                popularResult,
                topRatedResult,
                popularTVResult
            )

            trending = MediaItemMapper.fromSearchResults(trendingDTOs) // ← map trending
            popularMovies = MediaItemMapper.fromMovies(popularDTOs)    // ← map popular
            topRatedMovies = MediaItemMapper.fromMovies(topRatedDTOs)  // ← map top rated
            popularTV = MediaItemMapper.fromTVShows(popularTVDTOs)     // ← map popular TV
            heroItem = trending.first                                  // ← hero dari trending pertama

        } catch {
            errorMessage = error.localizedDescription // ← simpan error
            loadDummyFallback()                         // ← fallback ke dummy data
        }

        isLoading = false                       // ← selesai loading
    }

    /// Fallback to dummy data when API fails.
    private func loadDummyFallback() {
        // ← fallback ke empty (dummy data tidak tersedia untuk home)
        trending = []
        popularMovies = []
        topRatedMovies = []
        popularTV = []
    }
}
