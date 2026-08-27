//
//  netflix_cloneApp.swift
//  netflix-clone
//

import SwiftUI

@main
struct netflix_cloneApp: App {
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            rootContent
        }
    }

    // MARK: - Root Content

    @ViewBuilder
    private var rootContent: some View {
        if router.onboardingComplete {
            mainTabView
        } else {
            OnboardingPage {
                router.completeOnboarding()
            }
        }
    }

    // MARK: - Main Tab View

    private var mainTabView: some View {
        ZStack(alignment: .bottom) {
            tabContent
                .toolbar(.hidden, for: .tabBar)

            NavigationBar(selection: $router.selectedTab) // ← floating pill bar
        }
        .background(Color.Semantic.background.ignoresSafeArea())
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch router.selectedTab {
        case .home:
            homeTab
        case .klip:
            klipTab
        case .search:
            searchTab
        case .downloads:
            downloadsTab
        }
    }

    // MARK: - Home Tab

    private var homeTab: some View {
        NavigationStack(path: $router.homePath) {
            HomePage(onTitleTap: { item in
                router.selectedMediaItem = item
                router.navigateToTitleDetail(from: .home)
            })
            .navigationDestination(for: NavigationRoute.self) { route in
                switch route {
                case .titleDetail:
                    TitleDetailPage(
                        mediaType: router.selectedMediaItem?.mediaType.rawValue ?? "movie",
                        mediaId: router.selectedMediaItem?.id ?? 0,
                        onPlayTap: { router.navigateToVideoPlayer(from: .home) },
                        onTitleTap: { item in
                            router.selectedMediaItem = item
                            router.navigateToTitleDetail(from: .home)
                        }
                    )
                case .videoPlayer:
                    VideoPlayerPage(
                        seriesTitle: router.selectedMediaItem?.title ?? "Demo Video",
                        episodeLabel: "Big Buck Bunny",
                        demoIndex: 0
                    )
                }
            }
        }
    }

    // MARK: - Klip Tab

    private var klipTab: some View {
        KlipPage()
    }

    // MARK: - Search Tab

    private var searchTab: some View {
        NavigationStack(path: $router.searchPath) {
            SearchPage(onTitleTap: { item in
                router.selectedMediaItem = item
                router.navigateToTitleDetail(from: .search)
            })
            .navigationDestination(for: NavigationRoute.self) { route in
                switch route {
                case .titleDetail:
                    TitleDetailPage(
                        mediaType: router.selectedMediaItem?.mediaType.rawValue ?? "movie",
                        mediaId: router.selectedMediaItem?.id ?? 0,
                        onPlayTap: { router.navigateToVideoPlayer(from: .search) },
                        onTitleTap: { item in
                            router.selectedMediaItem = item
                            router.navigateToTitleDetail(from: .search)
                        }
                    )
                case .videoPlayer:
                    VideoPlayerPage(
                        seriesTitle: router.selectedMediaItem?.title ?? "Demo Video",
                        episodeLabel: "Big Buck Bunny",
                        demoIndex: 0,
                        onCloseTap: { router.popToRoot(from: .search) }
                    )
                }
            }
        }
    }

    // MARK: - Downloads Tab ("Netflix Saya")

    private var downloadsTab: some View {
        NavigationStack(path: $router.downloadsPath) {
            NetflixSayaPage()
                .navigationDestination(for: NavigationRoute.self) { route in
                    switch route {
                    case .titleDetail:
                        TitleDetailPage(
                            mediaType: router.selectedMediaItem?.mediaType.rawValue ?? "movie",
                            mediaId: router.selectedMediaItem?.id ?? 0
                        )
                    case .videoPlayer:
                        VideoPlayerPage(
                            seriesTitle: router.selectedMediaItem?.title ?? "Demo Video",
                            episodeLabel: "Big Buck Bunny",
                            demoIndex: 0
                        )
                    }
                }
        }
    }
}


