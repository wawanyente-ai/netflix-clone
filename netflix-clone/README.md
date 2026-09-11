# Netflix Clone — iOS App

A Netflix clone built with SwiftUI (MVVM + `@Observable`), with real TMDB content via a Go backend proxy, Firebase Google Sign-In, and adaptive HLS/MP4 streaming.

## Features

- **Home** — trending, popular, top rated rails + hero section + "Lanjutkan Tonton" (Continue Watching) rail
- **Klip** — vertical video-clip browser with curated clips
- **Cari (Search)** — real-time search with debounce, recent searches, trending suggestions
- **Title Detail** — movie/TV metadata, cast, seasons/episodes, recommendations, Play + My List actions
- **Video Player** — custom AVPlayer: play/pause, skip, scrubbing, fullscreen/landscape, Continue Watching progress save
- **Netflix Saya** — my list + watch history (real from backend) + downloads (placeholder)
- **MyListPage** — full my-list browsing, add/remove synced to backend
- **Onboarding + Auth** — 4-slide flow; real Google Sign-In via Firebase; guest mode gates personal features

## Guest vs Signed-In (Auth Gating)

- Guest can browse Home, Search, Klip, details, and play videos.
- Locked behind sign-in: My List, Downloads, Netflix Saya, Continue Watching, History.
- Rules documented in [`docs/auth-gating.md`](../docs/auth-gating.md).

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI (iOS 17+) |
| Architecture | MVVM, `@Observable` |
| Networking | async/await + URLSession (`BackendClient`) |
| Content API | Go backend proxy (`/v1/content/*`) — **no TMDB token in the app** |
| Backend data | Go API + Firestore (mylist, progress, history, profiles) |
| Auth | Firebase Auth (Google Sign-In) |
| Video | AVKit (AVPlayer) — HLS mux stream + Google sample MP4s |
| State | `AppRouter` (central navigation + session) |

## Project Structure

```
netflix-clone/
├── App/                    # App entry, AppDelegate (Firebase), AuthService
├── Core/Network/           # BackendClient, BackendConfig, APIConfig (image sizes)
├── Data/
│   ├── DTOs/               # Response models
│   ├── Dummy/              # JSON dummy data (previews)
│   ├── Mappers/            # DTO → Domain Model mapping
│   └── Services/           # BackendService, TMDBService, VideoService
├── Domain/Models/          # Pure data models
├── Features/
│   ├── Navigation/         # AppRouter + NavigationRoute
│   ├── Pages/              # Screen-level views
│   └── ViewModels/         # @Observable ViewModels
├── DesignSystem/           # Tokens + Components (see DesignSystem/README.md)
└── Resources/Fonts/        # NetflixSans font family
```

## Getting Started

### Prerequisites

- Xcode 15+
- iOS 17+ simulator (build target: **iPhone 17**)
- Go 1.22+ (backend)
- Running backend locally with a TMDB access token + Firebase service account (see [`backend/`](../backend))

### Setup

1. Clone the repo.
2. Start the backend (token lives server-side, never in the app):
   ```bash
   cd backend
   cp .env.example .env        # isi TMDB_ACCESS_TOKEN + FIREBASE_SERVICE_ACCOUNT_PATH
   make seed                   # seed video catalog ke Firestore
   make run                    # API di http://localhost:8080
   ```
3. Open `netflix-clone.xcodeproj`.
4. Add `GoogleService-Info.plist` (Firebase project `netflix-clone-db400`) to the `netflix-clone` target.
5. Build & Run (Cmd+R) on iPhone 17 simulator.
6. Optional: set `BackendBaseURL` in `Info.plist` to point the app at a deployed backend; defaults to `http://localhost:8080`.

### Dev bypass (no login)

Backend with `ALLOW_UNAUTHENTICATED_DEV=true` accepts requests without a Firebase token (synthetic `dev-user`). Production **must** keep this `false`.

## Videos

Streaming catalog served by the backend (`GET /v1/videos`) — seeded Blender open movies:
- Big Buck Bunny (HLS mux stream)
- Sintel
- Tears of Steel
- Elephants Dream

## Design System

See [`DesignSystem/README.md`](DesignSystem/README.md) for the complete reference:
- Color tokens, Typography, Icon accessors
- Component APIs and metrics
- Code conventions and past fixes

## Learning Resources

- [`Docs/SwiftAndSwiftUI.md`](Docs/SwiftAndSwiftUI.md) — Swift & SwiftUI basics
- [`Docs/Architecture.md`](Docs/Architecture.md) — MVVM architecture guide

## API Reference

All TMDB calls go through the backend proxy — the app only holds image URLs + proxy paths:

- `GET /v1/content/trending?time_window=week` — trending content
- `GET /v1/content/search?q=` — global search
- `GET /v1/content/{movie|tv}/{id}` — detail (+ videos/recommendations/seasons)
- `GET /v1/content/discover?genre=&sort=` — genre filtering
- `GET /v1/videos` — streaming catalog

Personal features use the Go backend:
- `POST /v1/auth/signin` — Firebase ID token → user + profiles
- `/v1/profiles/{id}/mylist` — save/remove/toggle
- `/v1/profiles/{id}/progress` — continue watching
- `/v1/profiles/{id}/history` — watch history

Full API docs: [`docs/backend.md`](../docs/backend.md).

## Attribution

This product uses the TMDB API but is not endorsed or certified by TMDB.