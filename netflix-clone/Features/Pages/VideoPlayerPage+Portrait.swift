//
//  VideoPlayerPage+Portrait.swift
//  netflix-clone
//

import SwiftUI
import AVKit

extension VideoPlayerPage {

    // MARK: - Portrait Player (controls menyatu dengan video)

    var portraitPlayer: some View {
        VStack(spacing: 0) {
            // ← video full-width + overlay controls di atasnya
            ZStack(alignment: .bottom) {
                if let player = viewModel.player {
                    PlayerView(player: player)
                        .frame(maxWidth: .infinity)
                        .frame(height: Metrics.videoHeight) // ← ubah tinggi video
                        .clipped()
                        .contentShape(Rectangle())
                        .onTapGesture { viewModel.togglePlay() } // ← tap video = play/pause
                        .disabled(viewModel.isScrubbing)
                } else {
                    Color.Neutral.black
                        .frame(maxWidth: .infinity)
                        .frame(height: Metrics.videoHeight)
                }

                // ← gradient biar kontrol kebaca
                LinearGradient(
                    colors: [.clear, Color.Neutral.black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: Metrics.videoHeight)

                // ← top bar: judul + fullscreen
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(seriesTitle)
                                .font(.Typography.Bold.label1)
                                .foregroundStyle(Color.Semantic.textPrimary)
                                .lineLimit(1)
                            Text(episodeLabel)
                                .font(.Typography.Medium.caption1)
                                .foregroundStyle(Color.Semantic.textSecondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        fullscreenButton(intoLandscape: true) // ← tombol fullscreen
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24) // ← turunkan sedikit dari atas

                    Spacer() // ← spacer atas: dorong kontrol ke tengah vertical

                    // ← center controls (di tengah vertical video)
                    VideoControlsBar(
                        isPlaying: $viewModel.isPlaying,
                        size: .large,
                        onSkipBack: { viewModel.skipBackward() },
                        onSkipForward: { viewModel.skipForward() },
                        onPlayPause: { viewModel.togglePlay() } // ← driver player asli
                    )

                    Spacer() // ← spacer bawah: nahan kontrol tetap di tengah

                    // ← progress bar (di bawah, tapi tidak nempel tepi)
                    VideoProgressBar(
                        progress: progressBinding,
                        size: .large,
                        timeLabel: viewModel.currentTime,
                        onSeek: { ratio in
                            viewModel.seekTo(ratio) // ← seek via timeline
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24) // ← jarak dari tepi bawah video
                }
            }
            .frame(height: Metrics.videoHeight)

            // ← demo video picker
            demoVideoPicker
                .padding(.horizontal, 16)
                .padding(.top, 16)

            Spacer()
        }
        .padding(.vertical, 0)
    }

    // MARK: - Progress Binding (hindari konflik time observer vs drag)

    var progressBinding: Binding<Double> {
        Binding(
            get: { viewModel.isScrubbing ? viewModel.scrubProgress : viewModel.progress },
            set: { newValue in
                viewModel.scrubProgress = newValue
                viewModel.isScrubbing = true
            }
        )
    }

    // MARK: - Demo Video Picker

    var demoVideoPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pilih Video")
                .font(.Typography.Medium.caption1)
                .foregroundStyle(Color.Semantic.textTertiary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.demoVideos.enumerated()), id: \.element.id) { index, video in
                        Button {
                            viewModel.loadDemoVideo(at: index) // ← ganti video (auto-play)
                        } label: {
                            VStack(spacing: 4) {
                                ZStack(alignment: .bottomTrailing) {
                                    PosterImage(url: video.posterURL, width: 80, height: 45, cornerRadius: 4) // ← poster component
                                    if index == viewModel.selectedDemoIndex {
                                        LinearGradient(
                                            colors: [Color.Primary.red, Color.Primary.red.opacity(0.6)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .frame(width: 24, height: 3) // ← indikator video aktif
                                    }
                                }
                                Text(video.title)
                                    .font(.Typography.Light.caption2)
                                    .foregroundStyle(
                                        index == viewModel.selectedDemoIndex
                                            ? Color.Semantic.textPrimary // ← aktif: putih
                                            : Color.Semantic.textSecondary
                                    )
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