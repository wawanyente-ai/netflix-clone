# Netflix Clone — iOS App

A Netflix clone built with SwiftUI, featuring real TMDB API integration and demo video streaming.

## Features

- **Home** — trending, popular, top rated content rails with hero section
- **Klip** — vertical TikTok-like clip browser with poster images
- **Search** — real-time search with debounce, trending suggestions
- **Title Detail** — movie/TV metadata, cast, episodes, recommendations
- **Video Player** — custom AVPlayer with demo videos (Big Buck Bunny, Sintel, etc.)
- **Onboarding** — 4-slide onboarding flow with page indicators

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI (iOS 17+) |
| Architecture | MVVM |
| Networking | async/await + URLSession |
| API | TMDB API v3 |
| Video | AVKit (AVPlayer) |
| State | @Observable |

## Project Structure

```
netflix-clone/
├── App/                    # App entry point
├── Core/
│   └── Network/            # API client, endpoints, config
├── Data/
│   ├── DTOs/               # TMDB response models
│   ├── Dummy/              # JSON dummy data
│   ├── Mappers/            # DTO → Domain Model mapping
│   └── Services/           # TMDBService, VideoService
├── Domain/
│   └── Models/             # Pure data models
├── Features/
│   ├── Navigation/         # AppRouter (central navigation)
│   ├── Pages/              # Screen-level views
│   └── ViewModels/         # @Observable ViewModels
├── DesignSystem/           # Tokens + Components (atomic design)
├── Resources/Fonts/        # NetflixSans font family
└── Assets.xcassets/        # Colors, Icons, Brand assets
```

## Getting Started

### Prerequisites
- Xcode 15+
- iOS 17+ simulator or device
- TMDB API Access Token

### Setup

1. Clone the repo
2. Open `netflix-clone.xcodeproj`
3. Get your TMDB API token at [themoviedb.org/settings/api](https://www.themoviedb.org/settings/api)
4. Replace `YOUR_TMDB_ACCESS_TOKEN_HERE` in `Core/Network/APIConfig.swift`
5. Build & Run (Cmd+R) on iPhone 17 simulator

### Demo Videos

Built-in demo videos from Google's sample CDN (Blender Open Movies):
- Big Buck Bunny
- Sintel
- Tears of Steel
- Elephants Dream

## Design System

See [`DesignSystem/README.md`](DesignSystem/README.md) for the complete reference:
- Color tokens, Typography, Icon accessors
- Component APIs and metrics
- Code conventions and known issues

## Learning Resources

- [`Docs/SwiftAndSwiftUI.md`](Docs/SwiftAndSwiftUI.md) — Swift & SwiftUI basics
- [`Docs/Architecture.md`](Docs/Architecture.md) — MVVM architecture guide

## API Reference

TMDB API endpoints used:
- `/trending/all/week` — trending content
- `/movie/popular`, `/movie/top_rated` — movie rails
- `/tv/popular`, `/tv/top_rated` — TV rails
- `/movie/{id}`, `/tv/{id}` — detail pages
- `/search/multi` — global search
- `/discover/movie` — genre filtering

## Attribution

This product uses the TMDB API but is not endorsed or certified by TMDB.
