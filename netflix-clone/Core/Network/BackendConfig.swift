//
//  BackendConfig.swift
//  netflix-clone
//

import Foundation

/// Konfigurasi backend server (Go + Firebase).
/// Base URL default = localhost (dev, simulator). Saat real Firebase sign-in
/// & Cloud Run ready, ubah lewat Info.plist key `BackendBaseURL`.
enum BackendConfig {

    // MARK: - Base URL

    /// Ambil dari Info.plist `BackendBaseURL` kalau ada; fallback ke localhost dev.
    static var baseURL: URL {
        if let custom = Bundle.main.infoDictionary?["BackendBaseURL"] as? String,
           let url = URL(string: custom) {
            return url // ← base URL dari Info.plist
        }
        return URL(string: "http://localhost:8080")! // ← dev simulator / backend lokal
    }

    // MARK: - Headers

    /// Header authorization. Saat dev bypass backend aktif, token opsional.
    /// Nanti: Firebase ID token hasil sign-in real.
    static var idToken: String? {
        get { UserDefaults.standard.string(forKey: "firebaseIDToken") } // ← baca token
        set {
            if let newValue { UserDefaults.standard.set(newValue, forKey: "firebaseIDToken") }
            else { UserDefaults.standard.removeObject(forKey: "firebaseIDToken") }
        }
    }
}