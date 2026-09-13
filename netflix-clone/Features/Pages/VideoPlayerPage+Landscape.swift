//
//  VideoPlayerPage+Landscape.swift
//  netflix-clone
//

import SwiftUI
import AVKit

extension VideoPlayerPage {

    // MARK: - Landscape Player

    var landscapePlayer: some View {
        ZStack {
            if let player = viewModel.player {
                PlayerView(player: player) // ← custom player, bukan VideoPlayer
            } else {
                Color.Neutral.black
            }

            VStack {
                HStack {
                    // ← collapse fullscreen (kembali portrait)
                    fullscreenButton(intoLandscape: false)
                    Spacer()
                    Text(episodeLabel)
                        .font(.Typography.Medium.label3)
                        .foregroundStyle(Color.Neutral.white)
                        .lineLimit(1)
                    Spacer()
                    VideoControlButton(variant: .close, action: onCloseTap)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20) // ← judul tidak nempel atas

                Spacer()

                // ← center controls overlay
                VideoControlsBar(
                    isPlaying: $viewModel.isPlaying,
                    size: .large,
                    onSkipBack: { viewModel.skipBackward() },
                    onSkipForward: { viewModel.skipForward() },
                    onPlayPause: { viewModel.togglePlay() }
                )

                VideoProgressBar(
                    progress: progressBinding,
                    size: .large,
                    timeLabel: viewModel.currentTime,
                    onSeek: { ratio in
                        viewModel.seekTo(ratio) // ← seek via timeline
                    }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 24) // ← agak naik dari tepi bawah
            }
            .background(
                // ← gelapin pinggiran biar kontrol kebaca
                LinearGradient(
                    colors: [.clear, Color.Neutral.black.opacity(0.6)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            )
        }
    }
}