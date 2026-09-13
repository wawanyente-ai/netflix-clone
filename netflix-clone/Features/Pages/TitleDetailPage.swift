//
//  TitleDetailPage.swift
//  netflix-clone
//

import SwiftUI

/// Title detail screen: hero backdrop, metadata, actions, cast, episodes, recommendations.
/// Loads from TMDB API via TitleDetailViewModel.
struct TitleDetailPage: View {

    @State var viewModel: TitleDetailViewModel
    var onPlayTap: () -> Void = {} // ← navigasi ke video player
    var onTitleTap: (MediaItem) -> Void = { _ in } // ← navigasi ke detail lain
    var onMyListTap: () -> Void = {} // ← toggle my list (di-gate auth oleh app root)
    var isInMyList: () -> Bool = { false } // ← status My List (closure biar selalu fresh setelah toggle)
    var isSavingMyList: () -> Bool = { false } // ← loading state toggle my list

    /// Initialize with TMDB media type and ID.
    init(
        mediaType: String = "movie",
        mediaId: Int = 0,
        isInMyList: @escaping () -> Bool = { false },
        isSavingMyList: @escaping () -> Bool = { false },
        onMyListTap: @escaping () -> Void = {},
        onPlayTap: @escaping () -> Void = {},
        onTitleTap: @escaping (MediaItem) -> Void = { _ in }
    ) {
        _viewModel = State(initialValue: TitleDetailViewModel(mediaType: mediaType, mediaId: mediaId))
        self.isInMyList = isInMyList
        self.isSavingMyList = isSavingMyList
        self.onMyListTap = onMyListTap
        self.onPlayTap = onPlayTap
        self.onTitleTap = onTitleTap
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                heroBackdrop
                titleInfo
                    .padding(.horizontal, 16)
                actions
                    .padding(.horizontal, 16)
                synopsis
                    .padding(.horizontal, 16)
                castSection
                    .padding(.horizontal, 16)
                if !viewModel.episodes.isEmpty {
                    tabBar
                        .padding(.horizontal, 16)
                    seasonPicker
                        .padding(.horizontal, 16)
                    episodeList
                        .padding(.horizontal, 16)
                }
                if !viewModel.recommendations.isEmpty {
                    moreLikeThisRail
                        .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 24)
        }
        .background(Color.Semantic.background.ignoresSafeArea())
        .onChange(of: viewModel.selectedSeason) { _, newSeason in
            Task { await viewModel.loadSeason(newSeason) } // ← load episode saat ganti season
        }
    }
}

// MARK: - Preview

#Preview {
    TitleDetailPage(mediaType: "movie", mediaId: 550)
}
