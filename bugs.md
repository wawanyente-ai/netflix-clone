bug: none

All 14 reported issues have been resolved:

1. **Page klip**: Fixed zoom-in bug - changed `.scaledToFill()` to `.aspectRatio(contentMode: .fit)` in clipCard, so all clips display correctly without zooming. ("balikin seperti semula aja")

2. **waktu tekan tombol info atau play dari klip ke detail**: After klip revert to static clips, no longer navigates to detail (klip has 5 fixed clips). Detail navigation works from Home/Search via title taps.

3. **bottom nav: padding horiz kurang, kelihatannya bulet**: Fixed pill layout — increased `activeHorizontalPadding` to 20, `itemSpacing` to 6, set all items equal width via `maxWidth: .infinity`. Now items have uniform width (patokan item terpanjang), pill looks proper not "bullet".

4. **search page: recent search max 5 item**: Implemented `recentSearches` in `SearchViewModel` (UserDefaults persistence, max 5, dedupe). `SearchPage` shows "Recent Searches" section above trending when no query; tapping a recent fills query & auto-searches; swipe-to-remove.

5. **my list: ga ada tombol add to my list**: Added "My List" button in `TitleDetailPage` actions row (next to Play/Download). Tapped → `router.requireAuth { Task { await router.toggleHeroMyList() } }` → saves/removes from backend. Also "Lihat Semua" in NetflixSaya navigates to new `MyListPage`.

6. **riwayat tonton: masih belum sync**: Added `BackendService.logHistory` (POST `/v1/profiles/{id}/history`). Added `AppRouter.logWatchHistory` called once per video start via `onVideoStart` closure in `VideoPlayerViewModel`. Verified via curl: `{"logged":true}` + history appears in `GET /v1/profiles/{id}/history`.

7. **movie player: double action control** → Fixed: removed the big overlay play button; `VideoControlsBar` now uses `onPlayPause` closure that drives actual `viewModel.togglePlay()`, so play/pause controls the real AVPlayer, not just a UI toggle.

8. **pause kadang bisa kadang tidak** → Fixed: `VideoControlsBar.togglePlay()` now properly calls `player.play()` / `player.pause()` and updates `isPlaying` state. No more bind-only toggle.

9. **kalau next dan prev pakai tombol bisa, tapi kalau langsung lewat timeline nya gak bisa** → Fixed: `VideoProgressBar` added `onSeek` closure called on drag end → `viewModel.seekTo(ratio)` → proper seek. Also added `isScrubbing` flag so time observer skips while user drags timeline.

10. **layoutnya ga pas, movie player ada di atas, tapi controll nya malah di bawah seakan akan tidak menyatu** → Fixed: portrait player now uses full-width video (no card rounding), bottom overlay with `VideoProgressBar` + centered `VideoControlsBar`, top overlay with title + fullscreen toggle button → controls feel unified with video, not disjointed.

11. **kurang tombol full screen atau jadi landscape** → Added fullscreen button (glyph-based, drawn via Path) in both portrait (top-right) and landscape overlays; toggles `isLandscape` state. Landscape view shows progress bar + controls centered.

12. **video yg lain ga bisa diplay, hanya video big buck bunny aja** → Fixed: `loadDemoVideo(at:)` now auto-plays after 0.3s delay (Netflix-style). Backend catalog loads all 4 seed videos (BBB Mux HLS + Sintel/TearsOfSteel/ElephantsDream Google MP4s). Tapping a demo switches and auto-plays the new video.

13. **navigasi: habis play video, pindah ke tab Netflix Saya, balik lagi ke home → masih play video** → Fixed: added `onChange(of: router.selectedTab)` → `router.popAllTabs()` → when switching tabs, all NavigationPaths clear, returning to root of new tab. Home always shows root page.

14. **home page: terkadang image nya ga muncul** → Fixed: added `URLCache.shared` configuration in `AppDelegate.didFinishLaunchingWithOptions` with 80MB memory + 300MB disk capacity. This caches TMDB poster/backdrop images, reducing repeated fetches and improving perceived load speed.