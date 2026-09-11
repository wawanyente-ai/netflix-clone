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
    var onStartPlaying: (() -> Void)? = nil // ← log history (sekali per video)
    var onProgressSave: ((Double, Double) -> Void)? = nil // ← (position, duration) → backend

    init(
        seriesTitle: String = "Demo Video",
        episodeLabel: String = "Big Buck Bunny",
        demoIndex: Int = 0,
        onCloseTap: @escaping () -> Void = {},
        onStartPlaying: (() -> Void)? = nil,
        onProgressSave: ((Double, Double) -> Void)? = nil
    ) {
        _viewModel = State(initialValue: VideoPlayerViewModel(demoIndex: demoIndex))
        self.seriesTitle = seriesTitle
        self.episodeLabel = episodeLabel
        self.onCloseTap = onCloseTap
        self.onStartPlaying = onStartPlaying
        self.onProgressSave = onProgressSave
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
            viewModel.onProgressUpdate = onProgressSave // ← lapor progress ke backend
            viewModel.onVideoStart = onStartPlaying // ← log history saat video mulai
            Task { await viewModel.loadCatalog() } // ← refresh katalog dari backend
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.togglePlay()
            }
        }
        .onDisappear {
            viewModel.player?.pause()
        }
    }

    // MARK: - Portrait Player (controls menyatu dengan video)

    private var portraitPlayer: some View {
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
                    .padding(.top, 12)

                    Spacer()

                    // ← center controls (overlay di video)
                    VideoControlsBar(
                        isPlaying: $viewModel.isPlaying,
                        size: .large,
                        onSkipBack: { viewModel.skipBackward() },
                        onSkipForward: { viewModel.skipForward() },
                        onPlayPause: { viewModel.togglePlay() } // ← driver player asli
                    )
                    .padding(.bottom, 8)

                    // ← progress bar (menempel di tepi bawah video)
                    VideoProgressBar(
                        progress: progressBinding,
                        size: .large,
                        timeLabel: viewModel.currentTime,
                        onSeek: { ratio in
                            viewModel.seekTo(ratio) // ← seek via timeline
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
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

    // MARK: - Landscape Player

    private var landscapePlayer: some View {
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
                .padding(.top, 8)

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
                .padding(.bottom, 8)
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

    // MARK: - Fullscreen Button (glyph sendiri, tanpa SF Symbol)

    private func fullscreenButton(intoLandscape: Bool) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isLandscape = intoLandscape
            }
        } label: {
            HStack(spacing: 6) {
                fullscreenGlyph
                    .frame(width: 18, height: 18)
                if !intoLandscape {
                    Text("Kecilkan")
                        .font(.Typography.Medium.caption2)
                        .foregroundStyle(Color.Semantic.textPrimary)
                }
            }
            .padding(8)
            .background(Color.Neutral.black.opacity(0.5))
            .clipShape(Capsule())
        }
    }

    /// Glyph fullscreen: dua sudut (kiri-atas + kanan-bawah).
    private var fullscreenGlyph: some View {
        Path { path in
            let s: CGFloat = 8
            // ← sudut kiri-atas
            path.move(to: CGPoint(x: 0, y: s))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: s, y: 0))
            // ← sudut kanan-bawah
            path.move(to: CGPoint(x: 20 - s, y: 20))
            path.addLine(to: CGPoint(x: 20, y: 20))
            path.addLine(to: CGPoint(x: 20, y: 20 - s))
        }
        .stroke(Color.Neutral.white, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
    }

    // MARK: - Progress Binding (hindari konflik time observer vs drag)

    private var progressBinding: Binding<Double> {
        Binding(
            get: { viewModel.isScrubbing ? viewModel.scrubProgress : viewModel.progress },
            set: { newValue in
                viewModel.scrubProgress = newValue
                viewModel.isScrubbing = true
            }
        )
    }

    // MARK: - Demo Video Picker

    private var demoVideoPicker: some View {
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

// MARK: - Metrics

private enum Metrics {
    static let videoHeight: CGFloat = 260 // ← ubah tinggi area video portrait
}

// MARK: - Preview

#Preview {
    VideoPlayerPage()
}