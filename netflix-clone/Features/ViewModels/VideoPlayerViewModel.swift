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
    var isScrubbing = false                        // ← sedang drag timeline
    var scrubProgress: Double = 0.0                // ← preview progress saat drag
    var brightness: Double = 0.65                 // ← level kecerahan (0...1)
    var isLocked: Bool = false                    // ← status lock layar
    var currentTime: String = "0:00"              // ← waktu saat ini (display)
    var player: AVPlayer?                         // ← AVPlayer instance
    var selectedDemoIndex: Int = 0                // ← indeks video demo aktif
    private var timeObserver: Any?                // ← time observer token
    private var isInitialized = false             // ← flag init
    private var lastReportedPosition: Double = 0  // ← throttle simpan progress
    private var hasReportedStart = false          // ← cegah log history ganda per video

    /// Dipanggil tiap ~5 detik playback: (position, duration). Pasang dari
    /// VideoPlayerPage untuk lapor ke backend Continue Watching.
    var onProgressUpdate: ((Double, Double) -> Void)?

    /// Dipanggil sekali saat video mulai play (untuk log history). Pasang dari
    /// VideoPlayerPage/AppRouter.
    var onVideoStart: (() -> Void)?

    // MARK: - Demo Videos

    /// Daftar video. Awalnya demo bawaan; saat onAppear, di-refresh dari
    /// katalog backend (`GET /v1/videos`) → hero jadi HLS adaptive stream.
    private(set) var demoVideos = VideoService.demoVideos   // ← daftar video (backend-refresh)
    private var hasLoadedCatalog = false                     // ← flag cegah reload ganda

    /// Current demo video URL.
    var currentVideoURL: URL? {
        demoVideos[safe: selectedDemoIndex]?.url
    }

    // MARK: - Init

    init(demoIndex: Int = 0) {
        selectedDemoIndex = demoIndex
        setupPlayer()
    }

    // MARK: - Catalog

    /// Fetch katalog `/v1/videos`; kalau backend mati, pakai fallback demo.
    func loadCatalog() async {
        guard !hasLoadedCatalog else { return }
        hasLoadedCatalog = true
        do {
            let videos = try await BackendService.streamVideos()
            let mapped = videos.map { video in
                VideoService.DemoVideo(
                    title: video.title,
                    description: video.description,
                    url: URL(string: video.streamUrl)!,
                    posterURL: URL(string: video.posterUrl)
                )
            }
            guard !mapped.isEmpty else { return }
            demoVideos = mapped
            // Reload player supaya stream aktif (HLS mux) langsung ke index sekarang.
            // loadDemoVideo auto-play dengan delay 0.3s.
            loadDemoVideo(at: selectedDemoIndex)
        } catch {
            // ← backend offline: biarkan demo bawaan
        }
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
        isScrubbing = false
        hasReportedStart = false
        autoplayAfterSwitch() // ← auto-play video baru (Netflix-style)
    }

    /// Auto-play 0.3 detik setelah ganti video (biar AVPlayer siap).
    private func autoplayAfterSwitch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }
            self.togglePlay()
        }
    }

    // MARK: - Time Observer

    private func addTimeObserver() {
        guard let player else { return }
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600) // ← update setiap 0.1 detik
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self, let duration = player.currentItem?.duration.seconds, duration > 0 else { return }
            if !isScrubbing { // ← skip update saat pengguna drag timeline
                self.progress = time.seconds / duration // ← update progress
            }
            self.currentTime = self.formatTime(time.seconds) // ← update display time
            self.reportProgressIfNeeded(position: time.seconds, duration: duration)
            self.reportStartIfNeeded()
        }
    }

    /// Fire `onVideoStart` sekali per video saat benar-benar diputar.
    private func reportStartIfNeeded() {
        guard !hasReportedStart, isPlaying, progress > 0 else { return }
        hasReportedStart = true
        onVideoStart?()
    }

    /// Throttle: lapor ke backend tiap ±5 detik untuk update Continue Watching.
    private func reportProgressIfNeeded(position: Double, duration: Double) {
        guard position - lastReportedPosition >= 5 else { return }
        lastReportedPosition = position
        onProgressUpdate?(position, duration)
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
            isPlaying = false
        } else {
            isScrubbing = false // ← selesai mode drag
            player.play()
            isPlaying = true
        }
    }

    func seekTo(_ ratio: Double) {
        guard let player, let duration = player.currentItem?.duration else { return }
        let time = CMTime(seconds: duration.seconds * ratio, preferredTimescale: 600)
        player.seek(to: time)
        progress = min(max(ratio, 0), 1)
        scrubProgress = progress
        isScrubbing = false
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
