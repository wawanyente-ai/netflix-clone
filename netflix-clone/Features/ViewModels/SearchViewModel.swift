//
//  SearchViewModel.swift
//  netflix-clone
//

import Foundation

/// Manages Search screen state: query, suggestions (trending), and results (multi-search).
/// Loads from TMDB API.
@Observable
final class SearchViewModel {

    // MARK: - Published State

    var query: String = ""                        // ← input pencarian
    var suggestions: [MediaItem] = []             // ← trending sebagai saran (sebelum input)
    var results: [MediaItem] = []                 // ← hasil pencarian
    var isLoading = false                         // ← loading state
    var errorMessage: String?                     // ← error message

    // MARK: - Computed

    var isActive: Bool { !query.isEmpty }         // ← true jika user sudah ketik

    // MARK: - Init

    init() {
        Task { await loadSuggestions() }
    }

    // MARK: - Data Loading

    /// Load trending as suggestions (shown before user types).
    func loadSuggestions() async {
        do {
            let trendingDTOs = try await TMDBService.shared.fetchTrending()
            suggestions = MediaItemMapper.fromSearchResults(trendingDTOs) // ← map trending → suggestions
        } catch {
            errorMessage = error.localizedDescription // ← simpan error
        }
    }

    /// Search using TMDB multi-search endpoint.
    func search() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = [] // ← query kosong, clear results
            return
        }

        isLoading = true                          // ← mulai loading

        do {
            let searchDTOs = try await TMDBService.shared.searchMulti(query: query)
            results = MediaItemMapper.fromSearchResults(searchDTOs) // ← map search results
        } catch {
            errorMessage = error.localizedDescription
            results = [] // ← clear on error
        }

        isLoading = false                         // ← selesai loading
    }
}
