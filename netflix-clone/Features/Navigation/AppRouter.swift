//
//  AppRouter.swift
//  netflix-clone
//

import SwiftUI

/// Central navigation state manager.
/// Controls onboarding → main flow, stack navigation, auth session (guest vs
/// signed-in), dan data backend (profil, riwayat).
@Observable
final class AppRouter {

    // MARK: - Onboarding

    var onboardingComplete: Bool {
        get { UserDefaults.standard.bool(forKey: "onboardingComplete") } // ← baca dari UserDefaults
        set { UserDefaults.standard.set(newValue, forKey: "onboardingComplete") } // ← tulis ke UserDefaults
    }

    // MARK: - Auth Session

    /// True setelah pengguna sign-in. Default guest → boleh browsing
    /// Home/Search/Klip tanpa login (lihat docs/auth-gating.md).
    var isSignedIn: Bool {
        get { UserDefaults.standard.bool(forKey: "isSignedIn") } // ← baca status login
        set { UserDefaults.standard.set(newValue, forKey: "isSignedIn") } // ← simpan status login
    }

    /// State untuk modal sign-in yang dipicu fitur ber-lock.
    var showSignInSheet = false

    /// Aksi yang ditunda sampai sign-in selesai (misal save My List).
    private var pendingAction: (() -> Void)?

    // MARK: - Backend Session (hasil /v1/auth/signin)

    var backendUser: BackendUser?           // ← user hasil sign-in
    var profiles: [UserProfile] = []        // ← daftar profil
    var selectedProfileId: String?          // ← profil aktif (persist)
    var historyEntries: [HistoryEntryModel] = [] // ← riwayat profil aktif
    var continueWatching: [WatchProgressModel] = [] // ← lanjut tonton
    var mylistItems: [WatchlistItemModel] = [] // ← my list profil aktif

    /// Profil yang sedang dipilih.
    var currentProfile: UserProfile? {
        profiles.first { $0.profileId == selectedProfileId }
    }

    /// Fitur lock: jalankan `action` kalau sudah login; kalau belum, buka sheet
    /// sign-in lalu jalanin `action` setelah login sukses.
    func requireAuth(_ action: @escaping () -> Void) {
        if isSignedIn {
            action()
        } else {
            pendingAction = action
            showSignInSheet = true
        }
    }

    /// Dipanggil saat user pilih Google di sheet. Jalankan sign-in async;
    /// pending action dieksekusi setelah user + profile siap.
    /// Returns: true kalau berhasil, false kalau gagal/timeout.
    @MainActor
    func completeSignIn() async -> Bool {
        let success = await performGoogleSignIn()
        if success {
            showSignInSheet = false
        }
        return success
    }

    /// Real Google Sign-In flow: Firebase Auth → ID token → backend POST /v1/auth/signin.
    @MainActor
    private func performGoogleSignIn() async -> Bool {
        do {
            let token = try await AuthService.signInWithGoogle() // ← Google Sign-In
            BackendConfig.idToken = token // ← simpan Firebase ID token
            await signIn() // ← POST /v1/auth/signin → user + profiles
            return isSignedIn
        } catch {
            // ← Google sign-in gagal: tetap guest, kasih kesempatan retry
            isSignedIn = false
            resetSession()
            return false
        }
    }

    /// RESTORE session pas app dibuka: flag sudah true (persist), fetch ulang
    /// user + profiles dari backend untuk validasi.
    func restoreSessionIfNeeded() {
        if let kept = UserDefaults.standard.string(forKey: "selectedProfileId") {
            selectedProfileId = kept // ← pulihkan profil persist
        }
        guard isSignedIn else { return }
        Task { await signIn() }
    }

    /// POST /v1/auth/signin → simpan user+profiles. Kalau belum ada profil, buat
    /// "Profil 1" (Netflix-style default).
    func signIn() async {
        do {
            let res = try await BackendService.signIn()
            backendUser = res.user
            profiles = res.profiles

            let kept = selectedProfileId.flatMap { id in
                res.profiles.first { $0.profileId == id }
            }
            if kept != nil {
                // ← profil aktif dipertahankan
            } else if res.profiles.isEmpty {
                let created = try await BackendService.createProfile(name: "Profil 1")
                profiles = [created]
                selectedProfileId = created.profileId
            } else {
                selectedProfileId = res.profiles.first?.profileId
            }
            persistSelectedProfile()

            withAnimation { isSignedIn = true }
            await loadNetflixSaya()
            pendingAction?()
            pendingAction = nil
        } catch {
            // ← backend offline / gagal: tetap guest, kasih kesempatan retry
            isSignedIn = false
            resetSession()
        }
    }

    func signOut() {
        withAnimation { isSignedIn = false }
        AuthService.signOut() // ← Firebase + Google Sign-Out
        resetSession()
    }

    private func resetSession() {
        backendUser = nil
        profiles = []
        selectedProfileId = nil
        historyEntries = []
        continueWatching = []
        mylistItems = []
        pendingAction = nil
        BackendConfig.idToken = nil
    }

    private func persistSelectedProfile() {
        UserDefaults.standard.set(selectedProfileId, forKey: "selectedProfileId")
    }

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

    // MARK: - Tab Selection

    var selectedTab: NavigationBar.Tab = .home

    // MARK: - Navigation Paths

    var homePath = NavigationPath()
    var klipPath = NavigationPath()     // ← path untuk klip tab
    var searchPath = NavigationPath()
    var downloadsPath = NavigationPath() // ← path untuk downloads tab

    // MARK: - Selected Media (untuk push ke detail)

    var selectedMediaItem: MediaItem?

    // MARK: - Actions

    func completeOnboarding() {
        withAnimation { onboardingComplete = true }
    }

    func navigateToTitleDetail(from tab: NavigationBar.Tab) {
        switch tab {
        case .home:
            homePath.append(NavigationRoute.titleDetail)
        case .klip:
            klipPath.append(NavigationRoute.titleDetail)
        case .search:
            searchPath.append(NavigationRoute.titleDetail)
        case .downloads:
            downloadsPath.append(NavigationRoute.titleDetail)
        }
    }

    func navigateToVideoPlayer(from tab: NavigationBar.Tab) {
        switch tab {
        case .home:
            homePath.append(NavigationRoute.videoPlayer)
        case .klip:
            klipPath.append(NavigationRoute.videoPlayer)
        case .search:
            searchPath.append(NavigationRoute.videoPlayer)
        case .downloads:
            downloadsPath.append(NavigationRoute.videoPlayer)
        }
    }

    func navigateToMyList() {
        downloadsPath.append(NavigationRoute.myList) // ← push My List page di tab downloads
    }

    /// Buka detail dari item My List. MediaItem dibuat minimal karena yg dipakai
    /// detail page cuma mediaType + mediaId (+ title untuk fallback).
    func openMyListDetail(_ item: WatchlistItemModel) {
        selectedMediaItem = MediaItem(
            id: item.mediaId,
            title: item.title,
            overview: "",
            posterPath: item.posterPath.isEmpty ? nil : item.posterPath,
            backdropPath: nil,
            voteAverage: 0,
            releaseDate: "",
            mediaType: item.mediaType == "tv" ? .tv : .movie,
            genreIds: [],
            runtime: nil
        )
        downloadsPath.append(NavigationRoute.titleDetail)
    }

    /// Hapus item dari My List lalu refresh.
    func removeFromMyList(_ item: WatchlistItemModel) async {
        guard let profile = currentProfile else { return }
        _ = try? await BackendService.toggleMyList(
            profileId: profile.profileId,
            mediaType: item.mediaType,
            mediaId: item.mediaId,
            title: item.title,
            posterPath: item.posterPath
        )
        if let updated = try? await BackendService.watchlist(profileId: profile.profileId) {
            mylistItems = updated
        }
    }

    func popToRoot(from tab: NavigationBar.Tab) {
        switch tab {
        case .home:
            homePath = NavigationPath()
        case .klip:
            klipPath = NavigationPath()
        case .search:
            searchPath = NavigationPath()
        case .downloads:
            downloadsPath = NavigationPath()
        }
    }

    /// Reset semua path saat ganti tab — kembali ke halaman utama tiap tab.
    func popAllTabs() {
        homePath = NavigationPath()
        klipPath = NavigationPath()
        searchPath = NavigationPath()
        downloadsPath = NavigationPath()
        selectedMediaItem = nil
    }
}

// MARK: - Navigation Route

enum NavigationRoute: Hashable {
    case titleDetail
    case videoPlayer
    case myList
}