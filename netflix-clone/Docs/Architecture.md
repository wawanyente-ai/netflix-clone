# Architecture Guide — Netflix Clone

Panduan arsitektur project ini untuk developer yang baru bergabung.

---

## Overview

```
App → Pages → ViewModels → Services → API
                  ↓
              Domain Models
                  ↑
              Mappers (DTO → Model)
                  ↓
              Data (JSON/API)
```

Flow data: `TMDB API → DTO → Mapper → Domain Model → ViewModel → View`

---

## Folder Structure

| Folder | Purpose | Contoh |
|---|---|---|
| `App/` | Entry point | `netflix_cloneApp.swift` |
| `Core/Network/` | API client, config | `APIClient.swift`, `APIConfig.swift` |
| `Data/DTOs/` | TMDB response structs | `MovieDTO.swift` |
| `Data/Mappers/` | DTO → Model conversion | `MediaItemMapper.swift` |
| `Data/Services/` | API methods | `TMDBService.swift` |
| `Domain/Models/` | Pure data models | `MediaItem.swift` |
| `Features/Navigation/` | Central nav state | `AppRouter.swift` |
| `Features/Pages/` | Screen views | `HomePage.swift` |
| `Features/ViewModels/` | State + logic | `HomeViewModel.swift` |
| `DesignSystem/` | UI tokens + components | `Colors.swift`, `AppButton.swift` |

---

## Key Files

### App Entry (`App/netflix_cloneApp.swift`)

```swift
@main
struct netflix_cloneApp: App {
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            if router.onboardingComplete {
                mainTabView  // ← Tab Bar
            } else {
                OnboardingPage { router.completeOnboarding() }
            }
        }
    }
}
```

### Navigation (`Features/Navigation/AppRouter.swift`)

```swift
@Observable
final class AppRouter {
    var onboardingComplete: Bool  // ← persisted via UserDefaults
    var selectedTab: NavigationBar.Tab
    var homePath = NavigationPath()
    var searchPath = NavigationPath()
    var selectedMediaItem: MediaItem?
}
```

### API Config (`Core/Network/APIConfig.swift`)

```swift
enum APIConfig {
    static let tmdbBaseURL = "https://api.themoviedb.org/3"
    static let accessToken = "YOUR_TOKEN_HERE" // ← ganti di sini
}
```

### TMDB Service (`Data/Services/TMDBService.swift`)

```swift
actor TMDBService {
    static let shared = TMDBService()

    func fetchTrending() async throws -> [MultiSearchResultDTO]
    func fetchPopularMovies() async throws -> [MovieDTO]
    func searchMulti(query: String) async throws -> [MultiSearchResultDTO]
    // ... semua endpoint
}
```

---

## Data Flow

### 1. API Call

```swift
// ViewModel
func loadData() async {
    let dtos = try await TMDBService.shared.fetchPopularMovies()
    movies = MediaItemMapper.fromMovies(dtos)
}
```

### 2. DTO (Data Transfer Object)

Matches TMDB JSON response:

```swift
struct MovieDTO: Codable {
    let id: Int
    let title: String
    let posterPath: String?  // ← optional karena TMDB kadang nil
    let voteAverage: Double
}
```

### 3. Mapper (DTO → Domain Model)

```swift
enum MediaItemMapper {
    static func fromMovie(_ dto: MovieDTO) -> MediaItem {
        MediaItem(
            id: dto.id,
            title: dto.title,
            posterPath: dto.posterPath,
            voteAverage: dto.voteAverage
        )
    }
}
```

### 4. Domain Model

Used by Views and ViewModels:

```swift
struct MediaItem: Identifiable {
    let id: Int
    let title: String
    let posterURL: URL?  // ← computed from posterPath
}
```

### 5. View

Consumes ViewModel:

```swift
struct HomePage: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        ForEach(viewModel.popularMovies) { item in
            PosterImage(url: item.posterURL)
        }
    }
}
```

---

## Design System

### Tokens (never hardcode)

| Type | Accessor Pattern | Example |
|---|---|---|
| Color | `Color.<Palette>.<Name>` | `Color.Primary.red` |
| Font | `Typography.<Weight>.<Role>` | `.Typography.Medium.label2` |
| Icon | `Image.<Namespace>.<Name>` | `Image.Icon.play` |

### Components

Built from atoms → molecules → organisms:

| Level | Components |
|---|---|
| Atoms | `TemplateIcon`, `PosterImage`, `ShimmerView`, `ContentBadge`, `TopTenBadge` |
| Molecules | `AppButton`, `VideoControlButton`, `NavigationBar`, `SearchBar`, `TitleCard` |
| Organisms | `ContentRow`, `TopSearchRow` |

---

## Common Patterns

### Pattern 1: Page with ViewModel

```swift
struct SomePage: View {
    @State private var viewModel = SomeViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ShimmerView()  // ← loading state
            } else {
                // ← content
            }
        }
        .refreshable { await viewModel.loadData() }
    }
}
```

### Pattern 2: Reusable Card with Badge

```swift
TitleCard(
    kind: .standard,
    badge: BadgeConfig(
        showTopTen: item.voteAverage >= 8.0,
        bottomBadges: BadgeHelper.generateBadges(for: item)
    ),
    hasImage: item.posterURL != nil
) {
    PosterImage(url: item.posterURL)
}
```

### Pattern 3: Navigation

```swift
// Parent
NavigationStack(path: $router.homePath) {
    HomePage(onTitleTap: { item in
        router.selectedMediaItem = item
        router.navigateToTitleDetail(from: .home)
    })
    .navigationDestination(for: NavigationRoute.self) { route in
        switch route {
        case .titleDetail: TitleDetailPage(...)
        case .videoPlayer: VideoPlayerPage(...)
        }
    }
}
```

---

## Debugging Tips

### Check API calls

```swift
// Add to APIClient.swift
print("Request: \(request.url!)")
print("Response: \(String(data: data, encoding: .utf8)!)")
```

### Check ViewModel state

```swift
// In any ViewModel
var description: String {
    "Movies: \(movies.count), Loading: \(isLoading), Error: \(errorMessage ?? "none")"
}
```

### Preview with dummy data

```swift
#Preview {
    HomePage()
}
```

### Build from command line

```bash
xcodebuild -project netflix-clone.xcodeproj \
  -scheme netflix-clone \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build
```
