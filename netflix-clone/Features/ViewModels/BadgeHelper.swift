//
//  BadgeHelper.swift
//  netflix-clone
//

import Foundation

/// Shared helper for generating bottom badges on TitleCard.
enum BadgeHelper {

    /// Generate bottom badges based on media item data.
    /// Returns max 2 badges: white on top, red on bottom.
    static func generateBadges(for item: MediaItem) -> [BadgeConfig.BottomBadge] {
        var badges: [BadgeConfig.BottomBadge] = []

        // ← badge pertama (putih bg hitam fg — atas)
        if item.voteAverage >= 7.5 {
            badges.append(.init(text: "Top Rated", style: .whiteBgBlackFg))
        } else if item.mediaType == .tv {
            badges.append(.init(text: "Series", style: .whiteBgBlackFg))
        } else {
            badges.append(.init(text: "Film", style: .whiteBgBlackFg))
        }

        // ← badge kedua (merah bg putih fg — bawah) — max 2
        if badges.count < 2, !item.year.isEmpty {
            badges.append(.init(text: item.year, style: .redBgWhiteFg))
        }

        return badges
    }
}
