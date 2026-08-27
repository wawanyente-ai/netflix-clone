# Swift & SwiftUI — Beginner Guide

Panduan lengkap untuk pemula yang baru belajar Swift dan SwiftUI, dengan referensi ke kode di project ini.

---

## Table of Contents

1. [Swift Basics](#swift-basics)
2. [SwiftUI Basics](#swiftui-basics)
3. [Project Patterns](#project-patterns)

---

## Swift Basics

### Variables & Constants

```swift
let name = "Netflix"         // ← constant (tidak bisa diubah)
var count = 0                // ← variable (bisa diubah)
count = 1                   // ← oke
// name = "Hulu"            // ← error! constant
```

**Di project ini:** ViewModels pakai `var` untuk state yang berubah, `let` untuk data yang tetap.

### Types

```swift
let title: String = "Stranger Things"   // ← text
let rating: Double = 8.5                // ← decimal
let year: Int = 2022                    // ← integer
let isActive: Bool = true               // ← boolean
```

**Di project ini:** `MediaItem` punya berbagai type:
```swift
struct MediaItem {
    let id: Int              // ← identifier
    let title: String        // ← judul
    let voteAverage: Double  // ← rating
    let releaseDate: String  // ← tanggal
}
```

### Optionals

Nilai yang MUNGKIN kosong:

```swift
let posterPath: String? = "/abc.jpg"   // ← ada nilainya
let posterPath: String? = nil          // ← kosong

//pakai optional binding:
if let path = posterPath {
    print(path) // ← aman, path ada
} else {
    print("kosong")
}

//pakai nil coalescing:
let display = posterPath ?? "placeholder" // ← fallback ke "placeholder"
```

**Di project ini:** Poster path dari TMDB sering `nil`:
```swift
var posterURL: URL? {
    ImageURLBuilder.posterURL(from: posterPath) // ← return URL? (bisa nil)
}
```

### Enums

Group related values:

```swift
enum Tab {
    case home
    case klip
    case search
    case downloads

    var icon: String {
        switch self {
        case .home: "house"
        case .klip: "film"
        case .search: "magnifyingglass"
        case .downloads: "arrow.down"
        }
    }
}
```

**Di project ini:** Banyak enum — `NavigationBar.Tab`, `VideoControlButton.Variant`, `BadgeConfig.BottomBadge.Style`.

### Closures

Anonymous functions:

```swift
// Basic closure
let greet = { print("Hello!") }
greet() // ← panggil

// With parameters
let add = { (a: Int, b: Int) -> Int in
    return a + b
}
let result = add(2, 3) // ← 5

// Trailing closure (SwiftUI pattern)
Button("Play") {
    print("tapped") // ← ini trailing closure
}
```

**Di project ini:** Semua action handlers pakai closures:
```swift
var onPlayTap: () -> Void = {}        // ← closure tanpa parameter
var onTitleTap: (MediaItem) -> Void   // ← closure dengan parameter
```

---

## SwiftUI Basics

### Views

Semua UI di SwiftUI adalah `View` — protocol yang bilang "ini bisa ditampilkan":

```swift
struct MyView: View {
    var body: some View {
        Text("Hello Netflix!")
    }
}
```

**Rule:** `body` harus return SATU view. Kalau butuh banyak, bungkus pakai `VStack`, `HStack`, atau `ZStack`.

### Stacks

Layout containers:

```swift
VStack {          // ← vertical stack
    Text("atas")
    Text("bawah")
}

HStack {          // ← horizontal stack
    Text("kiri")
    Text("kanan")
}

ZStack {          // ← overlay (stacked)
    Color.black   // ← background
    Text("di atas")
}
```

**Di project ini:** `HomePage` pakai VStack untuk layout, HStack untuk row items.

### Modifiers

ubah appearance/behavior view:

```swift
Text("Netflix")
    .font(.title)              // ← ubah font
    .foregroundColor(.red)     // ← ubah warna
    .padding()                 // ← tambah padding
    .frame(width: 200)         // ← set ukuran
    .background(.black)        // ← tambah background
    .cornerRadius(8)           // ← rounded corners
```

**Rule:** urutan modifier Penting! `.background()` SEBELUM `.cornerRadius()` berbeda hasilnya dengan sesudah.

### State

Data yang berubah → pakai `@State`:

```swift
struct Counter: View {
    @State private var count = 0  // ← mutable state

    var body: some View {
        Button("Count: \(count)") {
            count += 1  // ← otomatis update UI
        }
    }
}
```

**Di project ini:** ViewModels pakai `@Observable` (bukan `@State`), tapi prinsipnya sama.

### Bindings

Data yang di-share antara parent dan child:

```swift
struct Parent: View {
    @State private var name = ""

    var body: some View {
        Child(name: $name)  // ← kirim binding ($name)
    }
}

struct Child: View {
    @Binding var name: String  // ← terima binding

    var body: some View {
        TextField("Name", text: $name)  // ← edit langsung
    }
}
```

**Di project ini:** `SearchBar(text: $viewModel.query)` — binding ke query.

### Lists & ForEach

Tampilkan array data:

```swift
struct ListView: View {
    let items = ["Stranger Things", "Squid Game", "Wednesday"]

    var body: some View {
        ForEach(items, id: \.self) { item in
            Text(item)
        }
    }
}
```

**Di project ini:** `ForEach(viewModel.results) { item in ... }`

### Navigation

Stack-based navigation:

```swift
NavigationStack {
    List {
        NavigationLink("Detail") {
            DetailView()  ← push ke sini
        }
    }
    .navigationTitle("Home")
}
```

**Di project ini:** `AppRouter` manage navigation paths per tab.

### AsyncImage

Load gambar dari URL:

```swift
AsyncImage(url: imageURL) { phase in
    switch phase {
    case .success(let image):
        image.resizable().scaledToFill()
    case .failure:
        Text("Gagal load")
    case .empty:
        ProgressView()  // ← loading
    @unknown default:
        EmptyView()
    }
}
```

**Di project ini:** `PosterImage`, `BackdropImage`, `ProfileImage` — reusable wrapper.

---

## Project Patterns

### MVVM Pattern

```
View ←→ ViewModel ←→ Model/API
```

- **View**: tampilan UI (SwiftUI)
- **ViewModel**: state + logic (class `@Observable`)
- **Model**: data structures (struct `Codable`)

```swift
// Model
struct MediaItem: Identifiable {
    let id: Int
    let title: String
}

// ViewModel
@Observable
class HomeViewModel {
    var items: [MediaItem] = []

    func load() async {
        items = try await TMDBService.shared.fetchTrending()
    }
}

// View
struct HomePage: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        ForEach(viewModel.items) { item in
            Text(item.title)
        }
        .task { await viewModel.loadData() }
    }
}
```

### Async/Await

Modern Swift concurrency:

```swift
// Sequential
let movies = try await service.fetchMovies()
let tvShows = try await service.fetchTVShows()

// Parallel (faster!)
async let movies = service.fetchMovies()
async let tvShows = service.fetchTVShows()
let (m, t) = try await (movies, tvShows)
```

**Di project ini:** `HomeViewModel.loadData()` fetch semua data parallel.

### Design Tokens

Never hardcode colors/fonts — always use tokens:

```swift
// ❌ Bad
Text("Hello").foregroundColor(.white).font(.system(size: 16))

// ✅ Good
Text("Hello")
    .foregroundStyle(Color.Semantic.textPrimary)
    .font(.Typography.Medium.label2)
```

**Di project ini:** Semua tokens di `DesignSystem/Colors.swift`, `Typography.swift`, `Icons.swift`.
