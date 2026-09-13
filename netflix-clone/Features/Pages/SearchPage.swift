//
//  SearchPage.swift
//  netflix-clone
//

import SwiftUI

/// Netflix Search screen: trending suggestions (no input) / search results grid (with input).
/// Uses TopSearchRow for trending, TitleCard for results — consumes existing DS components.
struct SearchPage: View {

    @State var viewModel = SearchViewModel()
    @State private var searchDebounceTask: Task<Void, Never>?
    var onTitleTap: (MediaItem) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 0) {
            searchBarRow // ← sticky search bar (di LUAR ScrollView)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if viewModel.isLoading {
                        loadingSkeleton
                    } else if viewModel.isActive {
                        Text("Search Results") // ← judul hasil pencarian
                            .font(.Typography.Bold.label1)
                            .foregroundStyle(Color.Semantic.textPrimary)
                            .padding(.horizontal, 16)
                        searchResults
                    } else {
                        // ← recent searches paling atas
                        if !viewModel.recentSearches.isEmpty {
                            recentSearchesSection
                        }
                        // ← trending searches di bawah recent
                        Text("Trending Searches")
                            .font(.Typography.Bold.label1)
                            .foregroundStyle(Color.Semantic.textPrimary)
                            .padding(.horizontal, 16)
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
}

// MARK: - Preview

#Preview {
    SearchPage()
}
