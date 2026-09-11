//
//  HomePage.swift
//  netflix-clone
//

import SwiftUI

/// Netflix Home screen: hero, trending, popular, top rated rails.
/// Loads data from TMDB API via HomeViewModel.
struct HomePage: View {

    @State private var viewModel = HomeViewModel()
    var continueWatching: [WatchProgressModel] = [] // ← lanjut tonton (butuh login)
    var onTitleTap: (MediaItem) -> Void = { _ in } // ← navigasi ke detail
    var onMyListTap: () -> Void = {} // ← save/unsave (di-gate auth oleh app root)

    var body: some View {
        VStack(spacing: 0) { // ← topBar di LUAR ScrollView
            topBar // ← sticky top bar

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if viewModel.isLoading {
                        loadingSkeleton
                    } else {
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
            .refreshable { // ← pull-to-refresh: tarik ke bawah buat reload
                await viewModel.loadData()
            }
        }
        .background(Color.Semantic.background.ignoresSafeArea())
    }

    // MARK: - Loading Skeleton

    private var loadingSkeleton: some View {
        VStack(alignment: .leading, spacing: 24) {
            // ← hero skeleton
            ShimmerView()
                .frame(height: 480)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // ← rail skeleton (3 shimmer cards)
            VStack(alignment: .leading, spacing: 8) {
                ShimmerView()
                    .frame(width: 150, height: 20) // ← judul rail placeholder
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { _ in // ← 6 poster skeleton
                        ShimmerView()
                            .frame(width: 106, height: 152) // ← ukuran poster
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Top Bar (sticky, tappable)

    private var topBar: some View {
        HStack(spacing: 16) {
            Image.Brand.logoSmall
                .resizable()
                .scaledToFit()
                .frame(height: 24)

            // ← tappable: TV Shows
            Button {
                viewModel.selectedContentType = .tvShows // ← filter TV shows
            } label: {
                Text("TV Shows")
                    .font(.Typography.Medium.label3)
                    .foregroundStyle(
                        viewModel.selectedContentType == .tvShows
                            ? Color.Semantic.textPrimary // ← aktif: putih
                            : Color.Semantic.textTertiary // ← inactive: abu
                    )
            }

            // ← tappable: Movies
            Button {
                viewModel.selectedContentType = .movies // ← filter movies
            } label: {
                Text("Movies")
                    .font(.Typography.Medium.label3)
                    .foregroundStyle(
                        viewModel.selectedContentType == .movies
                            ? Color.Semantic.textPrimary
                            : Color.Semantic.textTertiary
                    )
            }

            // ← tappable: Categories
            Button {
                viewModel.showCategorySheet = true
            } label: {
                HStack(spacing: 2) {
                    Text("Categories")
                        .font(.Typography.Medium.label3)
                    // ← custom chevron (bukan SF Symbol)
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: 4, y: 4))
                        path.addLine(to: CGPoint(x: 8, y: 0))
                    }
                    .stroke(Color.Semantic.textPrimary, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .frame(width: 8, height: 5)
                }
                .foregroundStyle(Color.Semantic.textPrimary)
            }

            Spacer()

            TemplateIcon(image: Image.Icon.mirror, size: 20, tint: Color.Semantic.textPrimary)

            Image.UserVariant.blue
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color.Semantic.background)
    }

    // MARK: - Hero

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            // ← BackdropImage component (handles AsyncImage + shimmer)
            BackdropImage(
                url: viewModel.heroItem?.backdropURL,
                height: 480 // ← ubah tinggi hero
            )

            LinearGradient(
                colors: [.clear, Color.Semantic.background.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 480)

            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.heroItem?.title ?? "Loading...") // ← judul dari trending
                    .font(.Typography.Bold.header1)
                    .foregroundStyle(Color.Semantic.textPrimary)

                Text(viewModel.heroItem?.overview ?? "") // ← overview dari trending
                    .font(.Typography.Medium.caption1)
                    .foregroundStyle(Color.Semantic.textSecondary)
                    .lineLimit(3) // ← limit 3 baris

                HStack(spacing: 8) {
                    AppButton("My List", icon: Image.Icon.add, variant: .secondary, size: .small) { onMyListTap() }
                    AppButton("Play", icon: Image.Icon.play, variant: .primary, size: .small) {
                        if let item = viewModel.heroItem { onTitleTap(item) } // ← navigasi ke detail
                    }
                    AppButton("Info", icon: Image.Icon.info, variant: .secondary, size: .small) {
                        if let item = viewModel.heroItem { onTitleTap(item) } // ← navigasi ke detail
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Rails

    private var trendingRail: some View {
        mediaRail(title: "Trending Now", items: viewModel.trending) // ← trending rail
    }

    private var popularMoviesRail: some View {
        mediaRail(title: "Popular Movies", items: viewModel.popularMovies) // ← popular movies rail
    }

    private var topRatedMoviesRail: some View {
        mediaRail(title: "Top Rated", items: viewModel.topRatedMovies) // ← top rated rail
    }

    private var popularTVRail: some View {
        mediaRail(title: "Popular TV Shows", items: viewModel.popularTV) // ← popular TV rail
    }

    // MARK: - Continue Watching Rail

    private var continueWatchingRail: some View {
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

    private func continueWatchingCard(_ progress: WatchProgressModel) -> some View {
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
    private func mediaItem(for progress: WatchProgressModel) -> MediaItem? {
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
    private func mediaRail(title: String, items: [MediaItem]) -> some View {
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
    private func mediaCard(item: MediaItem) -> some View {
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
    private func generateBadges(for item: MediaItem) -> [BadgeConfig.BottomBadge] {
        BadgeHelper.generateBadges(for: item)
    }
}

// MARK: - Preview

#Preview {
    HomePage()
}
