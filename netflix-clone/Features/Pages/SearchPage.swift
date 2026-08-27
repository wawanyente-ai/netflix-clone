//
//  SearchPage.swift
//  netflix-clone
//

import SwiftUI

/// Netflix Search screen: trending suggestions (no input) / search results grid (with input).
/// Uses TopSearchRow for trending, TitleCard for results — consumes existing DS components.
struct SearchPage: View {

    @State private var viewModel = SearchViewModel()
    @State private var searchDebounceTask: Task<Void, Never>?
    var onTitleTap: (MediaItem) -> Void = { _ in }

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: 3) // ← 3 kolom grid
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBarRow // ← sticky search bar (di LUAR ScrollView)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(viewModel.isActive ? "Search Results" : "Trending Searches")
                        .font(.Typography.Bold.label1)
                        .foregroundStyle(Color.Semantic.textPrimary)
                        .padding(.horizontal, 16)

                    if viewModel.isLoading {
                        loadingSkeleton
                    } else if viewModel.isActive {
                        searchResults
                    } else {
                        trendingSuggestions
                    }
                }
                .padding(.top, 16)
            }
            .refreshable { // ← pull-to-refresh: tarik ke bawah buat reload
                await viewModel.loadSuggestions()
                if viewModel.isActive {
                    await viewModel.search()
                }
            }
        }
        .background(Color.Semantic.background.ignoresSafeArea())
    }

    // MARK: - Search Bar Row (sticky)

    private var searchBarRow: some View {
        HStack(spacing: 8) {
            SearchBar(text: $viewModel.query)

            if viewModel.isActive {
                Button("Cancel") {
                    viewModel.query = ""
                    viewModel.results = []
                    Task { await viewModel.loadSuggestions() }
                }
                .font(.Typography.Medium.label3)
                .foregroundStyle(Color.Semantic.textPrimary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color.Semantic.background) // ← background solid biar ga tembus scroll
        .onChange(of: viewModel.query) { _, newValue in
            searchDebounceTask?.cancel()
            searchDebounceTask = Task {
                try? await Task.sleep(for: .milliseconds(500))
                guard !Task.isCancelled else { return }
                if newValue.isEmpty {
                    viewModel.results = []
                    await viewModel.loadSuggestions()
                } else {
                    await viewModel.search()
                }
            }
        }
    }

    // MARK: - Loading Skeleton

    private var loadingSkeleton: some View {
        LazyVGrid(columns: gridColumns, spacing: 8) {
            ForEach(0..<9, id: \.self) { _ in
                VStack(spacing: 4) {
                    ShimmerView()
                        .frame(width: 106, height: 152)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    ShimmerView()
                        .frame(width: 80, height: 12)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Trending Suggestions (no input) — pakai TopSearchRow

    private var trendingSuggestions: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.suggestions) { item in
                TopSearchRow(
                    title: item.title,
                    hasTopTenBadge: false, // ← bisa diisi dari API
                    hasImage: item.posterURL != nil,
                    onPlayTap: { onTitleTap(item) }
                ) {
                    PosterImage(url: item.posterURL, width: 40, height: 56, cornerRadius: 2) // ← thumbnail kecil
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Search Results (with input) — pakai TitleCard

    private var searchResults: some View {
        LazyVGrid(columns: gridColumns, spacing: 8) {
            ForEach(viewModel.results) { item in
                resultCard(item: item)
            }
        }
        .padding(.horizontal, 16)
    }

    private func resultCard(item: MediaItem) -> some View {
        Button { onTitleTap(item) } label: {
            VStack(alignment: .leading, spacing: 4) {
                // ← TitleCard dengan poster, Netflix logo, dan badge
                TitleCard(
                    kind: .standard,
                    badge: BadgeConfig(
                        showTopTen: item.voteAverage >= 8.0, // ← TopTen jika rating ≥ 8.0
                        bottomBadges: generateBadges(for: item) // ← badges dari data
                    ),
                    hasImage: item.posterURL != nil
                ) {
                    PosterImage(url: item.posterURL) // ← poster image
                }

                Text(item.title)
                    .font(.Typography.Medium.caption2)
                    .foregroundStyle(Color.Semantic.textSecondary)
                    .lineLimit(2)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Badge Generator

    /// Generate bottom badges based on media item data.
    private func generateBadges(for item: MediaItem) -> [BadgeConfig.BottomBadge] {
        BadgeHelper.generateBadges(for: item)
    }
}

// MARK: - Preview

#Preview {
    SearchPage()
}
