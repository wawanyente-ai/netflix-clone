//
//  TitleCard.swift
//  netflix-clone
//

import SwiftUI

// MARK: - Badge Configuration (top-level for generic access)

/// Badge configuration — supports top-ten icon + stacked text badges at bottom.
struct BadgeConfig {
    var showTopTen: Bool = false                     // ← tampilkan TopTenBadge di pojok kanan atas
    var bottomBadges: [BottomBadge] = []             // ← max 2 text badges di bawah

    /// Bottom text badge — white bg black fg (top) or red bg white fg (bottom).
    struct BottomBadge {
        let text: String                             // ← teks badge
        let style: Style                             // ← red atau white style

        enum Style {
            case whiteBgBlackFg                      // ← bg putih, teks hitam (atas)
            case redBgWhiteFg                        // ← bg merah, teks putih (bawah)
        }
    }
}

// MARK: - TitleCard

/// Poster-style title card used in Browse rows, Continue Watching rails, and Top Searches.
/// Generic over `Background` so callers can plug in `AsyncImage`, a local asset, or a placeholder color.
struct TitleCard<Background: View>: View {

    // MARK: Types

    enum Kind {
        case standard                                    // ← poster only (106×152)
        case continueWatching(progress: Double, episodeLabel: String) // ← poster + progress + icons
        case topSearch                                   // ← horizontal thumbnail (96×54)
    }

    // MARK: Properties

    let kind: Kind
    let badge: BadgeConfig
    let hasImage: Bool
    let onInfoTap: (() -> Void)?
    let onMoreTap: (() -> Void)?
    let onPlayTap: (() -> Void)?
    let background: () -> Background

    // MARK: Initialization

    init(
        kind: Kind,
        badge: BadgeConfig = BadgeConfig(),
        hasImage: Bool = true,
        onInfoTap: (() -> Void)? = nil,
        onMoreTap: (() -> Void)? = nil,
        onPlayTap: (() -> Void)? = nil,
        @ViewBuilder background: @escaping () -> Background
    ) {
        self.kind = kind
        self.badge = badge
        self.hasImage = hasImage
        self.onInfoTap = onInfoTap
        self.onMoreTap = onMoreTap
        self.onPlayTap = onPlayTap
        self.background = background
    }

    // MARK: Body

    var body: some View {
        switch kind {
        case .standard:
            posterBody(showsPlayOverlay: false, progress: nil, episodeLabel: nil, showsFooter: false)
        case .continueWatching(let progress, let episodeLabel):
            posterBody(showsPlayOverlay: true, progress: progress, episodeLabel: episodeLabel, showsFooter: true)
        case .topSearch:
            topSearchBody
        }
    }
}

// MARK: - Poster (Standard / Continue Watching)

private extension TitleCard {

    var size: CGSize {
        switch kind {
        case .standard: TitleCardMetrics.standard.size
        case .continueWatching: TitleCardMetrics.continueWatching.size
        case .topSearch: TitleCardMetrics.topSearch.size
        }
    }

    func posterBody(
        showsPlayOverlay: Bool,
        progress: Double?,
        episodeLabel: String?,
        showsFooter: Bool
    ) -> some View {
        VStack(spacing: 0) {
            ZStack {
                clippedImage(showsFooter: showsFooter)

                // ← Netflix logo di pojok kiri atas
                if hasImage {
                    TemplateIcon(
                        image: Image.Brand.logoSingleBadge,
                        size: 10,
                        tint: Color.Primary.red
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(6)
                }

                // ← Play button overlay (untuk continue watching)
                if showsPlayOverlay {
                    VideoControlButton(variant: .play(.thumbnailLarge)) { onPlayTap?() }
                }

                // ← TopTen badge di pojok kanan atas
                if hasImage, badge.showTopTen {
                    TopTenBadge()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }

                // ← Episode label
                if let episodeLabel {
                    Text(episodeLabel)
                        .font(.Typography.Medium.caption2)
                        .foregroundStyle(Color.Neutral.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, showsFooter ? 15 : 3)
                }

                // ← Stacked bottom badges (max 2)
                if hasImage, !badge.bottomBadges.isEmpty {
                    bottomBadgesOverlay
                }
            }

            // ← Continue Watching footer
            if showsFooter, let progress {
                progressTrack(progress: progress)
                iconRow
            }
        }
        .frame(width: size.width, height: size.height, alignment: .top)
    }

    // MARK: - Bottom Badges Overlay

    private var bottomBadgesOverlay: some View {
        VStack(spacing: 0) { // ← ubah gap antar badge (0 = rapat)
            // ← badge pertama (atas) — white bg black fg (dibalik)
            if let first = badge.bottomBadges.first {
                Text(first.text.uppercased())
                    .font(.system(size: 7, weight: .bold)) // ← ubah font size badge atas
                    .foregroundStyle(Color.Neutral.black) // ← ubah warna teks badge atas (hitam)
                    .padding(.horizontal, 6) // ← ubah padding horizontal badge atas
                    .padding(.vertical, 2) // ← ubah padding vertical badge atas
                    .background(Color.Neutral.white) // ← ubah warna background badge atas (putih)
                    .cornerRadius(2) // ← ubah corner radius badge atas
            }

            // ← badge kedua (bawah) — red bg white fg (dibalik)
            if badge.bottomBadges.count > 1 {
                let second = badge.bottomBadges[1]
                Text(second.text.uppercased())
                    .font(.system(size: 7, weight: .bold)) // ← ubah font size badge bawah
                    .foregroundStyle(Color.Neutral.white) // ← ubah warna teks badge bawah (putih)
                    .padding(.horizontal, 6) // ← ubah padding horizontal badge bawah
                    .padding(.vertical, 2) // ← ubah padding vertical badge bawah
                    .background(Color.Primary.red) // ← ubah warna background badge bawah (merah)
                    .cornerRadius(2) // ← ubah corner radius badge bawah
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, episodeLabelForBadge != nil ? 16 : 0) // ← ubah offset jika ada episode label
    }

    private var episodeLabelForBadge: String? {
        if case .continueWatching(_, let label) = kind { return label }
        return nil
    }

    @ViewBuilder
    func clippedImage(showsFooter: Bool) -> some View {
        if showsFooter {
            imageLayer
                .frame(width: size.width, height: TitleCardMetrics.posterImageHeight)
                .clipShape(
                    .rect(
                        topLeadingRadius: TitleCardMetrics.cornerRadius,
                        topTrailingRadius: TitleCardMetrics.cornerRadius
                    )
                )
        } else {
            imageLayer
                .frame(width: size.width, height: TitleCardMetrics.posterImageHeight)
                .clipShape(RoundedRectangle(cornerRadius: TitleCardMetrics.cornerRadius))
        }
    }

    func progressTrack(progress: Double) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Color.Neutral.greyLight2
                Color.Primary.red
                    .frame(width: geometry.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(width: size.width, height: 3)
    }

    var iconRow: some View {
        HStack(spacing: 52) {
            Button { onInfoTap?() } label: {
                TemplateIcon(image: Image.Icon.info, size: 20, tint: footerIconTint)
            }
            Button { onMoreTap?() } label: {
                KebabDots()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(footerIconTint)
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 6)
        .padding(.horizontal, 7)
        .frame(width: size.width)
        .background(hasImage ? Color.Neutral.greyDark2 : .clear)
    }

    var footerIconTint: Color {
        hasImage ? Color.Neutral.greyLight1 : Color.Neutral.white
    }
}

// MARK: - Top Search

private extension TitleCard {

    var topSearchBody: some View {
        ZStack {
            imageLayer
                .frame(width: TitleCardMetrics.topSearch.size.width, height: TitleCardMetrics.topSearch.size.height)
                .clipShape(RoundedRectangle(cornerRadius: TitleCardMetrics.cornerRadius))

            // ← Netflix logo di pojok kiri atas
            if hasImage {
                TemplateIcon(
                    image: Image.Brand.logoSingleBadge,
                    size: 6,
                    tint: Color.Primary.red
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(4)
            }

            // ← TopTen badge di pojok kanan atas
            if badge.showTopTen {
                TopTenBadge(scale: TitleCardMetrics.topSearchBadgeScale, cornerRadius: TitleCardMetrics.cornerRadius)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .frame(width: TitleCardMetrics.topSearch.size.width, height: TitleCardMetrics.topSearch.size.height)
    }
}

// MARK: - Shared

private extension TitleCard {

    @ViewBuilder
    var imageLayer: some View {
        if hasImage {
            background()
        } else {
            ZStack(alignment: .topLeading) {
                Color.Neutral.grey.opacity(0.4)
                TemplateIcon(image: Image.Brand.logoSingleBadge, size: 8, tint: Color.Primary.red)
                    .rotationEffect(.degrees(180))
                    .padding(6)
            }
        }
    }
}

// MARK: - Kebab Dots Shape

private struct KebabDots: Shape {
    func path(in rect: CGRect) -> Path {
        let dotRadius = rect.width * 0.12
        let spacing = rect.height / 3
        var path = Path()
        for i in 0..<3 {
            let center = CGPoint(x: rect.midX, y: spacing * CGFloat(i + 1) - spacing / 2)
            path.addEllipse(in: CGRect(
                x: center.x - dotRadius,
                y: center.y - dotRadius,
                width: dotRadius * 2,
                height: dotRadius * 2
            ))
        }
        return path
    }
}

// MARK: - Metrics

private enum TitleCardMetrics {
    case standard
    case continueWatching
    case topSearch

    var size: CGSize {
        switch self {
        case .standard: CGSize(width: 106, height: 152)
        case .continueWatching: CGSize(width: 106, height: 188)
        case .topSearch: CGSize(width: 96, height: 54)
        }
    }

    static let posterImageHeight: CGFloat = 152
    static let cornerRadius: CGFloat = 4
    static let topSearchBadgeScale: CGFloat = 0.53
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            Text("Standard").font(.headline).foregroundStyle(.white)
            HStack(spacing: 8) {
                TitleCard(kind: .standard, hasImage: false) { Color.clear }
                TitleCard(kind: .standard, badge: BadgeConfig(showTopTen: true)) { Color.Neutral.greyDark1 }
                TitleCard(kind: .standard, badge: BadgeConfig(
                    bottomBadges: [
                        .init(text: "New Episodes", style: .whiteBgBlackFg),
                        .init(text: "Season 2", style: .redBgWhiteFg)
                    ]
                )) { Color.Neutral.greyDark1 }
            }

            Text("Continue Watching").font(.headline).foregroundStyle(.white)
            HStack(spacing: 8) {
                TitleCard(kind: .continueWatching(progress: 0.3, episodeLabel: "S0:E00"), hasImage: false) { Color.clear }
                TitleCard(kind: .continueWatching(progress: 0.3, episodeLabel: "S0:E00"), badge: BadgeConfig(showTopTen: true)) { Color.Neutral.greyDark1 }
                TitleCard(kind: .continueWatching(progress: 0.6, episodeLabel: "S1:E05"), badge: BadgeConfig(
                    bottomBadges: [
                        .init(text: "New Episodes", style: .whiteBgBlackFg),
                        .init(text: "Tonton Sekarang", style: .redBgWhiteFg)
                    ]
                )) { Color.Neutral.greyDark1 }
            }

            Text("Top Search").font(.headline).foregroundStyle(.white)
            HStack(spacing: 8) {
                TitleCard(kind: .topSearch, hasImage: false) { Color.clear }
                TitleCard(kind: .topSearch, badge: BadgeConfig(showTopTen: true)) { Color.Neutral.greyDark1 }
            }
        }
        .padding()
    }
    .background(Color.Neutral.black)
}
