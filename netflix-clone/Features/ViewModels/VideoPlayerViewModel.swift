//
//  VideoPlayerViewModel.swift
//  netflix-clone
//

import Foundation
import AVKit

/// Manages Video Player state: playback, progress, brightness, lock, video URL.
/// Loads demo video from Google CDN or trailer from TMDB.
@Observable
final class VideoPlayerViewModel {

    // MARK: - Published State

    var isPlaying: Bool = false                   // ← status play/pause
    var progress: Double = 0.0                    // ← progress video (0...1)
    var brightness: Double = 0.65                 // ← level kecerahan (0...1)
    var isLocked: Bool = false                    // ← status lock layar
    var currentTime: String = "0:00"              // ← waktu saat ini (display)
    var player: AVPlayer?                         // ← AVPlayer instance
    var selectedDemoIndex: Int = 0                // ← indeks video demo aktif
    private var timeObserver: Any?                // ← time observer token
    private var isInitialized = false             // ← flag init

    // MARK: - Demo Videos

    let demoVideos = VideoService.demoVideos     // ← daftar demo video

    /// Current demo video URL.
    var currentVideoURL: URL? {
        demoVideos[safe: selectedDemoIndex]?.url
    }

    // MARK: - Init

    init(demoIndex: Int = 0) {
        selectedDemoIndex = demoIndex
        setupPlayer()
    }

    deinit {
        removeTimeObserver() // ← cleanup observer
    }

    // MARK: - Player Setup

    func setupPlayer() {
        guard let url = currentVideoURL else { return }
        player = AVPlayer(url: url)
        player?.allowsExternalPlayback = true
        addTimeObserver() // ← add time observer untuk progress
        isInitialized = true
    }

    /// Load a different demo video.
    func loadDemoVideo(at index: Int) {
        guard demoVideos.indices.contains(index) else { return }
        selectedDemoIndex = index
        player?.pause()
        removeTimeObserver()
        setupPlayer()
        isPlaying = false // ← reset play state
        progress = 0.0    // ← reset progress
    }

    // MARK: - Time Observer

    private func addTimeObserver() {
        guard let player else { return }
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600) // ← update setiap 0.1 detik
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self, let duration = player.currentItem?.duration.seconds, duration > 0 else { return }
            self.progress = time.seconds / duration // ← update progress
            self.currentTime = self.formatTime(time.seconds) // ← update display time
        }
    }

    private func removeTimeObserver() {
        if let timeObserver, let player {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs) // ← format "M:SS"
    }

    // MARK: - Playback Controls

    func togglePlay() {
        guard let player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }

    func seekTo(_ ratio: Double) {
        guard let player, let duration = player.currentItem?.duration else { return }
        let time = CMTime(seconds: duration.seconds * ratio, preferredTimescale: 600)
        player.seek(to: time)
        progress = min(max(ratio, 0), 1)
    }

    func skipForward() {
        seekTo(progress + 0.05)
    }

    func skipBackward() {
        seekTo(progress - 0.05)
    }

    func toggleLock() {
        isLocked.toggle()
    }

    func setBrightness(_ value: Double) {
        brightness = min(max(value, 0), 1)
    }
}

// MARK: - Array Safe Subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
