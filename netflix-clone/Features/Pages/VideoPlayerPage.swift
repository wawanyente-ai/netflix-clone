//
//  VideoPlayerPage.swift
//  netflix-clone
//

import SwiftUI
import AVKit

/// Video player screen: custom player without default controls.
/// Uses PlayerView (AVPlayerLayer wrapper) for full control over playback UI.
struct VideoPlayerPage: View {

    @State private var viewModel: VideoPlayerViewModel
    @State private var isLandscape = false

    let seriesTitle: String
    let episodeLabel: String

    var onCloseTap: () -> Void = {}

    init(
        seriesTitle: String = "Demo Video",
        episodeLabel: String = "Big Buck Bunny",
        demoIndex: Int = 0,
        onCloseTap: @escaping () -> Void = {}
    ) {
        _viewModel = State(initialValue: VideoPlayerViewModel(demoIndex: demoIndex))
        self.seriesTitle = seriesTitle
        self.episodeLabel = episodeLabel
        self.onCloseTap = onCloseTap
    }

    var body: some View {
        Group {
            if isLandscape {
                landscapePlayer
            } else {
                portraitPlayer
            }
        }
        .background(Color.Neutral.black.ignoresSafeArea())
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    isLandscape = geo.size.width > geo.size.height // ← pakai GeometryReader
                }
            }
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.togglePlay()
            }
        }
        .onDisappear {
            viewModel.player?.pause()
        }
    }

    // MARK: - Portrait Player

    private var portraitPlayer: some View {
        VStack(spacing: 0) {
            // ← custom player (tanpa default controls)
            if let player = viewModel.player {
                ZStack {
                    PlayerView(player: player)
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    // ← play button overlay (tap untuk play/pause)
                    if !viewModel.isPlaying {
                        Button {
                            viewModel.togglePlay()
                        } label: {
                            Image(systemName: "play.fill")
                                .font(.system(size: 40)) // ← ubah ukuran icon play
                                .foregroundStyle(Color.Semantic.textPrimary)
                                .frame(width: 80, height: 80) // ← ubah ukuran tombol
                                .background(Color.Neutral.black.opacity(0.5)) // ← ubah warna background
                                .clipShape(Circle())
                        }
                    }
                }
            } else {
                Color.Neutral.black
                    .frame(height: 220)
            }

            // ← video info
            VStack(alignment: .leading, spacing: 8) {
                Text(seriesTitle)
                    .font(.Typography.Bold.label1)
                    .foregroundStyle(Color.Semantic.textPrimary)

                Text(episodeLabel)
                    .font(.Typography.Medium.caption1)
                    .foregroundStyle(Color.Semantic.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // ← custom playback controls
            VideoControlsBar(
                isPlaying: $viewModel.isPlaying,
                size: .large,
                onSkipBack: { viewModel.skipBackward() },
                onSkipForward: { viewModel.skipForward() }
            )
            .padding(.top, 16)

            // ← progress bar
            VideoProgressBar(
                progress: $viewModel.progress,
                size: .large,
                timeLabel: viewModel.currentTime
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // ← demo video picker
            demoVideoPicker
                .padding(.horizontal, 16)
                .padding(.top, 16)

            Spacer()
        }
        .padding(.vertical, 16)
    }

    // MARK: - Landscape Player

    private var landscapePlayer: some View {
        ZStack {
            if let player = viewModel.player {
                PlayerView(player: player) // ← custom player, bukan VideoPlayer
            } else {
                Color.Neutral.black
            }

            VStack {
                VideoPlayerTopBar(
                    title: episodeLabel,
                    onCastTap: {},
                    onCloseTap: onCloseTap
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                VideoProgressBar(
                    progress: $viewModel.progress,
                    size: .large,
                    timeLabel: viewModel.currentTime
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
    }

    // MARK: - Demo Video Picker

    private var demoVideoPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Demo Videos")
                .font(.Typography.Medium.caption1)
                .foregroundStyle(Color.Semantic.textTertiary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.demoVideos.enumerated()), id: \.element.id) { index, video in
                        Button {
                            viewModel.loadDemoVideo(at: index) // ← ganti video
                        } label: {
                            VStack(spacing: 4) {
                                PosterImage(url: video.posterURL, width: 80, height: 45, cornerRadius: 4) // ← poster component

                                Text(video.title)
                                    .font(.Typography.Light.caption2)
                                    .foregroundStyle(Color.Semantic.textSecondary)
                                    .lineLimit(1)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VideoPlayerPage()
}
