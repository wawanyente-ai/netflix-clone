# Deployment & CI/CD — Netflix Clone

Semua otomasi ada di `.github/workflows/`. Tiga workflow, terpisah berdasarkan path filter supaya push iOS tidak memicu build backend, dan sebaliknya.

## Workflows

### `backend.yml` — Backend CI

| | |
|---|---|
| Trigger | push/PR ke `main` yang mengubah `backend/**` atau workflow-nya |
| Runner | `ubuntu-latest` |
| Steps | `go build ./...` → `go vet ./...` → `go test -race ./...` → `docker build backend/` |

### `ios.yml` — iOS CI

| | |
|---|---|
| Trigger | push/PR ke `main` yang mengubah `netflix-clone/**` atau `netflix-clone.xcodeproj/**` |
| Runner | `macos-15` |
| Steps | copy `GoogleService-Info.ci.plist` → `GoogleService-Info.plist` (stub, karena plist asli gitignored) → `xcodebuild build` untuk `generic/platform=iOS` tanpa signing |
| On failure | upload `xcresult` + build log sebagai artifact |

Catatan: CI hanya **build**, tidak menjalankan unit test.

### `deploy.yml` — Deploy ke Cloud Run

| | |
|---|---|
| Trigger | push ke `main` yang mengubah `backend/**`, atau `workflow_dispatch` manual |
| Runner | `ubuntu-latest` |
| Skip | job `skipped` jalan (sukses tanpa action) kalau secrets belum diset |

Urutan job `deploy`:

1. Auth ke GCP (`google-github-actions/auth` dengan `GCP_SA_KEY`)
2. Opsional: `go run ./cmd/seed` kalau input `seed_catalog` dicentang
3. `gcloud builds submit backend/` → image `gcr.io/$PROJECT/netflix-backend:latest`
4. `gcloud run deploy netflix-backend` — region `asia-southeast2`, `--allow-unauthenticated`
5. Blok cron worker + Cloud Scheduler masih dikomentari (butuh scheduler service account)

## Secrets yang Dibutuhkan

| Secret | Dipakai oleh | Isi |
|---|---|---|
| `GCP_PROJECT_ID` | `deploy.yml` | ID project GCP |
| `GCP_SA_KEY` | `deploy.yml` | JSON service account (full key, satu baris) |
| `TMDB_TOKEN` | `deploy.yml` | TMDB v4 access token |

Set di **GitHub → Settings → Secrets and variables → Actions**. Selama kosong, deploy di-skip dengan aman.

## Setup Cloud Run Manual (tanpa Actions)

```bash
cd backend
make deploy PROJECT_ID=<project> TMDB_TOKEN=<tmdb-v4-token>
```

Setelah deploy:

1. Upload rules: `firebase deploy --only firestore` (atau lewat console) pakai `firebase/firestore.rules` + `firestore.indexes.json`.
2. Seed katalog: `make seed` (butuh service account + project aktif).
3. Cron episode notifier (opsional):
   ```bash
   make deploy-cron PROJECT_ID=<project> TMDB_TOKEN=<token>
   ```
   lalu buat Cloud Scheduler HTTP GET mingguan ke URL service `netflix-backend-cron`.

## Konfigurasi Production

Env yang di-set oleh `deploy.yml` ke Cloud Run:

```
ENV=production
GCP_PROJECT_ID=<project>
TMDB_ACCESS_TOKEN=<token>
```

Checklist sebelum production:

- [ ] `ALLOW_UNAUTHENTICATED_DEV` **tidak** di-set (default `false` — fails closed)
- [ ] `firestore.rules` sudah ter-deploy
- [ ] `BackendBaseURL` di `netflix-clone/Info.plist` menunjuk ke URL Cloud Run
- [ ] TMDB token hanya hidup di server, tidak pernah di iOS

## Docker Image

```bash
cd backend
make docker-build
make docker-run     # port 8080
```

Multi-stage build (`golang:1.26-alpine` → `gcr.io/distroless/static-debian12`, nonroot).
