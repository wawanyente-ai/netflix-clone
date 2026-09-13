//
//  HomePage+Rails.swift
//  netflix-clone
//

import SwiftUI

extension HomePage {

    // MARK: - Rails

    var trendingRail: some View {
        mediaRail(title: "Trending Now", items: viewModel.trending) // ← trending rail
    }

    var popularMoviesRail: some View {
        mediaRail(title: "Popular Movies", items: viewModel.popularMovies) // ← popular movies rail
    }

    var topRatedMoviesRail: some View {
        mediaRail(title: "Top Rated", items: viewModel.topRatedMovies) // ← top rated rail
    }

    var popularTVRail: some View {
        mediaRail(title: "Popular TV Shows", items: viewModel.popularTV) // ← popular TV rail
    }

    // MARK: - Continue Watching Rail

    var continueWatchingRail: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lanjutkan Tonton")
                .font(.Typography.Bold.label1) // ← ubah font judul rail
                .foregroundStyle(Color.Semantic.textPrimary)
                .padding(.horizontal, 16) // ← ubah inset horizontal

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) { // ← ubah gap antar card
                    ForEach(continueWatching) { progress in
                        continueWatchingCard(progress)
                    }
                }
                .padding(.horizontal, 16) // ← ubah inset horizontal
            }
        }
    }

    func continueWatchingCard(_ progress: WatchProgressModel) -> some View {
        Button {
            if let item = mediaItem(for: progress) { onTitleTap(item) } // ← navigasi ke detail
        } label: {
            TitleCard(
                kind: .continueWatching(
                    progress: min(max(progress.completion, 0), 1), // ← progress bar 0...1
                    episodeLabel: "\(Int(min(max(progress.completion, 0), 1) * 100))%" // ← persen progress
                ),
                hasImage: !progress.posterPath.isEmpty // ← tampil logo kalau ada poster
            ) {
                PosterImage(url: ImageURLBuilder.posterURL(from: progress.posterPath))
            }
        }
        .buttonStyle(.plain)
    }

    /// Convert WatchProgressModel → MediaItem (untuk navigasi detail).
    func mediaItem(for progress: WatchProgressModel) -> MediaItem? {
        MediaItem(
            id: progress.mediaId,
            title: progress.title,
            overview: "",
            posterPath: progress.posterPath.isEmpty ? nil : progress.posterPath,
            backdropPath: nil,
            voteAverage: 0,
            releaseDate: "",
            mediaType: progress.mediaType == "tv" ? .tv : .movie,
            genreIds: [],
            runtime: nil
        )
    }

    /// Reusable media rail component.
    func mediaRail(title: String, items: [MediaItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.Typography.Bold.label1) // ← ubah font judul rail
                .foregroundStyle(Color.Semantic.textPrimary)
                .padding(.horizontal, 16) // ← ubah inset horizontal

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) { // ← ubah gap antar card
                    ForEach(items) { item in
                        mediaCard(item: item) // ← card per item
                    }
                }
                .padding(.horizontal, 16) // ← ubah inset horizontal
            }
        }
    }

    /// Individual media card with poster image, Netflix logo, and badges.
    func mediaCard(item: MediaItem) -> some View {
        Button { onTitleTap(item) } label: {
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
        }
        .buttonStyle(.plain)
    }

    /// Generate bottom badges based on media item data.
    func generateBadges(for item: MediaItem) -> [BadgeConfig.BottomBadge] {
        BadgeHelper.generateBadges(for: item)
    }
}