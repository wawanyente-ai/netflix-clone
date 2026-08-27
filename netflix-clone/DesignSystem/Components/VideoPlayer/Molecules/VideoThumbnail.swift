//
//  VideoThumbnail.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//


import SwiftUI

/// A video/episode preview thumbnail with a centered play affordance.
///
/// - `.primary`: the large hero thumbnail on a title-details page — red
///   play ring, optional top cast/close controls, optional bottom label
///   (e.g. "Trailer").
/// - `.secondary`: the small thumbnail used in an episode row — white
///   play ring only.
///
/// Image loading is left to the caller via `background` — this component
/// doesn't own artwork, only the play affordance and chrome.
///
/// ```swift
/// VideoThumbnail(variant: .primary(label: "Trailer"), onCastTap: {}, onCloseTap: {}, onPlayTap: {}) {
///     Color.Neutral.greyDark1 // replace with real artwork
/// }
///
/// VideoThumbnail(variant: .secondary, onPlayTap: {}) {
///     Color.Neutral.white.opacity(0.16)
/// }
/// ```
struct VideoThumbnail<Background: View>: View {

    // MARK: Types

    enum Variant {
        case primary(label: String?)
        case secondary
    }

    // MARK: Properties

    let variant: Variant
    var onCastTap: (() -> Void)? = nil
    var onCloseTap: (() -> Void)? = nil
    var onPlayTap: () -> Void
    @ViewBuilder var background: () -> Background

    // MARK: Body

    var body: some View {
        background()
            .overlay(playButton)
            .overlay(alignment: .top) { topControls }
            .overlay(alignment: .bottomLeading) { bottomLabel }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Play Button

private extension VideoThumbnail {
    @ViewBuilder
    var playButton: some View {
        switch variant {
        case .primary:
            VideoControlButton(variant: .play(.videoLarge), action: onPlayTap)
        case .secondary:
            VideoControlButton(variant: .play(.thumbnailLarge), action: onPlayTap)
        }
    }
}

// MARK: - Chrome

private extension VideoThumbnail {
    @ViewBuilder
    var topControls: some View {
        if case .primary = variant, onCastTap != nil || onCloseTap != nil {
            HStack {
                if let onCastTap {
                    VideoControlButton(variant: .mirror, action: onCastTap)
                }
                Spacer()
                if let onCloseTap {
                    VideoControlButton(variant: .close, action: onCloseTap)
                }
            }
            .padding(ThumbnailMetrics.controlInset)
        }
    }

    @ViewBuilder
    var bottomLabel: some View {
        if case .primary(.some(let label)) = variant {
            Text(label)
                .font(.Typography.Bold.label3)
                .foregroundStyle(Color.Neutral.greyLight3)
                .padding(ThumbnailMetrics.labelInset)
        }
    }

    var cornerRadius: CGFloat {
        switch variant {
        case .primary: 16
        case .secondary: 4
        }
    }
}

// MARK: - Metrics

private enum ThumbnailMetrics {
    static let controlInset: CGFloat = 8  // ← ubah inset kontrol atas (cast/close)
    static let labelInset: CGFloat = 15   // ← ubah inset label bawah
}

// MARK: - Preview

#Preview("VideoThumbnail") {
    VStack(spacing: 24) {
        VideoThumbnail(variant: .primary(label: "Trailer"), onCastTap: {}, onCloseTap: {}, onPlayTap: {}) {
            Color.Neutral.greyDark1
        }
        .frame(height: 210)

        VideoThumbnail(variant: .secondary, onPlayTap: {}) {
            Color.Neutral.white.opacity(0.16)
        }
        .frame(width: 124, height: 69)
    }
    .padding()
    .background(Color.Neutral.black)
}