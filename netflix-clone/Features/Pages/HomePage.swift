//
//  HomePage.swift
//  netflix-clone
//

import SwiftUI

/// Netflix Home screen: hero, trending, popular, top rated rails.
/// Loads data from TMDB API via HomeViewModelCached with SWR caching.
struct HomePage: View {

    var viewModel: HomeViewModelCached
    var continueWatching: [WatchProgressModel] = [] // ← lanjut tonton (butuh login)
    var onTitleTap: (MediaItem) -> Void = { _ in } // ← navigasi ke detail
    var onMyListTap: (MediaItem) -> Void = { _ in } // ← save/unsave hero (di-gate auth oleh app root)
    var isInMyList: (MediaItem) -> Bool = { _ in false } // ← cek status My List
    var isSavingMyList: (MediaItem) -> Bool = { _ in false } // ← loading state toggle My List

    var body: some View {
        VStack(spacing: 0) { // ← topBar di LUAR ScrollView
            topBar // ← sticky top bar

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Initial loading state (no cache)
                    if viewModel.isInitialLoading {
                        loadingSkeleton
                    }
                    // Error state when no cache exists
                    else if let error = viewModel.error, !viewModel.hasContent {
                        errorState(error)
                    }
                    // Content (cached or fresh)
                    else if viewModel.hasContent {
                        hero

                        // ← Continue Watching rail (hanya kalau ada progress)
                        if !continueWatching.isEmpty {
                            continueWatchingRail
                        }

                        // ← tampilkan rails berdasarkan filter top bar
                        switch viewModel.selectedContentType {
                        case .all:
                            trendingRail
                            popularMoviesRail
                            topRatedMoviesRail
                            popularTVRail
                        case .movies:
                            popularMoviesRail
                            topRatedMoviesRail
                        case .tvShows:
                            popularTVRail
                            trendingRail
                        }
                    }
                }
                .padding(.bottom, 24)
            }
            .refreshable { // ← pull-to-refresh: force refresh ignoring TTL
                await viewModel.refresh()
            }
        }
        .background(Color.Semantic.background.ignoresSafeArea())
    }

    // MARK: - Error State

    @ViewBuilder
    private func errorState(_ error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(Color.Primary.red)

            Text("Gagal memuat Home")
                .font(.Typography.Bold.label2)
                .foregroundStyle(Color.Semantic.textPrimary)

            Text(error.localizedDescription)
                .font(.Typography.Medium.caption1)
                .foregroundStyle(Color.Semantic.textSecondary)
                .multilineTextAlignment(.center)

            AppButton("Coba Lagi", variant: .primary) {
                Task { await viewModel.loadData() }
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

// MARK: - Preview

#Preview {
    HomePage(viewModel: HomeViewModelCached())
}