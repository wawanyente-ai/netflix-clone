//
//  RatingBadge.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//


import SwiftUI

/// **Atom** — small dark badge showing a content rating code (e.g. "TV-MA").
///
/// Used in the static ratings reference grid and inside `VideoMetadataBar`.
struct RatingBadge: View {
    let rating: String

    var body: some View {
        Text(rating)
            // NOTE: Figma calls for a 6pt mark; the DS's smallest role is
            // `caption2` (10pt) — same gap flagged in the Navigation group.
            .font(.Typography.Medium.caption2)
            .tracking(0.6)
            .foregroundStyle(Color.Neutral.greyLight3)
            .padding(Metrics.padding)
            // NOTE: Figma's badge background (#575757, "neutral/grey-dark-1")
            // doesn't match the catalog's `greyDark1` (#323232). Using the
            // catalog token as source of truth rather than the raw hex.
            .background(Color.Neutral.greyDark1)
            .cornerRadius(Metrics.cornerRadius)
    }
}

private extension RatingBadge {
    enum Metrics {
        static let padding: CGFloat = 3
        static let cornerRadius: CGFloat = 2
    }
}

#Preview {
    HStack(spacing: 8) {
        RatingBadge(rating: "TV-MA")
        RatingBadge(rating: "PG-13")
    }
    .padding()
    .background(Color.Neutral.black)
}