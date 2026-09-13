//
//  VideoPlayerPage.swift
//  netflix-clone
//

import SwiftUI
import AVKit

/// Video player screen: custom player without default controls.
/// Uses PlayerView (AVPlayerLayer wrapper) for full control over playback UI.
struct VideoPlayerPage: View {

    @State var viewModel: VideoPlayerViewModel
    @State var isLandscape = false
    @State var isFullscreen = false // ← mode fullscreen (cover penuh layar)

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
        .fullScreenCover(isPresented: $isFullscreen) { // ← fullscreen: layar penuh, status bar hilang
            fullscreenPlayer
        }
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
}

// MARK: - Metrics

enum Metrics {
    static let videoHeight: CGFloat = 260 // ← ubah tinggi area video portrait
}

// MARK: - Preview

#Preview {
    VideoPlayerPage()
}