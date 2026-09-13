//
//  SearchPage+Sections.swift
//  netflix-clone
//

import SwiftUI

extension SearchPage {

    // MARK: - Grid Columns

    var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: 3) // ← 3 kolom grid
    }

    // MARK: - Loading Skeleton

    var loadingSkeleton: some View {
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

    // MARK: - Recent Searches (maks 5)

    var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Searches")
                .font(.Typography.Bold.label1)
                .foregroundStyle(Color.Semantic.textPrimary)
                .padding(.horizontal, 16)

            ForEach(viewModel.recentSearches, id: \.self) { item in
                HStack(spacing: 12) {
                    // ← ikon riwayat (custom, tanpa SF Symbol)
                    Path { path in
                        path.move(to: CGPoint(x: 2, y: 10))
                        path.addArc(
                            center: CGPoint(x: 10, y: 10),
                            radius: 8,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270),
                            clockwise: false
                        )
                    }
                    .stroke(Color.Semantic.textTertiary, lineWidth: 1.5)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Path { path in
                            path.move(to: CGPoint(x: 7, y: 10))
                            path.addLine(to: CGPoint(x: 10, y: 10))
                            path.addLine(to: CGPoint(x: 10, y: 13))
                        }
                        .stroke(Color.Semantic.textTertiary, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                        .frame(width: 20, height: 20)
                    )

                    Button {
                        viewModel.applyRecent(item) // ← set query → auto search
                    } label: {
                        Text(item)
                            .font(.Typography.Medium.label3)
                            .foregroundStyle(Color.Semantic.textPrimary)
                            .lineLimit(1)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button {
                        viewModel.removeRecent(item) // ← hapus dari riwayat
                    } label: {
                        Image.Icon.close
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color.Semantic.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Trending Suggestions (no input) — pakai TopSearchRow

    var trendingSuggestions: some View {
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

    var searchResults: some View {
        LazyVGrid(columns: gridColumns, spacing: 8) {
            ForEach(viewModel.results) { item in
                resultCard(item: item)
            }
        }
        .padding(.horizontal, 16)
    }

    func resultCard(item: MediaItem) -> some View {
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
    func generateBadges(for item: MediaItem) -> [BadgeConfig.BottomBadge] {
        BadgeHelper.generateBadges(for: item)
    }
}
