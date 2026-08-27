//
//  TitleDetailPage.swift
//  netflix-clone
//

import SwiftUI

/// Title detail screen: hero backdrop, metadata, actions, cast, episodes, recommendations.
/// Loads from TMDB API via TitleDetailViewModel.
struct TitleDetailPage: View {

    @State private var viewModel: TitleDetailViewModel
    var onPlayTap: () -> Void = {} // ← navigasi ke video player
    var onTitleTap: (MediaItem) -> Void = { _ in } // ← navigasi ke detail lain

    /// Initialize with TMDB media type and ID.
    init(mediaType: String = "movie", mediaId: Int = 0, onPlayTap: @escaping () -> Void = {}, onTitleTap: @escaping (MediaItem) -> Void = { _ in }) {
        _viewModel = State(initialValue: TitleDetailViewModel(mediaType: mediaType, mediaId: mediaId))
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

    // MARK: - Hero Backdrop

    private var heroBackdrop: some View {
        ZStack(alignment: .bottomLeading) {
            // ← BackdropImage component (handles shimmer + layout)
            BackdropImage(
                url: viewModel.titleDetail?.backdropURL,
                height: 220 // ← ubah tinggi hero backdrop
            )

            LinearGradient(
                colors: [.clear, Color.Semantic.background.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 220)
        }
    }

    // MARK: - Title Info

    private var titleInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.titleDetail?.rating ?? "Loading...") // ← genre/rating
                .font(.Typography.Medium.caption2)
                .tracking(3)
                .foregroundStyle(Color.Neutral.greyLight1)

            Text(viewModel.titleDetail?.title ?? "") // ← judul
                .font(.Typography.Bold.header1)
                .foregroundStyle(Color.Semantic.textPrimary)

            HStack(spacing: 8) {
                Text(viewModel.titleDetail?.year ?? "") // ← tahun
                Text("•")
                Text(viewModel.titleDetail?.seasonCount ?? "") // ← season/durasi
                Text("•")
                Text(viewModel.titleDetail?.voteAverageString ?? "") // ← rating TMDB
            }
            .font(.Typography.Medium.caption1)
            .foregroundStyle(Color.Semantic.textSecondary)
        }
    }

    // MARK: - Actions

    private var actions: some View {
        VStack(spacing: 8) {
            AppButton("Play", icon: Image.Icon.play, variant: .primary) { onPlayTap() }
            AppButton("Download", icon: Image.Icon.downloadAction, variant: .secondary) {}
        }
    }

    // MARK: - Synopsis

    private var synopsis: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.titleDetail?.synopsis ?? "") // ← sinopsis
                .font(.Typography.Medium.caption1)
                .foregroundStyle(Color.Semantic.textSecondary)
        }
    }

    // MARK: - Cast

    private var castSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cast")
                .font(.Typography.Bold.label3)
                .foregroundStyle(Color.Semantic.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.titleDetail?.cast ?? []) { member in
                        castMemberView(member)
                    }
                }
            }
        }
    }

    private func castMemberView(_ member: CastMember) -> some View {
        VStack(spacing: 4) {
            // ← ProfileImage component (handles shimmer + circle clip)
            ProfileImage(url: member.profileURL, size: 60) // ← ubah ukuran foto

            Text(member.name)
                .font(.Typography.Light.caption2)
                .foregroundStyle(Color.Semantic.textSecondary)
                .lineLimit(1)
        }
        .frame(width: 70) // ← lebar card cast
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        TitleDetailsTabBar(selection: $viewModel.selectedTab)
    }

    // MARK: - Season Picker

    private var seasonPicker: some View {
        SeasonSelectionDropdown(selection: $viewModel.selectedSeason, availableSeasons: 1...5)
    }

    // MARK: - Episode List

    private var episodeList: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.episodes) { episode in
                episodeRow(episode)
            }
        }
    }

    private func episodeRow(_ episode: Episode) -> some View {
        HStack(spacing: 12) {
            // ← PosterImage component untuk episode still
            PosterImage(url: episode.stillURL, width: 120, height: 68, cornerRadius: 4) // ← ubah ukuran still

            VStack(alignment: .leading, spacing: 4) {
                Text(episode.title)
                    .font(.Typography.Medium.caption1)
                    .foregroundStyle(Color.Semantic.textPrimary)
                    .lineLimit(1)

                Text(episode.synopsis)
                    .font(.Typography.Light.caption2)
                    .foregroundStyle(Color.Semantic.textSecondary)
                    .lineLimit(3)
            }
        }
    }

    // MARK: - More Like This

    private var moreLikeThisRail: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("More Like This")
                .font(.Typography.Bold.label3)
                .foregroundStyle(Color.Semantic.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.recommendations) { item in
                        Button { onTitleTap(item) } label: {
                            PosterImage(url: item.posterURL) // ← poster component
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    TitleDetailPage(mediaType: "movie", mediaId: 550)
}
