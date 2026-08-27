//
//  EpisodeSummaryRow.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//


import SwiftUI

/// One row in an episode list: thumbnail + title/duration, followed by a
/// short synopsis line. Composed from `VideoThumbnail`'s `.secondary`
/// variant — image loading is left to the caller, same as there.
///
/// ```swift
/// EpisodeSummaryRow(
///     title: "1. Episode Name",
///     duration: "37m",
///     synopsis: "Episode details are included here...",
///     onPlayTap: {}
/// ) {
///     Color.Neutral.greyDark1 // replace with real artwork
/// }
/// ```
struct EpisodeSummaryRow<Thumbnail: View>: View {
    let title: String
    let duration: String
    let synopsis: String
    var onPlayTap: () -> Void
    @ViewBuilder var thumbnailBackground: () -> Thumbnail

    var body: some View {
        VStack(alignment: .leading, spacing: EpisodeMetrics.verticalSpacing) {
            HStack(spacing: EpisodeMetrics.horizontalSpacing) {
                VideoThumbnail(variant: .secondary, onPlayTap: onPlayTap, background: thumbnailBackground)
                    .frame(width: EpisodeMetrics.thumbnailWidth, height: EpisodeMetrics.thumbnailHeight)

                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        // NOTE: Figma's text color here (#E2E2E2) and the
                        // duration color (#8C8C8C) are close to but not
                        // exact catalog matches — using `greyLight3` /
                        // `grey` as the nearest tokens.
                        .font(.Typography.Light.caption1)
                        .foregroundStyle(Color.Neutral.greyLight3)
                    Text(duration)
                        .font(.Typography.Light.caption2)
                        .foregroundStyle(Color.Neutral.grey)
                }
            }

            Text(synopsis)
                .font(.Typography.Light.caption1)
                .foregroundStyle(Color.Neutral.greyLight3)
        }
    }
}

// MARK: - Metrics

private enum EpisodeMetrics {
    static let verticalSpacing: CGFloat = 8   // ← ubah spacing vertical
    static let horizontalSpacing: CGFloat = 8 // ← ubah spacing horizontal
    static let thumbnailWidth: CGFloat = 124  // ← ubah lebar thumbnail
    static let thumbnailHeight: CGFloat = 69  // ← ubah tinggi thumbnail
}

#Preview {
    EpisodeSummaryRow(
        title: "1. Episode Name",
        duration: "37m",
        synopsis: "Episode details are included here. Typically, this description is around 3 lines long.",
        onPlayTap: {}
    ) {
        Color.Neutral.greyDark1
    }
    .padding()
    .frame(width: 375)
    .background(Color.Neutral.black)
}