//
//  AppRouter+NetflixSaya.swift
//  netflix-clone
//

import SwiftUI

extension AppRouter {

    // MARK: - Netflix Saya Data

    /// Load profil + riwayat + continue watching + my list untuk Netflix Saya & Home.
    func loadNetflixSaya() async {
        guard let profile = currentProfile else { return }
        // ← load history + progress + mylist secara parallel
        async let historyFetch = BackendService.history(profileId: profile.profileId)
        async let progressFetch = BackendService.progress(profileId: profile.profileId)
        async let watchlistFetch = BackendService.watchlist(profileId: profile.profileId)
        do {
            let (history, progress, mylist) = try await (historyFetch, progressFetch, watchlistFetch)
            historyEntries = history
            continueWatching = progress
            mylistItems = mylist
        } catch {
            historyEntries = [] // ← backend offline: biarkan kosong
            continueWatching = []
            mylistItems = []
        }
    }

    func selectProfile(_ profileId: String) {
        selectedProfileId = profileId
        persistSelectedProfile()
        Task { await loadNetflixSaya() } // ← muat ulang riwayat profil baru
    }

    // MARK: - Gated Actions

    /// My List toggle untuk hero Home (butuh login + profil aktif).
    func toggleHeroMyList() async {
        guard let profile = currentProfile, let item = selectedMediaItem else { return }
        let key = "\(item.mediaType.rawValue)-\(item.id)"
        savingMyListId = key // ← aktifkan loading state tombol
        defer { savingMyListId = nil } // ← reset setelah selesai (sukses/gagal)

        _ = try? await BackendService.toggleMyList(
            profileId: profile.profileId,
            mediaType: item.mediaType.rawValue,
            mediaId: item.id,
            title: item.title,
            posterPath: item.posterPath ?? "" // ← path TMDB opsional
        )
        // ← refresh my list setelah toggle
        if let updated = try? await BackendService.watchlist(profileId: profile.profileId) {
            mylistItems = updated
        }
    }

    /// Download (butuh login + profil). Belum ada storage offline; stub sampai
    /// fitur download terisi (lihat docs/auth-gating.md).
    func downloadCurrentTitle() async {
        // TODO: simpan ke local storage + daftarkan di profil downloads.
    }

    /// Save playback progress ke backend (Continue Watching). Butuh login.
    @MainActor
    func saveProgress(position: Double, duration: Double) async {
        guard let profile = currentProfile, let item = selectedMediaItem else { return }
        _ = try? await BackendService.saveProgress(
            profileId: profile.profileId,
            mediaType: item.mediaType.rawValue,
            mediaId: item.id,
            position: position,
            duration: duration,
            title: item.title,
            posterPath: item.posterPath ?? ""
        )
        // ← refresh continue watching biar rail Home langsung update
        if let updated = try? await BackendService.progress(profileId: profile.profileId) {
            continueWatching = updated
        }
    }

    /// True kalau media ada di My List profil aktif.
    func isInMyList(mediaType: String, mediaId: Int) -> Bool {
        mylistItems.contains { $0.mediaType == mediaType && $0.mediaId == mediaId }
    }

    /// True kalau media sedang di-proses toggle My List (buat loading state).
    func isSavingMyList(mediaType: String, mediaId: Int) -> Bool {
        savingMyListId == "\(mediaType)-\(mediaId)"
    }

    /// Catat tontonan ke riwayat (POST history). Dipanggil sekali per video mulai play.
    @MainActor
    func logWatchHistory() async {
        guard let profile = currentProfile, let item = selectedMediaItem else { return }
        _ = try? await BackendService.logHistory(
            profileId: profile.profileId,
            mediaType: item.mediaType.rawValue,
            mediaId: item.id,
            title: item.title,
            posterPath: item.posterPath ?? ""
        )
        // ← refresh riwayat supaya langsung tampil
        if let updated = try? await BackendService.history(profileId: profile.profileId) {
            historyEntries = updated
        }
    }
}
