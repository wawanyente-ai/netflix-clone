//
//  SearchViewModel.swift
//  netflix-clone
//

import Foundation

/// Manages Search screen state: query, recent searches, suggestions (trending),
/// and results (multi-search). Loads from the backend TMDB proxy.
@Observable
final class SearchViewModel {

    // MARK: - Published State

    var query: String = ""                        // ← input pencarian
    var recentSearches: [String] = []             // ← riwayat pencarian (max 5)
    var suggestions: [MediaItem] = []             // ← trending sebagai saran (sebelum input)
    var results: [MediaItem] = []                 // ← hasil pencarian
    var isLoading = false                         // ← loading state
    var errorMessage: String?                     // ← error message

    // MARK: - Computed

    var isActive: Bool { !query.isEmpty }         // ← true jika user sudah ketik

    // MARK: - Constants

    private static let recentKey = "recentSearches" // ← kunci UserDefaults
    static let maxRecent = 5                        // ← maks 5 item recent

    // MARK: - Init

    init() {
        recentSearches = Self.loadRecentSearches()
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

    /// Search using TMDB multi-search endpoint (via backend proxy).
    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            results = [] // ← query kosong, clear results
            return
        }

        isLoading = true                          // ← mulai loading

        do {
            let searchDTOs = try await TMDBService.shared.searchMulti(query: trimmed)
            results = MediaItemMapper.fromSearchResults(searchDTOs) // ← map search results
            saveRecent(trimmed)                    // ← simpan ke riwayat saat sukses
        } catch {
            errorMessage = error.localizedDescription
            results = [] // ← clear on error
        }

        isLoading = false                         // ← selesai loading
    }

    // MARK: - Recent Searches

    /// Simpan query ke riwayat (front, dedupe, max 5).
    func saveRecent(_ item: String) {
        var list = recentSearches.filter { $0.lowercased() != item.lowercased() }
        list.insert(item, at: 0)                   // ← taruh paling depan
        recentSearches = Array(list.prefix(Self.maxRecent)) // ← max 5
        Self.persist(recentSearches)
    }

    /// Hapus satu item riwayat.
    func removeRecent(_ item: String) {
        recentSearches.removeAll { $0 == item }
        Self.persist(recentSearches)
    }

    /// Set query dari item recent → memicu pencarian (via debounce di view).
    func applyRecent(_ item: String) {
        query = item
    }

    // MARK: - Persistence

    private static func loadRecentSearches() -> [String] {
        UserDefaults.standard.stringArray(forKey: recentKey) ?? []
    }

    private static func persist(_ items: [String]) {
        UserDefaults.standard.set(items, forKey: recentKey)
    }
}