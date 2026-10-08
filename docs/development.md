# Development Guide — Netflix Clone

Commands, konvensi, dan alur kerja harian untuk monorepo ini.

## Prasyarat

| Component | Version |
|---|---|
| Xcode | 15+ (project dibuat dengan tools 26.x) |
| iOS Simulator | iPhone 17 (target build) |
| Go | 1.26 (lihat `backend/go.mod`) |
| Firebase CLI | hanya untuk deploy rules/indexes |

## Build & Test — iOS

```bash
# Build
xcodebuild -project netflix-clone.xcodeproj -scheme netflix-clone \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Success = `** BUILD SUCCEEDED **`.

Catatan: target test iOS (`netflix-cloneTests`) sudah dihapus karena tidak pernah berfungsi (mock minta mewarisi concrete actor yang invalid di Swift) dan CI tidak menjalankannya. Build verification iOS = compile, bukan unit test. Unit test aktif ada di **backend** (lihat bawah).

### Setup Lokal iOS

1. Taruh `GoogleService-Info.plist` (project Firebase kamu) di folder `netflix-clone/`. File ini gitignored; CI memakai stub `GoogleService-Info.ci.plist`.
2. Backend jalan dulu (`cd backend && make run`), default `http://localhost:8080`.
3. Ganti `BackendBaseURL` di `netflix-clone/Info.plist` kalau backend tidak di localhost.

## Build & Test — Backend

```bash
cd backend
make build     # bin/server, bin/notifier, bin/seed
make test      # go test ./...
make vet       # go vet ./...
make fmt       # gofmt -w . + cek formatting
make run       # API di :8080 (butuh .env)
make seed      # seed katalog video ke Firestore
```

Smoke test:

```bash
curl http://localhost:8080/healthz
curl -H "Authorization: Bearer <token>" http://localhost:8080/v1/profiles
```

Dev tanpa token: set `ALLOW_UNAUTHENTICATED_DEV=true` di `backend/.env` (user synthetic `dev-user`). **Jangan pernah di production.**

## Konvensi iOS

Detail lengkap ada di [`../netflix-clone/AGENTS.md`](../netflix-clone/AGENTS.md) dan [`../netflix-clone/DesignSystem/README.md`](../netflix-clone/DesignSystem/README.md). Ringkasan:

- **Arsitektur MVVM**: `JSON → DTO → Mapper → Domain Model → ViewModel → View`. View tidak pernah konsumsi JSON langsung.
- **Token desain, bukan literal**: warna `Color.Semantic.*`, font `.Typography.<Weight>.<Role>`, ikon `Image.Icon.*`. Dilarang hardcode warna/font/`Image("literal")` di component.
- **Component baru** → `DesignSystem/Components/<Group>/<Tier>/Molecules/<Name>.swift` + daftarkan ke gallery `ContentView.swift`.
- **Komentar style**: tiap metrik/warna/font dikasih `// ←` penjelasan.
- **Gotcha**: static stored property tidak boleh di extension generic type — pakai top-level private enum.

## Konvensi Backend

- Layer: `handler → service → repository`. Business rules di `service` (diuji unit test).
- Repository satu file per aggregate (`history_repo.go`, `watchlist_repo.go`, dst).
- Semua error response JSON: `{ "error": "human-readable message" }`.
- Sebelum commit: `make fmt && make vet && make test`.

## Struktur Test

| Lokasi | Framework | Cakupan |
|---|---|---|
| `backend/internal/handlers/*_test.go` | `go test` | health handler |
| `backend/internal/middleware/*_test.go` | `go test` | auth middleware (5 kasus) |
| `backend/internal/service/*_test.go` | `go test` | business rules (profile, history, mylist, progress, notif) |

## Status & Backlog

Progres per fase dan sisa pekerjaan tercatat di [`tasks.md`](tasks.md). Update file itu setiap kali satu fase selesai.
