//
//  HomeViewModel+Cached.swift
//  netflix-clone
//
//  Updated Home ViewModel with SWR caching behavior.
//
import Foundation

@Observable
final class HomeViewModelCached {
    // MARK: - Published State

    var trending: [MediaItem] = []
    var popularMovies: [MediaItem] = []
    var topRatedMovies: [MediaItem] = []
    var popularTV: [MediaItem] = []
    var heroItem: MediaItem?

    // MARK: - Loading States

    enum LoadingState {
        case idle
        case loading               // Initial load, no cache
        case loaded                // Data loaded
        case refreshing            // Background refresh while showing cached
        case failed(Error)         // Initial load failed, no cache
    }

    @ObservationIgnored
    private(set) var loadingState: LoadingState = .idle

    // MARK: - Top Bar State

    enum ContentType { case all, movies, tvShows }
    var selectedContentType: ContentType = .all

    // MARK: - Dependencies

    private let repository: MovieRepository
    private let mainActor: MainActor.Type

    // MARK: - Init

    init(repository: MovieRepository = LiveMovieRepository()) {
        self.repository = repository
        self.mainActor = MainActor.self

        Task { await loadData() }
    }

    // MARK: - Loading Logic (Cache-First + SWR)

    func loadData() async {
        // Cache ada (stale-ok): langsung tampilkan tanpa shimmer, revalidate di background.
        if let cached = await repository.getCachedHomeData() {
            await updateUI(with: cached, state: .loaded)
            if await repository.isCacheStale() {
                await refresh() // ← silent: data cache tetap tampil, UI di-update setelah fetch
            }
            return
        }

        // Belum pernah fetch: baru tampilkan loading (hanya pertama kali).
        await MainActor.run { self.loadingState = .loading }

        do {
            let data = try await repository.refreshHome()
            await updateUI(with: data, state: .loaded)
        } catch {
            await MainActor.run {
                self.loadingState = .failed(error)
            }
        }
    }

    // MARK: - Pull-to-Refresh

    func refresh() async {
        await MainActor.run {
            if case .loaded = self.loadingState {
                self.loadingState = .refreshing
            }
        }

        do {
            let data = try await repository.refreshHome()
            await updateUI(with: data, state: .loaded)
        } catch {
            // Keep cached data visible on error
            await MainActor.run {
                // Don't show error spinner if we have cached content
                if self.trending.isEmpty {
                    self.loadingState = .failed(error)
                } else {
                    self.loadingState = .loaded
                }
            }
        }
    }

    // MARK: - Private Helpers

    @MainActor
    private func updateUI(with data: HomeData, state: LoadingState) {
        self.trending = data.trending
        self.popularMovies = data.popularMovies
        self.topRatedMovies = data.topRatedMovies
        self.popularTV = data.popularTV
        self.heroItem = data.heroItem
        self.loadingState = state
    }

    // MARK: - Accessors for View

    var isInitialLoading: Bool {
        if case .loading = loadingState {
            return true
        }
        return false
    }

    var isRefreshing: Bool {
        if case .refreshing = loadingState {
            return true
        }
        return false
    }

    var error: Error? {
        if case .failed(let err) = loadingState {
            return err
        }
        return nil
    }

    var hasContent: Bool {
        !trending.isEmpty || !popularMovies.isEmpty
    }
}