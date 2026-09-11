# Netflix Clone — Design System

SwiftUI design system for the Netflix clone iOS app. Single source of truth for colors, typography, icons, and reusable components. **AI agents must follow this document when writing or modifying UI code.**

- Language: Swift 6 / SwiftUI
- Design tokens source: `Assets.xcassets`
- Fonts: custom `NetflixSans` family (registered in `Info.plist` via `UIAppFonts`)

---

## File Structure

```
DesignSystem/
├── Colors.swift
├── Typography.swift
├── Icons.swift
└── Components/
    ├── Core/
    │   └── Atoms/
    │       ├── ContentBadge.swift
    │       ├── PosterImage.swift
    │       ├── ShimmerView.swift
    │       └── TopTenBadge.swift
    ├── ButtonAndTabs/
    │   └── Molecules/
    │       ├── AppButton.swift
    │       ├── VideoControlButton.swift
    │       ├── VideoReactionButton.swift
    │       └── VideoTabButton.swift
    ├── InputFieldAndSearch/
    │   ├── Atoms/
    │   │   ├── ClearButton.swift
    │   │   └── TemplateIcon.swift
    │   └── Molecules/
    │       ├── InputField.swift
    │       └── SearchBar.swift
    ├── NavigationAndMenus/
    │   ├── Atoms/
    │   │   └── NavigationIcon.swift
    │   └── Molecules/
    │       └── NavigationBar.swift
    ├── TitleCards/
    │   ├── Molecules/
    │   │   └── TitleCard.swift
    │   └── Organisms/
    │       ├── ContentRow.swift
    │       └── TopSearchRow.swift
    └── VideoPlayer/
        ├── Atoms/
        │   ├── PlayerView.swift
        │   ├── QualityBadge.swift
        │   └── RatingBadge.swift
        └── Molecules/
            ├── BrightnessControl.swift
            ├── EpisodeSummaryRow.swift
            ├── SeasonSelectionDropdown.swift
            ├── TitleDetailsTabBar.swift
            ├── VideoAdvancedControlsBar.swift
            ├── VideoControlsBar.swift
            ├── VideoMetadataBar.swift
            ├── VideoPlayerTopBar.swift
            ├── VideoProgressBar.swift
            └── VideoThumbnail.swift
```

Convention: new components go to `Components/<Group>/<Tier>/Molecules/<Name>.swift`. No full-screen template compositions live under DesignSystem (screens live in `Features/Pages/`).

---

## Colors

Accessed via namespaced statics on `Color`. **Never** use raw values (`Color(hex:)`, `Color.red`, `.black`, etc.) in feature/component code.

### Palettes

| Accessor | Asset name | Hex |
|---|---|---|
| `Color.Primary.redLight1` | `RedLight1` | `#D22F26` |
| `Color.Primary.red` | `Red` | `#D22F26` |
| `Color.Primary.redDark1` | `RedDark1` | `#B1060F` |
| `Color.Neutral.black` | `Black` | `#000000` |
| `Color.Neutral.greyDark3` | `GreyDark3` | `#010101` |
| `Color.Neutral.greyDark2` | `GreyDark2` | `#191919` |
| `Color.Neutral.greyDark1` | `GreyDark1` | `#323232` |
| `Color.Neutral.grey` | `Grey` | `#737373` |
| `Color.Neutral.greyLight1` | `GreyLight1` | `#B2B2B2` |
| `Color.Neutral.greyLight2` | `GreyLight2` | `#CBCBCB` |
| `Color.Neutral.greyLight3` | `GreyLight3` | `#E6E6E6` |
| `Color.Neutral.white` | `White` | `#FFFFFF` |
| `Color.System.blue` | `SystemBlue` | `#4B6AEA` |
| `Color.System.red` | `SystemRed` | `#FE0202` |

> `RedLight1` currently holds the same value as `Red` — known duplicate.

### Semantic aliases

```swift
Color.Semantic.background          // Neutral.black
Color.Semantic.backgroundSecondary // Neutral.greyDark3
Color.Semantic.textPrimary         // Neutral.white
Color.Semantic.textSecondary       // Neutral.greyLight1
Color.Semantic.textTertiary        // Neutral.grey
Color.Semantic.brand               // Primary.red
Color.Semantic.brandPressed        // Primary.redDark1
Color.Semantic.error               // System.red
Color.Semantic.info                // System.blue
```

**Rule:** new tokens → colorsets in `Assets.xcassets/<Palette>/<Name>.colorset` → exposed through `Colors.swift`. Never reference a colorset by string anywhere else.

---

## Typography

Custom font family **NetflixSans** (Light/Medium/Bold), registered via `UIAppFonts`. Accessed as `.Typography.<Weight>.<Role>` on `Font`.

| Role | Size | Example |
|---|---|---|
| caption2 | 10 | `.Typography.Medium.caption2` |
| caption1 | 12 | `.Typography.Medium.caption1` |
| label3 | 14 | `.Typography.Medium.label3` |
| label2 | 16 | `.Typography.Medium.label2` |
| label1 | 18 | `.Typography.Medium.label1` |
| header1 | 32 | `.Typography.Bold.header1` |

**Rules:**
- No `.font(.system(...))`, no `Font.custom(...)` outside `Typography.swift`.
- There is **no** `Regular` weight enum.
- **Exception:** atomic badge components (`TopTenBadge`, `ContentBadge`, `RatingBadge`, `NavigationIcon`) may use `.font(.system(size:weight:))` for sizes smaller than caption2 (6–9pt). This is documented per-component — do not apply this exception to molecules or screens.

---

## Icons & Assets

All images live in `Assets.xcassets` and are exposed only through `Icons.swift`:

```swift
Image.Brand.logoLarge          // Brand/NetflixLogoLarge
Image.Brand.logoSingleBadge    // Brand/NetflixLogoSingleBadge
Image.Brand.logoSmall          // Brand/NetflixLogoSmall
Image.Brand.wordmark           // Brand/NetflixWordmark

Image.Icon.add                 // Icons/Add
Image.Icon.brightness, .close, .downloadAction, .downloadNavigation,
      .error, .home, .info, .like, .lockClosed, .lockOpen, .mirror,
      .pause, .play, .playStacked, .search, .share, .skipBackward,
      .skipForward, .smile, .speed, .subtitles, .user

Image.UserVariant.blue         // UserVariants/UserBlue
Image.UserVariant.pink         // UserVariants/UserPink
Image.UserVariant.turquoise    // UserVariants/UserTurquoise
Image.UserVariant.turquoise1   // UserVariants/UserTurquoise1
```

**Rules:**
- `Image("Literal")` is allowed **only** inside `Icons.swift`.
- Do **not** use SF Symbols (`Image(systemName:)`) in components.
- Template rendering pattern (used by most components, or via `TemplateIcon` atom):

```swift
image
    .resizable()
    .renderingMode(.template)
    .scaledToFit()
    .frame(width: size, height: size)
    .foregroundStyle(tint)
```

---

## Components

Full visual gallery lives in `ContentView.swift`. **Any new component or variant must be added there.**

---

### Core — Atoms

#### TopTenBadge

The "TOP 10" ribbon badge. Shape: trapezium — rusuk kiri lebih panjang (87.5% dari tinggi), rusuk kanan lebih pendek. Proporsional menyesuaikan frame. Uses `.font(.system(size:weight:))` for sizes below caption2.

```swift
TopTenBadge()                                        // full size (17×24)
TopTenBadge(scale: 0.53, cornerRadius: 4)            // mini (≈9×13) + clip ke card radius
```

| Parameter | Default | Comment |
|---|---|---|
| `scale` | 1.0 | Skala badge (0.53 = mini untuk top search cards) |
| `cornerRadius` | 0 | Radius clip (4 = sesuaikan dengan TitleCard radius) |

| Base Metric | Value | Comment |
|---|---|---|
| width | 17 | Lebar badge (× scale) |
| height | 24 | Tinggi badge (× scale) |
| left edge | 87.5% height | Rusuk kiri (trapezium slant), proporsional |
| "TOP" font | 6pt bold | × scale |
| number font | 10pt bold | × scale |
| bg color | `Color.Primary.red` | — |
| text color | `#FDFDFD` ≈ white | `Color(red: 253/255, ...)` |

#### ContentBadge

Solid-color label badge (e.g. "NEW EPISODES"). Uses `.font(.system(size:weight:))` for size below caption2.

```swift
ContentBadge(text: "New Episodes")
ContentBadge(text: "Leaving Soon", backgroundColor: Color.Neutral.greyDark1)
```

| Property | Default | Comment |
|---|---|---|
| bg | `Color.Primary.redDark1` | Override for other labels |
| font | 8pt bold, `.uppercased()` | `.system(size: 8, weight: .bold)` |
| text color | `Color.Neutral.white` | Override |
| hPad | 8 | — |
| vPad | 2 | — |
| cornerRadius | 2 | — |

---

### ButtonAndTabs — Molecules

#### AppButton

General-purpose button.

```swift
init(
    _ title: String,
    icon: Image? = nil,
    variant: Variant = .primary,
    size: Size = .large,
    action: @escaping () -> Void
)
```

| Variant | Bg | Fg | Disabled bg | Disabled fg |
|---|---|---|---|---|
| `.primary` | white | black | white | greyLight2 |
| `.primaryOnboarding` | red | white | redDark1 | grey |
| `.secondary` | greyDark2 | white | greyDark2 | grey |

| Size | Icon | Spacing | H-pad | V-pad | Font |
|---|---|---|---|---|---|
| `.large` | 18 | 8 | 8 | 8 | Medium.label3 |
| `.small` | 18 | 8 | 8 | 6 | Medium.label3 |
| `.primaryOnboarding` | 24 | 8 | 8 | 12 | Medium.label2 |

Behavior: full width except `.small`; corner radius 4; pressed opacity 0.8 + `easeOut(0.1s)`; disabled via `@Environment(\.isEnabled)`.

#### VideoControlButton

Player control button. All metrics centralized in private `Metrics` struct with 6 fields — change one place per variant.

```swift
init(variant: Variant, action: @escaping () -> Void)
```

**Enums:**

```swift
enum PlayStyle  { case thumbnailSmall, thumbnailLarge, videoLarge, videoSmall }
enum PauseStyle { case small, large }
enum SkipStyle  { case small, large }
```

| Variant | Icon | Container | Stroke W | Stroke Color | Bg | Icon Color |
|---|---|---|---|---|---|---|
| `.play(.thumbnailSmall)` | 20 | 32 | 3 | Neutral.white | clear | white |
| `.play(.thumbnailLarge)` | 32 | 54 | 1 | Primary.red | clear | white |
| `.play(.videoLarge)` | 42 | 42 | 0 | — | clear | white |
| `.play(.videoSmall)` | 28 | 28 | 0 | — | clear | white |
| `.pause(.small)` | 24 | 24 | 0 | — | clear | white |
| `.pause(.large)` | 42 | 42 | 0 | — | clear | white |
| `.mirror` | 18 | 28 | 0 | — | greyDark2 | white |
| `.close` | 18 | 28 | 0 | — | greyDark2 | white |
| `.skipBackward(.small)` | 22 | 22 | 0 | — | clear | white |
| `.skipBackward(.large)` | 40 | 40 | 0 | — | clear | white |
| `.skipForward(.small)` | 22 | 22 | 0 | — | clear | white |
| `.skipForward(.large)` | 40 | 40 | 0 | — | clear | white |

Stroke: `.overlay(Circle().strokeBorder(...))`, only when `strokeWidth > 0`. All `// ←` comments in code mark fields for customization.

#### VideoReactionButton

Vertical icon + label reaction button (e.g. Like).

```swift
init(
    title: String,
    icon: Image,
    isSelected: Bool = false,
    style: Style = .standard,
    action: @escaping () -> Void
)
```

| Style | Icon size | Spacing | Font |
|---|---|---|---|
| `.standard` | 32 | 8 | Light.label3 |
| `.prominent` | 32 | 8 | Medium.label3 |

`isSelected == true` → foreground `Color.Primary.red`; else `Color.Neutral.white`.

#### VideoTabButton

Text tab with underline indicator.

```swift
init(title: String, isSelected: Bool, action: @escaping () -> Void)
```

Selected: text white + red underline (height 4). Unselected: text greyDark1 + clear underline. Spacing 8, font Medium.label3.

---

### InputFieldAndSearch

#### Atoms

**TemplateIcon** — reusable icon wrapper for the standard rendering pattern (`resizable` + `.template` + tint + frame).

```swift
TemplateIcon(image: Image.Icon.search, size: 16, tint: Color.Semantic.textTertiary)
```

**ClearButton** — round "x" clear control (16pt: 8pt glyph + 4pt padding each side). Bg `Color.Neutral.grey`, icon `Image.Icon.close` tinted `greyDark2`.

#### Molecules

**InputField** — Netflix-style text input. States: default → focused (blue border) → filled → error (red border + error icon).

```swift
InputField(text: $email, placeholder: "Enter email")
InputField(text: $email, placeholder: "Enter email", errorMessage: "Invalid email")
```

Metrics: height 52, corner radius 2, hPad 12, vPad 16. Border color: `greyLight1` default → `System.blue` focused → `System.red` error. Font: Medium.label2.

**SearchBar** — Netflix-style search bar with centered placeholder when idle.

```swift
SearchBar(text: $query)
SearchBar(text: $query, placeholder: "Find a show...")
```

Metrics: height 28, corner radius 4, hPad 10, vPad 4, icon 16. Bg `greyDark2`. Idle = centered placeholder; active = left-aligned input + clear button. Font: Light.label3.

---

### NavigationAndMenus

#### Atom: NavigationIcon

Tab icon + micro-label pair, tinted by active state.

```swift
NavigationIcon(icon: Image.Icon.home, title: "Home", isActive: true)
```

Metrics: 75×36, icon 24, spacing 2, font Light.caption2 (10pt — closest catalog match to Figma's 8pt spec). Active tint: `greyLight2`; inactive: `grey`.

#### Molecule: NavigationBar

Bottom tab bar. 4 tabs: Home, Klip, Cari, Netflix Saya.

```swift
@State private var tab: NavigationBar.Tab = .home
NavigationBar(selection: $tab)
```

Tabs use `NavigationIcon` atoms. Bg `greyDark3`, vertical padding 4. Pressed feedback: opacity 0.8 + `easeOut(0.1)`.

---

### VideoPlayer

#### Atoms

**QualityBadge** — bordered badge for quality marks (Dolby Vision, HD). Pass real badge asset as `mark` (currently uses `Image.Icon.info` as stand-in). Metrics: default width 50, height 14, corner radius 2, border `greyDark1` 1pt.

```swift
QualityBadge(mark: Image.Icon.info, width: 50)
```

**RatingBadge** — content rating code (e.g. "TV-MA"). Bg `greyDark1`, font Medium.caption2, text `greyLight3`, padding 3, corner radius 2.

```swift
RatingBadge(rating: "TV-MA")
```

#### Molecules

**BrightnessControl** — vertical brightness slider (sun icon + fill bar).

```swift
BrightnessControl(level: $brightness, size: .large)
```

| Size | Icon | Bar W | Bar H | Spacing |
|---|---|---|---|---|
| `.large` | 24 | 6 | 124 | 8 |
| `.small` | 12 | 3 | 64 | 4 |

Bar: `grey` track, `white` fill from bottom. Shadow: `Neutral.black.opacity(0.4)` radius 24.

**VideoControlsBar** — transport row (skip back, play/pause, skip forward). All button sizes driven by `size` property.

```swift
VideoControlsBar(isPlaying: $isPlaying, size: .large, onSkipBack: {}, onSkipForward: {})
```

| Bar Size | Play | Pause | Skip |
|---|---|---|---|
| `.large` | `.videoLarge` | `.large` | `.large` |
| `.small` | `.videoSmall` | `.small` | `.small` |

Gap: large=156, small=87.36.

**VideoProgressBar** — scrubber with red fill + draggable thumb + time label.

```swift
VideoProgressBar(progress: $progress, size: .large, timeLabel: "7:40")
```

| Size | Thumb | Track H | Spacing |
|---|---|---|---|
| `.large` | 24 | 4 | 12 |
| `.small` | 16 | 4 | 12 |

Track: `grey` fill, `Primary.red` fill + thumb. Font: Light.label3.

**VideoAdvancedControlsBar** — secondary row: Speed, Lock, Audio & Subtitles.

```swift
VideoAdvancedControlsBar(speedLabel: "Speed (1x)", onSpeedTap: {}, onLockTap: {}, onSubtitlesTap: {})
```

Font: Medium.caption1, icon size 21 via `TemplateIcon`. Lock toggles `lockClosed`/`lockOpen` icon.

**VideoMetadataBar** — year, rating, duration, quality badges row.

```swift
VideoMetadataBar(year: "2022", rating: "TV-MA", duration: "5 Seasons")
```

Composed from `RatingBadge` + `QualityBadge`. Spacing 4, font Medium.caption1.

**VideoPlayerTopBar** — cast/mirror + title + close over player.

```swift
VideoPlayerTopBar(title: "S0:E0 \"Episode Name\"", onCastTap: {}, onCloseTap: {})
```

Uses `VideoControlButton(.mirror)` and `.close`. Title: Medium.label3, lineLimit 1.

**VideoThumbnail** — thumbnail with centered play button. Generic (`<Background: View>`).

```swift
VideoThumbnail(variant: .primary(label: "Trailer"), onCastTap: {}, onCloseTap: {}, onPlayTap: {}) {
    Color.Neutral.greyDark1
}
VideoThumbnail(variant: .secondary, onPlayTap: {}) {
    Color.Neutral.white.opacity(0.16)
}
```

| Variant | Play button | Corner radius |
|---|---|---|
| `.primary(label:)` | `.play(.videoLarge)` | 16 |
| `.secondary` | `.play(.thumbnailLarge)` | 4 |

Top controls (`.primary` only): `VideoControlButton(.mirror)` + `.close`, inset 8. Bottom label: Bold.label3, inset 15.

**EpisodeSummaryRow** — thumbnail + title/duration + synopsis. Generic (`<Thumbnail: View>`).

```swift
EpisodeSummaryRow(title: "1. Episode Name", duration: "37m", synopsis: "...", onPlayTap: {}) {
    Color.Neutral.greyDark1
}
```

Metrics: vSpacing 8, hSpacing 8, thumbnail 124×69. Uses `VideoThumbnail(.secondary)`. Title: Light.caption1 `greyLight3`, duration: Light.caption2 `grey`.

**SeasonSelectionDropdown** — "Season N" picker via native `Menu`. Chevron drawn as custom `Shape` (no catalog asset yet). Text: Light.caption1 `greyLight3`, spacing 6, chevron 16.

**TitleDetailsTabBar** — Episodes / Collection / More Like This / Trailers & More. Composed from `VideoTabButton`. Spacing 16.

---

### TitleCards

Cards used in Browse rows, Continue Watching rails, and Top Searches.

#### Molecule: TitleCard

Poster-style title card. Generic (`<Background: View>`).

```swift
TitleCard(kind: .standard, badge: .topTen) { Color.Neutral.greyDark1 }
TitleCard(kind: .continueWatching(progress: 0.3, episodeLabel: "S0:E00")) { Color.Neutral.greyDark1 }
TitleCard(kind: .topSearch, badge: .topTen) { Color.Neutral.greyDark1 }
```

| Kind | Size | Description |
|---|---|---|
| `.standard` | 106×152 | Poster only, corner radius 4 |
| `.continueWatching(progress:episodeLabel:)` | 106×188 | Poster + progress track + icon row (info + 3-dot kebab) |
| `.topSearch` | 96×54 | Horizontal thumbnail, no play button inside (play is in TopSearchRow) |

| Badge | Behavior |
|---|---|
| `.none` | No badge |
| `.topTen` | `TopTenBadge` at top-trailing. Full-size cards: scale 1.0. Top search: scale 0.53 + cornerRadius 4 |
| `.newEpisodes` | `ContentBadge("New Episodes")` at bottom |

Placeholder (no image): `Color.Neutral.grey.opacity(0.4)` + rotated `Image.Brand.logoSingleBadge` tinted `Color.Primary.red`.

Continue Watching footer: info icon (`Image.Icon.info`) + 3-dot kebab (`KebabDots` custom shape, vertical). Bg `greyDark2`, icon tint `greyLight1`.

#### Organism: TopSearchRow

Single row: TitleCard + title + play button. Generic (`<Thumbnail: View>`).

```swift
TopSearchRow(title: "The Sea Beast", hasTopTenBadge: true, onPlayTap: {}) {
    Color.Neutral.greyDark1
}
```

Layout: `HStack(spacing: 16)` — TitleCard(.topSearch) → Text(title, Bold.caption1, grey) → Spacer → VideoControlButton(.play(.thumbnailSmall)). Row height 54.

#### Organism: ContentRow

Horizontally-scrolling rail of TitleCards with a section header. Generic (`<Item: Identifiable, Background: View>`).

```swift
ContentRow(title: "Continue Watching", items: items, kind: { .continueWatching(...) }) { _ in
    Color.Neutral.greyDark1
}
```

Header: Bold.label1, `textPrimary`, hPad 16. Rail: `ScrollView(.horizontal)` with `HStack(spacing: 8)`, hPad 16. Bg `Semantic.background`.

---

## Code Conventions

1. **Token pattern:** `extension <SwiftUI type>` + nested `enum` namespaces of `static let`.
2. **File layout:** every file has `// MARK:` sections: Types → Properties → Initialization → Body, then private extensions for subviews/Metrics.
3. **Metrics:** per-state values in a private `Metrics` struct/enum, selected by `switch` — no magic numbers inline. All fields annotated with `// ←` comments.
4. **Button styling:** `Button` + private `ButtonStyle` or `.buttonStyle(.plain)`; pressed = opacity 0.8 + `easeOut(0.1)`.
5. **Disabled states:** `@Environment(\.isEnabled)`, never a parameter.
6. **Generic types:** static stored properties are **not allowed** inside extensions of generic types (Swift limitation). Use a top-level private enum instead (e.g. `ThumbnailMetrics`, `EpisodeMetrics`).
7. **Shared atoms:** `TemplateIcon` is used across InputFieldAndSearch and NavigationAndMenus. If a third group needs it, consider promoting to a shared location.
8. **Custom shapes for missing assets:** when no catalog asset exists for a glyph (kebab dots, chevron), draw a private `Shape` struct inline in the component file. Name it descriptively (`KebabDots`, `ChevronDownMark`). Mark with `// ← stand-in untuk asset yang belum ada di catalog` for future replacement.

---

## Known Issues & Past Fixes

- **Asset mismatches:** `Brand.logo`/`lettermarkBlue` referenced non-existent assets → replaced with `logoLarge`/`logoSingleBadge`/`logoSmall`. `UserVariant.blue` added for `UserBlue.imageset`.
- **SF Symbols:** `VideoControlButton` was migrated from SF Symbols to catalog assets.
- **Typography Regular:** does not exist — fixed usages to `Light`.
- **Generic type Metrics:** `VideoThumbnail` and `EpisodeSummaryRow` had `static stored properties` errors — Metrics moved to top-level private enums.
- **Xcode asset warnings:** "conflicting symbol" warnings from codegen are pre-existing and harmless.
- **`RedLight1`** duplicates `Red` value — known.
- **iPhone 16** simulator does not exist on this machine — build against **iPhone 17**.

---

## Build Verification

```bash
xcodebuild -project netflix-clone.xcodeproj \
  -scheme netflix-clone \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build
```

Success = `** BUILD SUCCEEDED **`. Always build after touching the DesignSystem.

---

## Component Gallery

`ContentView.swift` renders every component variant/state on a black background (`.preferredColorScheme(.dark)`):

- AppButton: all variants × sizes, icon versions, disabled states
- VideoControlButton: all Play/Pause/Skip/Utility variants with labels
- VideoReactionButton: standard/prominent, tap toggles `isSelected`
- VideoTabButton: tap switches active tab

**Rule:** any new component or variant must be added to the gallery.
