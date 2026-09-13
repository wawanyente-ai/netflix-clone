//
//  AppRouter.swift
//  netflix-clone
//

import SwiftUI
import FirebaseAuth

/// Central navigation state manager.
/// Controls onboarding → main flow, stack navigation, auth session (guest vs
/// signed-in), dan data backend (profil, riwayat).
@Observable
final class AppRouter {

    // MARK: - Home Data (Persistent across tab switches)

    var homeViewModel: HomeViewModelCached

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

    /// Media yang sedang di-toggle My List ("\(mediaType)-\(mediaId)"). Dipakai
    /// buat loading state di tombol My List. Nil saat tidak ada proses.
    var savingMyListId: String?

    /// Profil yang sedang dipilih.
    var currentProfile: UserProfile? {
        profiles.first { $0.profileId == selectedProfileId }
    }

    // MARK: - Init

    init() {
        self.homeViewModel = HomeViewModelCached()
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
            // ← kirim nama dari Firebase sebagai fallback displayName
            let firebaseName = Auth.auth().currentUser?.displayName
            await signIn(preferredName: firebaseName) // ← POST /v1/auth/signin → user + profiles
            return isSignedIn
        } catch {
            // ← Google sign-in gagal: tetap guest, kasih kesempatan retry
            isSignedIn = false
            resetSession()
            return false
        }
    }

    /// RESTORE session pas app dibuka: pulihkan user+profiles dari cache lokal
    /// (biar login instan + bisa offline), lalu refresh dari backend.
    func restoreSessionIfNeeded() {
        if let kept = UserDefaults.standard.string(forKey: "selectedProfileId") {
            selectedProfileId = kept // ← pulihkan profil persist
        }
        // ← hydrate cache: info user tidak hilang pas app dibuka ulang
        if loadCachedSession() {
            if selectedProfileId == nil || !profiles.contains(where: { $0.profileId == selectedProfileId }) {
                selectedProfileId = profiles.first?.profileId
            }
            withAnimation { isSignedIn = true }
        }
        guard isSignedIn else { return }
        Task { await signIn() } // ← refresh background: validasi token + sinkron profil
    }

    /// POST /v1/auth/signin → simpan user+profiles. Kalau belum ada profil, buat
    /// profil default bernama displayName user (fallback "Profil 1").
    func signIn(preferredName: String? = nil) async {
        do {
            let res = try await BackendService.signIn(displayName: preferredName)
            backendUser = res.user
            profiles = res.profiles

            let kept = selectedProfileId.flatMap { id in
                res.profiles.first { $0.profileId == id }
            }
            if kept != nil {
                // ← profil aktif dipertahankan
            } else if res.profiles.isEmpty {
                // ← nama profil default dari display name user, bukan hardcoded
                let name = Self.defaultProfileName(displayName: res.user.displayName, email: res.user.email)
                let created = try await BackendService.createProfile(name: name)
                profiles = [created]
                selectedProfileId = created.profileId
            } else {
                selectedProfileId = res.profiles.first?.profileId
            }
            persistSelectedProfile()
            saveCachedSession() // ← simpan info user + profil ke lokal

            withAnimation { isSignedIn = true }
            await loadNetflixSaya()
            pendingAction?()
            pendingAction = nil
        } catch {
            if case BackendError.unauthorized = error {
                // ← token invalid/expired: logout bersih (flag + token + cache)
                isSignedIn = false
                resetSession()
            } else {
                // ← backend offline: biarkan session dari cache tetap login
            }
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
        UserDefaults.standard.removeObject(forKey: Self.cachedUserKey)
        UserDefaults.standard.removeObject(forKey: Self.cachedProfilesKey)
    }

    // MARK: - Local Session Cache

    private static let cachedUserKey = "cachedBackendUser"
    private static let cachedProfilesKey = "cachedProfiles"

    /// Simpan user + profiles ke UserDefaults (JSON). Dipanggil tiap sign-in
    /// sukses; supaya info user tersimpan di perangkat, bukan cuma di memori.
    private func saveCachedSession() {
        let d = UserDefaults.standard
        if let user = backendUser, let data = try? JSONEncoder().encode(user) {
            d.set(data, forKey: Self.cachedUserKey)
        }
        if let data = try? JSONEncoder().encode(profiles) {
            d.set(data, forKey: Self.cachedProfilesKey)
        }
    }

    /// Muat user + profiles dari cache lokal. Returns false kalau belum pernah
    /// sign-in atau cache kosong.
    private func loadCachedSession() -> Bool {
        let d = UserDefaults.standard
        guard let userData = d.data(forKey: Self.cachedUserKey),
              let user = try? JSONDecoder().decode(BackendUser.self, from: userData),
              let profilesData = d.data(forKey: Self.cachedProfilesKey),
              let cachedProfiles = try? JSONDecoder().decode([UserProfile].self, from: profilesData)
        else { return false }
        backendUser = user
        profiles = cachedProfiles
        return true
    }

    /// Nama profil default saat user baru belum punya profil: displayName user,
    /// lalu fallback nama dari email ("dewi.maya@gmail.com" → "Dewi Maya"),
    /// terakhir "Profil 1". Dibatasi 30 karakter (= MaxProfileNameLen).
    private static func defaultProfileName(displayName: String, email: String) -> String {
        let fromDisplay = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !fromDisplay.isEmpty {
            return String(fromDisplay.prefix(30))
        }
        let fromEmail = nameFromEmail(email)
        if !fromEmail.isEmpty {
            return String(fromEmail.prefix(30))
        }
        return "Profil 1"
    }

    /// "dewi.maya@gmail.com" → "Dewi Maya". Pemisah: titik, underscore, dash.
    private static func nameFromEmail(_ email: String) -> String {
        let prefix = email.split(separator: "@").first.map(String.init) ?? email
        let words = prefix
            .split { $0 == "." || $0 == "_" || $0 == "-" }
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { word -> String in
                guard let first = word.first else { return String(word) }
                return String(first).uppercased() + word.dropFirst().lowercased()
            }
        return words.joined(separator: " ")
    }

    func persistSelectedProfile() {
        UserDefaults.standard.set(selectedProfileId, forKey: "selectedProfileId")
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
}

// MARK: - Navigation Route

enum NavigationRoute: Hashable {
    case titleDetail
    case videoPlayer
    case myList
}
