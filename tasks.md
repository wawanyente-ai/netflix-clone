# Netflix Clone — Tasks & Progress

> Reference source of truth for AI agents. Update this file every time a phase completes or status changes.
> If work stops mid-phase, next agent resumes from the last `in_progress` phase.

## Project Status Overview

- **Platform:** iOS (SwiftUI) + Go backend + Firebase
- **Architecture:** Monorepo
- **iOS progress:** 7/7 pages implemented (Home, Search, Klip, TitleDetail, VideoPlayer, NetflixSaya, Onboarding+MyList). Home/Search/Detail real TMDB via backend proxy; Klip real data; Continue Watching rail + MyList wire; NetflixSaya history/mylist real; Google Sign-In di-wire (Apple placeholder).
- **UI Auth rules:** onboarding wajib → guest mode; fitur personal di-gate (docs/auth-gating.md)
- **Backend progress:** API Fase 1–8 selesai, **jalan lokal** (bukan cloud) dengan service account `netflix-clone-db400`
- **CI/CD:** GitHub Actions ditambahkan — `backend.yml` (build/vet/test + docker), `ios.yml` (build sim + unit test, pakai `GoogleService-Info.ci.plist` stub), `deploy.yml` (Cloud Run, aktif saat secrets `GCP_PROJECT_ID`/`GCP_SA_KEY`/`TMDB_TOKEN` di-set)

---

## Tech Stack (Backend)

| Layer | Choice | Why |
|---|---|---|
| API server | Go + chi router | Fast, simple, portfolio value |
| Auth | Firebase Auth (Google/Apple) | Free unbounded, no OAuth boilerplate |
| Database | Firestore (NoSQL) | Free tier 50k reads/writes/hari |
| Push notif | FCM | Free unbounded |
| Deploy | Cloud Run (asia-southeast2) | Free 2M req/bln, serverless |
| Video | HLS test streams + Google sample CDN | Real adaptive streaming, open license |
| TMDB | Proxied server-side | Token must NOT be in iOS client |

**Note:** Cloud Run needs billing account but stays $0 under free tier. Fallback without credit card: Railway/Fly.io free tier, same Go code.

---

## Architecture

```
┌─────────────────┐
│  iOS App        │
└────────┬────────┘
         │ Firebase ID Token (JWT)
┌────────▼────────┐
│  Go API         │  ← Cloud Run
└────┬────────┬───┘
     │        │
┌────▼───┐ ┌──▼────────┐ ┌────────────┐
│Firestore│ │ TMDB proxy │ │ FCM (notif)│
└─────────┘ └───────────┘ └────────────┘
```

---

## Monorepo Layout

```
netflix-clone/
├── netflix-clone/              # iOS app (existing)
├── backend/                    # Go API
│   ├── cmd/server/main.go
│   ├── internal/
│   │   ├── config/
│   │   ├── auth/
│   │   ├── middleware/
│   │   ├── handlers/
│   │   ├── repository/
│   │   ├── models/
│   │   ├── service/
│   │   └── tmdb/
│   ├── go.mod
│   ├── Dockerfile
│   └── .env.example
├── firebase/
│   ├── firestore.rules
│   ├── firestore.indexes.json
│   └── firebase.json
└── docs/backend.md             # API docs
```

---

## Firestore Data Model

```
users/{uid}
├── email, displayName, createdAt, plan
├── devices/              # FCM tokens
│   └── {deviceToken}: {platform, updatedAt}
└── profiles/
    └── {profileId}
        ├── name, avatarColor, isKid, createdAt
        ├── mylist/{mediaId}
        │   └── {addedAt, mediaType, title, posterPath}
        ├── progress/{mediaId}
        │   └── {position, duration, updatedAt, title, posterPath}
        └── history/{ts}
            └── {mediaId, mediaType, title, watchedAt, completed}

content/videos/{videoId}
└── {title, description, posterUrl, streamUrl, duration, quality[], categories[]}
```

**Rule:** semua doc user wajib punya `ownerId == auth.uid`. Firestore rules + Go double guard.

---

## API Endpoints

**Auth:**
```
POST /v1/auth/signin          # verify Firebase ID token → user + profiles
```

**Profiles:**
```
GET    /v1/profiles
POST   /v1/profiles
PATCH  /v1/profiles/{id}
DELETE /v1/profiles/{id}
```

**My List:**
```
GET    /v1/profiles/{id}/mylist
POST   /v1/profiles/{id}/mylist/{mediaType}/{mediaId}
DELETE /v1/profiles/{id}/mylist/{mediaType}/{mediaId}
PUT    /v1/profiles/{id}/mylist/{mediaType}/{mediaId}   # toggle
```

**Continue Watching:**
```
GET    /v1/profiles/{id}/progress
PUT    /v1/profiles/{id}/progress/{mediaType}/{mediaId}
DELETE /v1/profiles/{id}/progress/{mediaType}/{mediaId}  # mark complete
```

**Watch History:**
```
GET  /v1/profiles/{id}/history?limit=&cursor=
POST /v1/profiles/{id}/history
```

**Notifications:**
```
POST   /v1/notifications/device/register     # upsert FCM token
GET    /v1/notifications
PATCH  /v1/notifications/{id}/read
```
Trigger: Cloud Scheduler job → cek TMDB episode baru dari mylist → kirim FCM.

**TMDB Proxy:**
```
GET /v1/content/trending?time_window=week
GET /v1/content/{movie|tv}/{id}
GET /v1/content/search?q=
GET /v1/content/genres
GET /v1/content/discover?genre=&sort=
```

**Videos (streaming):**
```
GET /v1/videos
GET /v1/videos/{id}
```

---

## Roadmap

Status: `done` | `in_progress` | `pending`

### Fase 1 — Foundations
- [x] Simpan plan ke tasks.md
- [x] `go mod init`, chi router, middleware (auth/logging/recovery), `/healthz`
- [x] Firebase admin init, env config, Dockerfile, Makefile, firestore.rules
- [x] Unit test middleware auth (5 cases) + health handler
- [x] Restruktur: `internal/firebase` wrapper expose Auth + Firestore (ganti `internal/auth`)
- [ ] DEPLOY (butuh akses GCP user): `make deploy PROJECT_ID=...` + push firestore.rules
Status: **done** (deploy menunggu kredensial user)

### Fase 2 — Auth
- [x] `POST /v1/auth/signin` — middleware verify token, inject claims ke context
- [x] `internal/firebase` wrapper, UserRepo, UserService `GetOrCreateUser` (idempotent)
- [x] Test: create-first / idempotent / email-prefix fallback
Status: **done**

### Fase 3 — Profiles
- [x] ProfileRepo (list/count/get/create/update/delete)
- [x] ProfileService (max 5, valid avatar, name length) + 5 unit test
- [x] Handler GET/POST/PATCH/DELETE `/v1/profiles`
- [x] SignIn response include profiles
Status: **done**

### Fase 4 — My List + Continue Watching
- [x] Model WatchlistItem + WatchProgress (+ MediaKey komposit `mediaType:mediaId`)
- [x] WatchlistRepo + ProgressRepo
- [x] Handler GET/POST/DELETE/PUT `/v1/profiles/{id}/mylist/...`
- [x] Handler GET/PUT/DELETE `/v1/profiles/{id}/progress/...`
- [x] Ownership check via helper `parseMediaParams` (403 untuk profile orang lain)
- [x] Test: save idempotent, toggle, mediaType valid, movie/tv same ID coexist
Status: **done**

### Fase 5 — Watch History + Home Rail
- [x] HistoryEntry model + HistoryRepo pagination cursor (watchedAt + docID tie-break)
- [x] Handler GET/POST `/v1/profiles/{id}/history` + base64 cursor codec
- [x] Test: invalid mediaType/ID, timestamp set, limit clamp
Status: **done**

### Fase 6 — Notifications (FCM)
- [x] Model Device + AppNotification
- [x] DeviceRepo + NotificationRepo
- [x] Handler register/unregister/list/mark-read `/v1/notifications/...`
- [x] Messaging client plumb (firebase.App.Messaging) + SendPush
- [x] Test: register valid/invalid, send w/o device, multi-token deliver, mark-read
- [ ] Cron job (Cloud Scheduler) episode checker — menunggu TMDB proxy (Fase 7)
Status: **done** (cron di Fase 7)

### Fase 7 — TMDB Proxy + Streaming
- [x] `internal/tmdb` client (Fetch raw JSON, StatusError, ErrNotConfigured)
- [x] Content proxy routes `/v1/content/...` — trending, search, genres, list, data (detail/videos/recommendations/season), discover
- [x] Video catalog: Video model + VideoRepo + handler `/v1/videos` + `cmd/seed`
- [x] Cron `cmd/notifier` + `internal/notify`: scan mylist TV → TMDB last_episode_to_air → FCM + tracker
Status: **done**
- [ ] DEPLOY pending kredensial user: seed catalog, deploy cron service + Cloud Scheduler, tmdb token env

### Fase 4 — My List + Continue Watching
- [ ] My List CRUD API
- [ ] Progress (continue watching) API
- [ ] iOS: MyListPage baru + hook tombol MyList di Home/Klip/detail
Status: pending

### Fase 5 — Watch History + Home Rail
- [ ] History API (paginated)
- [ ] iOS: riwayat section di NetflixSayaPage jadi real
Status: pending

### Fase 6 — Notifications (FCM)
- [ ] Device register endpoint + Cloud Scheduler job
- [ ] iOS: request push permission, handle open URL
Status: pending

### Fase 7 — TMDB Proxy + Streaming
- [ ] Pindahin TMDB token dari iOS APIConfig.swift ke env Go
- [ ] iOS ganti networking ke backend
- [ ] Video catalog API + HLS stream ke player
Status: pending

### Fase 8 — iOS Integrasi (real sign-in + proxy di-wire)
- [x] **Backend jalan lokal**: `backend/.env` (project `netflix-clone-db400`, service account, TMDB token), `make seed` sukses, smoke test semua endpoint
- [x] Dev bypass fix: `ALLOW_UNAUTHENTICATED_DEV=true` → synthetic token `dev-user`/`dev@local` (login status di `UserDefaults[isSignedIn]`)
- [x] **Auth gating rules** (`docs/auth-gating.md`): onboarding wajib, Home/Search/Klip/detail/player guest-OK; My List, Download, Netflix Saya, Continue Watching, History butuh login
- [x] AppRouter: `requireAuth`/`completeSignIn`/`signOut` + sheet `AuthSheetView`; NetflixSaya guest prompt; Home/Klip/Detail download di-gate
- [x] **Real sign-in (Google)**: Firebase iOS SDK (SPM) + GoogleSignIn pakai `GoogleSignIn-iOS`, bundle id `ozi.netflix-clone`, `GoogleService-Info.plist` di target + URL scheme `REVERSED_CLIENT_ID`
- [x] `completeSignIn` → `AuthService.signInWithGoogle()` → Firebase ID token → `BackendConfig.idToken` → `POST /v1/auth/signin` → simpan user + profiles
- [x] iOS `BackendClient` (URLSession + Firebase ID token header) — sudah aktif
- [x] **iOS ganti `APIConfig.swift` TMDB token → proxy `/v1/content/...`**: `TMDBService` di-routing via `BackendClient`; hardcoded token `APIConfig.accessToken` DIHAPUS (security)
- [x] VideoPlayer → `GET /v1/videos` catalog + HLS mux stream (loadCatalog)
- [x] **Continue Watching**: `onProgressSave` di-wire ke `saveProgress` (3x VideoPlayerPage), rail "Lanjutkan Tonton" di Home (TitleCard `.continueWatching`)
- [x] **MyListPage** baru + hook dari NetflixSaya (Lihat Semua) + refresh setelah toggle
- [x] **NetflixSayaPage** → my list + progress real (download tetap placeholder)
- [x] **KlipPage** → trending real via proxy (bukan dummy)
- [ ] Sign in with Apple (belum; user prioritas Google)
- [ ] Push notification handling iOS
Describe: progress test `550 Fight Club` seeded di profil Ahmad (untuk demo Continue Watching + My List)
Status: **done** (deploy cloud & push notif pending)

---

## iOS Issues Konteks (dari audit sebelumnya)

- TMDB token hardcoded di `netflix-clone/Core/Network/APIConfig.swift` — harus pindah ke backend
- KlipPage pakai dummy data, action buttons kosong
- NetflixSayaPage semua placeholder
- Onboarding auth fake (Google/Apple icon stand-in)
- QualityBadge / RatingBadge / continueWatching / category sheet belum dipakai di halaman
- `TitleCard` kebab dots, `TopTenBadge`, `ContentBadge` sudah tersedia di DesignSystem

---

## Build Verification Commands

**iOS:**
```bash
cd /Users/tpcahmad5054/Documents/labs/netflix-clone
xcodebuild -project netflix-clone.xcodeproj -scheme netflix-clone -destination 'platform=iOS Simulator,name=iPhone 17' build
```

**Backend:**
```bash
cd /Users/tpcahmad5054/Documents/labs/netflix-clone/backend
go build ./...
go vet ./...
go test ./...
```