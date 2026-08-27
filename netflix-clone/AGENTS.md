# Agent Instructions

## Design System — READ FIRST

Before writing or modifying any UI code, read [`DesignSystem/README.md`](DesignSystem/README.md). It is the complete reference for:

- Color tokens (`Color.Primary.*`, `Color.Neutral.*`, `Color.Semantic.*`) — never hardcode colors
- Typography (`.Typography.<Weight>.<Role>` only; there is no `Regular` weight)
- Icon accessors (`Image.Icon.*`, `Image.Brand.*`, `Image.UserVariant.*`) — never `Image("literal")` outside `Icons.swift`, never SF Symbols in components
- Component APIs, metrics, and behavior for all groups: **Core**, **ButtonAndTabs**, **InputFieldAndSearch**, **NavigationAndMenus**, **VideoPlayer**, **TitleCards**
- Code conventions (MARK sections, private `Metrics` struct/enum, token pattern)
- Known issues/past fixes and the build verification command

Rules of thumb:
- New tokens go into `Assets.xcassets` + exposed via `DesignSystem/{Colors,Typography,Icons}.swift`.
- New components go into `DesignSystem/Components/<Group>/<Tier>/Molecules/<Name>.swift` and must be added to the gallery in `ContentView.swift`.
- **Generic type gotcha:** static stored properties are not allowed inside extensions of generic types. Use a top-level private enum instead (e.g. `ThumbnailMetrics`).
- Verify with:
  ```bash
  xcodebuild -project netflix-clone.xcodeproj -scheme netflix-clone -destination 'platform=iOS Simulator,name=iPhone 17' build
  ```

## Architecture — MVVM

```
├── App/                    # App entry point
├── Core/                   # Shared utilities (network, extensions)
├── Data/
│   ├── Dummy/              # JSON dummy files for development
│   └── Mappers/            # DTO ↔ Domain Model mapping
├── Domain/
│   └── Models/             # Pure data models (Codable, Identifiable)
├── Features/
│   ├── ViewModels/         # @Observable ViewModels (one per page)
│   ├── Pages/              # Screen-level views (composed from DesignSystem components)
│   └── Navigation/         # AppRouter — central navigation state
├── DesignSystem/           # Tokens + Components (atomic design)
└── ContentView.swift       # Component gallery
```

**Rules:**
- **Models** live in `Domain/Models/`. They are plain structs, no SwiftUI imports.
- **DTOs** (Data Transfer Objects) live in `Data/Mappers/` alongside their mapper. They match JSON structure with `CodingKeys`.
- **Mappers** convert DTO → Domain Model. When API changes, only mapper logic updates.
- **Never consume JSON directly in Views.** Always: JSON → DTO → Mapper → Domain Model → ViewModel → View.
- **Dummy data** lives in `Data/Dummy/` as JSON files. Load via `Mapper.loadDummy()` for previews/development.
- **Style comments:** every metric, color, font, spacing, padding should have `// ←` comment explaining what it controls. Example:
  ```swift
  .font(.Typography.Medium.label3)           // ← ubah ukuran/weight font
  .foregroundStyle(Color.Semantic.textPrimary) // ← ubah warna teks
  .frame(height: 480)                          // ← ubah tinggi hero
  .padding(.horizontal, 16)                    // ← ubah inset horizontal
  ```

**Rules (continued):**
- **ViewModels** live in `Features/ViewModels/`. One `@Observable` class per page. Load dummy data in `init()`.
- **Pages** live in `Features/Pages/`. Composed from DesignSystem components only. Never import UIKit or use raw colors/fonts.
- **Navigation** is centralized in `Features/Navigation/AppRouter.swift`. Pages receive closures for navigation actions, never push directly.
- **Dummy data flow:** `Data/Dummy/*.json` → `Data/Mappers/*Mapper.swift` (DTO → Domain Model) → `ViewModel.loadDummy()` → `View`.
