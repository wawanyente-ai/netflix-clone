//
//  AppRouter+Navigation.swift
//  netflix-clone
//

import SwiftUI

extension AppRouter {

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

    /// Pilih tab aktif: tab tujuan selalu balik ke root (tutup detail/player yang
    /// masih terbuka). Tab lain tetap mempertahankan state-nya.
    func selectTab(_ tab: NavigationBar.Tab) {
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
        selectedMediaItem = nil
        withAnimation(.easeInOut(duration: 0.2)) { // ← animasi sama dengan NavigationBar
            selectedTab = tab
        }
    }
}
