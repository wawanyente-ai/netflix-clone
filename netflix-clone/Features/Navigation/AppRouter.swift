//
//  AppRouter.swift
//  netflix-clone
//

import SwiftUI

/// Central navigation state manager.
/// Controls onboarding → main flow and stack navigation within tabs.
@Observable
final class AppRouter {

    // MARK: - Onboarding

    var onboardingComplete: Bool {
        get { UserDefaults.standard.bool(forKey: "onboardingComplete") } // ← baca dari UserDefaults
        set { UserDefaults.standard.set(newValue, forKey: "onboardingComplete") } // ← tulis ke UserDefaults
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
}

// MARK: - Navigation Route

enum NavigationRoute: Hashable {
    case titleDetail
    case videoPlayer
}
