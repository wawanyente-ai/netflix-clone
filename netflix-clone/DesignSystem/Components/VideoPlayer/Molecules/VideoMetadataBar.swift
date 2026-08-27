//
//  VideoMetadataBar.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//


import SwiftUI

/// The metadata row under a title's video player / thumbnail: release
/// year, content rating, duration or season count, and quality badges.
/// Composed from `RatingBadge` and `QualityBadge`.
///
/// ```swift
/// VideoMetadataBar(year: "2022", rating: "TV-MA", duration: "5 Seasons")
/// ```
struct VideoMetadataBar: View {
    let year: String
    let rating: String
    let duration: String
    var qualityBadges: [Image] = []

    var body: some View {
        HStack(spacing: Metrics.spacing) {
            Text(year)
                // NOTE: Figma uses Inter 11pt here; the DS's Typography
                // catalog is Netflix-Sans-only. Closest role used instead
                // of introducing an Inter-specific one.
                .font(.Typography.Medium.caption1)
                .foregroundStyle(Color.Neutral.white)

            RatingBadge(rating: rating)

            Text(duration)
                .font(.Typography.Medium.caption1)
                .foregroundStyle(Color.Neutral.white)

            ForEach(Array(qualityBadges.enumerated()), id: \.offset) { _, mark in
                QualityBadge(mark: mark)
            }
        }
    }
}

private extension VideoMetadataBar {
    enum Metrics {
        static let spacing: CGFloat = 4
    }
}

#Preview {
    VideoMetadataBar(year: "2022", rating: "TV-MA", duration: "5 Seasons")
        .padding()
        .background(Color.Neutral.black)
}