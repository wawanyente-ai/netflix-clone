//
//  VideoPlayerPage+Fullscreen.swift
//  netflix-clone
//

import SwiftUI
import AVKit

extension VideoPlayerPage {

    // MARK: - Fullscreen Button (glyph sendiri, tanpa SF Symbol)

    func fullscreenButton(intoLandscape: Bool) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isFullscreen = intoLandscape // ← true = buka cover fullscreen, false = tutup
            }
        } label: {
            // ← icon ikut arah: perbesar = sudut keluar, perkecil = sudut masuk
            glyph(intoLandscape: intoLandscape)
                .frame(width: 18, height: 18)
                .padding(8)
                .background(Color.Neutral.black.opacity(0.5))
                .clipShape(Capsule())
        }
    }

    /// Pilih glyph sesuai arah: perbesar vs perkecil.
    @ViewBuilder
    private func glyph(intoLandscape: Bool) -> some View {
        if intoLandscape {
            expandGlyph
        } else {
            collapseGlyph
        }
    }

    /// Glyph perbesar fullscreen: sudut keluar (kiri-atas + kanan-bawah) — bentuk "><".
    var expandGlyph: some View {
        Path { path in
            let s: CGFloat = 8
            // ← sudut kiri-atas (mengarah ke arah luar)
            path.move(to: CGPoint(x: 0, y: s))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: s, y: 0))
            // ← sudut kanan-bawah (mengarah ke arah luar)
            path.move(to: CGPoint(x: 20 - s, y: 20))
            path.addLine(to: CGPoint(x: 20, y: 20))
            path.addLine(to: CGPoint(x: 20, y: 20 - s))
        }
        .stroke(Color.Neutral.white, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
    }

    /// Glyph perkecil fullscreen: sudut masuk (kebalikan perbesar) — bentuk "<>".
    var collapseGlyph: some View {
        Path { path in
            let s: CGFloat = 8
            // ← sudut kiri-atas (mengarah ke arah dalam)
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: s))
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: s, y: 0))
            // ← sudut kanan-bawah (mengarah ke arah dalam)
            path.move(to: CGPoint(x: 20, y: 20))
            path.addLine(to: CGPoint(x: 20, y: 20 - s))
            path.move(to: CGPoint(x: 20, y: 20))
            path.addLine(to: CGPoint(x: 20 - s, y: 20))
        }
        .stroke(Color.Neutral.white, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
    }

    // MARK: - Fullscreen Player (layar penuh)

    var fullscreenPlayer: some View {
        ZStack {
            if let player = viewModel.player {
                PlayerView(player: player) // ← video memenuhi layar
            } else {
                Color.Neutral.black
            }

            VStack {
                HStack {
                    // ← keluar dari fullscreen (kembali portrait)
                    fullscreenButton(intoLandscape: false)
                    Spacer()
                    Text(episodeLabel)
                        .font(.Typography.Medium.label3)
                        .foregroundStyle(Color.Neutral.white)
                        .lineLimit(1)
                    Spacer()
                    VideoControlButton(variant: .close) { // ← tutup player
                        isFullscreen = false
                        Task {
                            try? await Task.sleep(for: .milliseconds(300)) // ← tunggu cover dismiss
                            onCloseTap()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20) // ← judul tidak nempel atas

                Spacer()

                // ← control di tengah vertical
                VideoControlsBar(
                    isPlaying: $viewModel.isPlaying,
                    size: .large,
                    onSkipBack: { viewModel.skipBackward() },
                    onSkipForward: { viewModel.skipForward() },
                    onPlayPause: { viewModel.togglePlay() }
                )

                Spacer()

                // ← progress bar di bawah, agak naik dari tepi
                VideoProgressBar(
                    progress: progressBinding,
                    size: .large,
                    timeLabel: viewModel.currentTime,
                    onSeek: { ratio in
                        viewModel.seekTo(ratio)
                    }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
            }
            .background(
                // ← gelapin pinggiran biar kontrol kebaca
                LinearGradient(
                    colors: [.clear, Color.Neutral.black.opacity(0.7)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            )
        }
        .background(Color.Neutral.black.ignoresSafeArea())
        .statusBarHidden(true) // ← immersive fullscreen
    }
}