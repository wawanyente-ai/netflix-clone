# Netflix Clone

Netflix clone: **iOS app (SwiftUI) + Go backend + Firebase**. Konten asli dari TMDB lewat proxy backend (token TMDB tidak pernah menyentuh iOS), auth Google via Firebase, streaming HLS/MP4.

## Features

- **Home** — hero, rails trending/popular/top rated, rail "Lanjutkan Tonton"
- **Klip** — browser klip video vertikal
- **Cari (Search)** — search real-time + debounce, recent searches, trending suggestions
- **Title Detail** — metadata, cast, musim/episode, rekomendasi, aksi Play + My List
- **Video Player** — AVPlayer custom: play/pause, skip, scrubbing, fullscreen/landscape, simpan progres
- **Netflix Saya** — my list, riwayat tonton (dari backend), profil
- **Onboarding + Auth** — 4 slide; Google Sign-In real via Firebase; mode guest untuk browsing

## Stack

| Layer | Teknologi |
|---|---|
| iOS | SwiftUI (iOS 17+), MVVM + `@Observable` |
| Networking iOS | async/await + URLSession (`BackendClient`) |
| Backend | Go 1.26 + chi + Firebase Admin |
| Data | Firestore (mylist, progress, history, profiles, notifikasi) |
| Content API | Go proxy `/v1/content/*` → TMDB (token server-side only) |
| Auth | Firebase Auth (Google Sign-In) |
| Video | AVKit (AVPlayer) — HLS mux stream + sample MP4 |
| Deploy | Cloud Run (asia-southeast2) via GitHub Actions |

## Monorepo Layout

```
netflix-clone/
├── netflix-clone/              # iOS app (SwiftUI)
│   ├── App/                    # Entry point, AppDelegate (Firebase), AuthService
│   ├── Core/Network/           # BackendClient, BackendConfig, APIConfig
│   ├── Data/                   # DTOs, Mappers, Repositories, Services, Persistence
│   ├── Domain/Models/          # Pure data models
│   ├── Features/               # Navigation, Pages, ViewModels
│   ├── DesignSystem/           # Tokens + components → DesignSystem/README.md
│   └── Docs/                   # Panduan arsitektur & Swift
├── backend/                    # Go API → backend/README.md
├── firebase/                   # firestore.rules, indexes, firebase.json
├── scripts/                    # Generator asset (colors, image assets)
├── docs/                       # Dokumentasi → docs/README.md
└── .github/workflows/          # CI/CD → docs/deployment.md
```

## Getting Started

### 1. Backend

```bash
cd backend
cp .env.example .env        # isi TMDB_ACCESS_TOKEN + FIREBASE_SERVICE_ACCOUNT_PATH
make seed                   # seed video catalog ke Firestore
make run                    # API di http://localhost:8080
```

Detail: [`backend/README.md`](backend/README.md).

### 2. iOS App

1. Buka `netflix-clone.xcodeproj`.
2. Taruh `GoogleService-Info.plist` (Firebase project kamu) di folder `netflix-clone/` — file ini gitignored, CI memakai stub `GoogleService-Info.ci.plist`.
3. Build & Run (Cmd+R) di simulator iPhone 17.
4. Backend default `http://localhost:8080` — ganti lewat key `BackendBaseURL` di `netflix-clone/Info.plist`.

Dev bypass (tanpa login): backend dengan `ALLOW_UNAUTHENTICATED_DEV=true` menerima request tanpa token (user `dev-user`). **Production wajib `false`.**

### 3. Verify

```bash
# Backend
cd backend && go build ./... && go vet ./... && go test ./...

# iOS
xcodebuild -project netflix-clone.xcodeproj -scheme netflix-clone \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

## Docs

| Doc | Isi |
|---|---|
| [`docs/README.md`](docs/README.md) | Index semua docs |
| [`docs/backend.md`](docs/backend.md) | Referensi API lengkap |
| [`docs/auth-gating.md`](docs/auth-gating.md) | Aturan akses guest vs signed-in |
| [`docs/caching.md`](docs/caching.md) | Strategi SWR caching + image cache iOS |
| [`docs/deployment.md`](docs/deployment.md) | CI/CD GitHub Actions + Cloud Run |
| [`docs/development.md`](docs/development.md) | Build, test, konvensi kerja |
| [`docs/tasks.md`](docs/tasks.md) | Backlog & progres per fase |
| [`netflix-clone/README.md`](netflix-clone/README.md) | Detail iOS app |
| [`backend/README.md`](backend/README.md) | Detail backend |
| [`netflix-clone/DesignSystem/README.md`](netflix-clone/DesignSystem/README.md) | Design system (wajib baca sebelum nulis UI) |

## Attribution

Product ini memakai TMDB API tapi tidak di-endorse atau disertifikasi oleh TMDB.
