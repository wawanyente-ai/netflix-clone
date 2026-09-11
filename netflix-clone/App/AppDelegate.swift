//
//  AppDelegate.swift
//  netflix-clone
//

import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import SwiftUI

/// UIApplicationDelegate untuk Firebase setup.
class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure() // ← inisialisasi Firebase dari GoogleService-Info.plist

        // ← cache image lebih besar (AsyncImage pakai URLCache.shared) — kurangi repeat fetch
        URLCache.shared = URLCache(
            memoryCapacity: 80 * 1024 * 1024,   // ← 80 MB memory
            diskCapacity: 300 * 1024 * 1024,    // ← 300 MB disk
            diskPath: "netflix-image-cache"
        )

        return true
    }

    /// Handle Google Sign-In redirect URL scheme.
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        GIDSignIn.sharedInstance.handle(url) // ← Google Sign-In URL handle
    }
}
