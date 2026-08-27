//
//  VideoControlsBar.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//


import SwiftUI

/// The primary transport row: skip-back 10s, play/pause, skip-forward 10s.
///
/// Composed entirely from the existing `VideoControlButton` molecule
/// (`Button_And_Tabs/Molecules`) — no new button styling needed here,
/// this just arranges three of them and owns the play/pause toggle.
///
/// ```swift
/// @State private var isPlaying = true
/// VideoControlsBar(isPlaying: $isPlaying, size: .large, onSkipBack: {}, onSkipForward: {})
/// ```
struct VideoControlsBar: View {

    // MARK: Types

    enum Size { case large, small }

    // MARK: Properties

    @Binding var isPlaying: Bool
    var size: Size = .large
    var onSkipBack: () -> Void
    var onSkipForward: () -> Void

    // MARK: Body

    var body: some View {
        HStack(spacing: Metrics.metrics(for: size).gap) {
            // ← skip size ikut bar size
            VideoControlButton(
                variant: .skipBackward(size == .large ? .large : .small),
                action: onSkipBack
            )
            VideoControlButton(variant: playPauseVariant) { isPlaying.toggle() }
            VideoControlButton(
                variant: .skipForward(size == .large ? .large : .small),
                action: onSkipForward
            )
        }
    }
}

// MARK: - Play/Pause

private extension VideoControlsBar {
    var playPauseVariant: VideoControlButton.Variant {
        // ← play/pause size ikut bar size
        isPlaying
            ? .pause(size == .large ? .large : .small)
            : .play(size == .large ? .videoLarge : .videoSmall)
    }
}

// MARK: - Metrics

private extension VideoControlsBar {
    struct Metrics {
        let gap: CGFloat

        static func metrics(for size: Size) -> Metrics {
            switch size {
            case .large: Metrics(gap: 48) // ← ubah gap large (sebelumnya 156, terlalu lebar)
            case .small: Metrics(gap: 32) // ← ubah gap small (sebelumnya 87.36)
            }
        }
    }
}

// MARK: - Preview

#Preview("VideoControlsBar") {
    struct PreviewHost: View {
        @State private var isPlaying = true
        var body: some View {
            VStack(spacing: 24) {
                VideoControlsBar(isPlaying: $isPlaying, size: .large, onSkipBack: {}, onSkipForward: {})
                VideoControlsBar(isPlaying: $isPlaying, size: .small, onSkipBack: {}, onSkipForward: {})
            }
            .padding()
            .background(Color.Neutral.black)
        }
    }
    return PreviewHost()
}