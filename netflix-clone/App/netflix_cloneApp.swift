//
//  netflix_cloneApp.swift
//  netflix-clone
//

import SwiftUI

@main
struct netflix_cloneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            rootContent
        }
    }

    // MARK: - Root Content

    @ViewBuilder
    private var rootContent: some View {
        Group {
            if router.onboardingComplete {
                mainTabView
            } else {
                OnboardingPage(
                    onComplete: { router.completeOnboarding() }, // ← lanjut guest tanpa login
                    onGoogleSignIn: {
                        await router.completeSignIn() // ← real Google sign-in
                    }
                )
            }
        }
        .task { router.restoreSessionIfNeeded() } // ← restore login + muat data backend pas app dibuka
    }

    // MARK: - Main Tab View

    private var mainTabView: some View {
        ZStack(alignment: .bottom) {
            tabContent
                .toolbar(.hidden, for: .tabBar)

            NavigationBar(selection: Binding( // ← custom binding: tiap tab disentuh, tab tujuan balik ke root
                get: { router.selectedTab },
                set: { newTab in router.selectTab(newTab) }
            )) // ← floating pill bar
        }
        .background(Color.Semantic.background.ignoresSafeArea())
        .sheet(isPresented: $router.showSignInSheet) { // ← modal sign-in (fitur ber-lock)
            AuthSheetView(onGoogleSignIn: { await router.completeSignIn() })
        }
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
            HomePage(
                viewModel: router.homeViewModel,
                continueWatching: router.continueWatching, // ← rail Lanjutkan Tonton real
                onTitleTap: { item in
                    router.selectedMediaItem = item
                    router.navigateToTitleDetail(from: .home)
                },
                onMyListTap: { item in
                    router.requireAuth {
                        router.selectedMediaItem = item
                        Task { await router.toggleHeroMyList() } // ← save/unsave
                    }
                },
                isInMyList: { item in
                    router.isInMyList(mediaType: item.mediaType.rawValue, mediaId: item.id)
                },
                isSavingMyList: { item in
                    router.isSavingMyList(mediaType: item.mediaType.rawValue, mediaId: item.id)
                }
            )
            .navigationDestination(for: NavigationRoute.self) { route in
                switch route {
                case .titleDetail:
                    TitleDetailPage(
                        mediaType: router.selectedMediaItem?.mediaType.rawValue ?? "movie",
                        mediaId: router.selectedMediaItem?.id ?? 0,
                        isInMyList: {
                            router.isInMyList(
                                mediaType: router.selectedMediaItem?.mediaType.rawValue ?? "movie",
                                mediaId: router.selectedMediaItem?.id ?? 0
                            )
                        },
                        isSavingMyList: {
                            router.isSavingMyList(
                                mediaType: router.selectedMediaItem?.mediaType.rawValue ?? "movie",
                                mediaId: router.selectedMediaItem?.id ?? 0
                            )
                        },
                        onMyListTap: {
                            router.requireAuth { Task { await router.toggleHeroMyList() } }
                        },
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
                        demoIndex: 0,
                        onStartPlaying: { Task { await router.logWatchHistory() } }, // ← riwayat
                        onProgressSave: { position, duration in
                            Task { await router.saveProgress(position: position, duration: duration) } // ← continue watching
                        }
                    )
                case .myList:
                    MyListPage(
                        items: router.mylistItems,
                        onTitleTap: { router.openMyListDetail($0) },
                        onRemove: { item in Task { await router.removeFromMyList(item) } },
                        onRefresh: { await router.loadNetflixSaya() }
                    )
                }
            }
        }
    }

    // MARK: - Klip Tab

    private var klipTab: some View {
        NavigationStack(path: $router.klipPath) {
            KlipPage(
                onPlayTap: { klip in
                    router.selectedMediaItem = klip.mediaItem
                    router.navigateToVideoPlayer(from: .klip) // ← play
                },
                onInfoTap: { klip in
                    router.selectedMediaItem = klip.mediaItem
                    router.navigateToTitleDetail(from: .klip) // ← info ke detail
                },
                onMyListTap: { klip in
                    router.requireAuth {
                        router.selectedMediaItem = klip.mediaItem
                        Task { await router.toggleHeroMyList() } // ← save/unsave
                    }
                },
                isInMyList: { klip in
                    router.isInMyList(mediaType: klip.mediaType, mediaId: klip.mediaId)
                },
                isSavingMyList: { klip in
                    router.isSavingMyList(mediaType: klip.mediaType, mediaId: klip.mediaId)
                }
            )
            .navigationDestination(for: NavigationRoute.self) { route in
                switch route {
                case .titleDetail:
                    TitleDetailPage(
                        mediaType: router.selectedMediaItem?.mediaType.rawValue ?? "movie",
                        mediaId: router.selectedMediaItem?.id ?? 0,
                        isInMyList: {
                            router.isInMyList(
                                mediaType: router.selectedMediaItem?.mediaType.rawValue ?? "movie",
                                mediaId: router.selectedMediaItem?.id ?? 0
                            )
                        },
                        isSavingMyList: {
                            router.isSavingMyList(
                                mediaType: router.selectedMediaItem?.mediaType.rawValue ?? "movie",
                                mediaId: router.selectedMediaItem?.id ?? 0
                            )
                        },
                        onMyListTap: {
                            router.requireAuth { Task { await router.toggleHeroMyList() } }
                        },
                        onPlayTap: { router.navigateToVideoPlayer(from: .klip) }
                    )
                case .videoPlayer:
                    VideoPlayerPage(
                        seriesTitle: router.selectedMediaItem?.title ?? "Demo Video",
                        episodeLabel: "Big Buck Bunny",
                        demoIndex: 0,
                        onStartPlaying: { Task { await router.logWatchHistory() } },
                        onProgressSave: { position, duration in
                            Task { await router.saveProgress(position: position, duration: duration) }
                        }
                    )
                case .myList:
                    MyListPage(
                        items: router.mylistItems,
                        onTitleTap: { router.openMyListDetail($0) },
                        onRemove: { item in Task { await router.removeFromMyList(item) } },
                        onRefresh: { await router.loadNetflixSaya() }
                    )
                }
            }
        }
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
                        isInMyList: {
                            router.isInMyList(
                                mediaType: router.selectedMediaItem?.mediaType.rawValue ?? "movie",
                                mediaId: router.selectedMediaItem?.id ?? 0
                            )
                        },
                        isSavingMyList: {
                            router.isSavingMyList(
                                mediaType: router.selectedMediaItem?.mediaType.rawValue ?? "movie",
                                mediaId: router.selectedMediaItem?.id ?? 0
                            )
                        },
                        onMyListTap: {
                            router.requireAuth { Task { await router.toggleHeroMyList() } }
                        },
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
                        onCloseTap: { router.popToRoot(from: .search) },
                        onStartPlaying: { Task { await router.logWatchHistory() } },
                        onProgressSave: { position, duration in
                            Task { await router.saveProgress(position: position, duration: duration) }
                        }
                    )
                case .myList:
                    MyListPage(
                        items: router.mylistItems,
                        onTitleTap: { router.openMyListDetail($0) },
                        onRemove: { item in Task { await router.removeFromMyList(item) } },
                        onRefresh: { await router.loadNetflixSaya() }
                    )
                }
            }
        }
    }

    // MARK: - Downloads Tab ("Netflix Saya")

    private var downloadsTab: some View {
        NavigationStack(path: $router.downloadsPath) {
            NetflixSayaPage(
                isSignedIn: router.isSignedIn,
                onSignInTap: { router.showSignInSheet = true }, // ← buka sheet sign-in
                profiles: router.profiles, // ← daftar profil
                selectedProfileId: router.selectedProfileId, // ← profil aktif
                history: router.historyEntries, // ← riwayat tontonan real
                mylist: router.mylistItems, // ← my list real
                onSelectProfile: { id in router.selectProfile(id) }, // ← ganti profil
                onSignOut: { router.signOut() }, // ← keluar
                onMyListTap: { item in router.openMyListDetail(item) }, // ← tap judul → detail
                onSeeAllMyList: { router.navigateToMyList() } // ← buka halaman My List penuh
            )
                .navigationDestination(for: NavigationRoute.self) { route in
                    switch route {
                    case .titleDetail:
                        TitleDetailPage(
                            mediaType: router.selectedMediaItem?.mediaType.rawValue ?? "movie",
                            mediaId: router.selectedMediaItem?.id ?? 0,
                            isInMyList: {
                                router.isInMyList(
                                    mediaType: router.selectedMediaItem?.mediaType.rawValue ?? "movie",
                                    mediaId: router.selectedMediaItem?.id ?? 0
                                )
                            },
                            isSavingMyList: {
                                router.isSavingMyList(
                                    mediaType: router.selectedMediaItem?.mediaType.rawValue ?? "movie",
                                    mediaId: router.selectedMediaItem?.id ?? 0
                                )
                            },
                            onMyListTap: {
                                router.requireAuth { Task { await router.toggleHeroMyList() } }
                            }
                        )
                    case .videoPlayer:
                        VideoPlayerPage(
                            seriesTitle: router.selectedMediaItem?.title ?? "Demo Video",
                            episodeLabel: "Big Buck Bunny",
                            demoIndex: 0,
                            onStartPlaying: { Task { await router.logWatchHistory() } },
                            onProgressSave: { position, duration in
                                Task { await router.saveProgress(position: position, duration: duration) }
                            }
                        )
                    case .myList:
                        MyListPage(
                            items: router.mylistItems,
                            onTitleTap: { router.openMyListDetail($0) },
                            onRemove: { item in Task { await router.removeFromMyList(item) } },
                            onRefresh: { await router.loadNetflixSaya() }
                        )
                    }
                }
        }
    }
}


