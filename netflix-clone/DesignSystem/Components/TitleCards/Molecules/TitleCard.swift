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