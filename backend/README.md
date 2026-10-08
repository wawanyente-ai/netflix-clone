# Backend — Netflix Clone

Go API untuk iOS app: auth Firebase, Firestore data (profiles, mylist, progress, history, notifikasi), proxy TMDB, katalog video streaming.

- Router: [chi](https://github.com/go-chi/chi)
- Full API reference: [`docs/backend.md`](../docs/backend.md)
- Deploy/CI: [`docs/deployment.md`](../docs/deployment.md)

## Requirements

- Go 1.26+ (lihat `go.mod`)
- Firebase project + service account JSON
- TMDB v4 access token (hanya server-side)

## Setup

```bash
cp .env.example .env
```

Isi `.env`:

| Var | Fungsi |
|---|---|
| `GCP_PROJECT_ID` | Project GCP/Firebase |
| `FIREBASE_SERVICE_ACCOUNT_PATH` | Path ke service account JSON (opsional; kosong = Application Default Credentials) |
| `TMDB_ACCESS_TOKEN` | Token TMDB — **tidak boleh bocor ke iOS** |
| `ALLOW_UNAUTHENTICATED_DEV` | `true` = request tanpa token diterima sebagai `dev-user`. **Wajib `false` di production** |
| `CORS_ALLOWED_ORIGINS` | Origins dipisah koma |
| `PORT` | Default `8080` |

`.env` dan `*adminsdk*.json` sudah gitignored — jangan pernah di-commit.

## Make Targets

| Target | Fungsi |
|---|---|
| `make run` | Jalankan API dengan env dari `.env` |
| `make run-cron` | Jalankan sekali job "episode baru" notifier |
| `make build` | Build `bin/server`, `bin/notifier`, `bin/seed` |
| `make seed` | Seed katalog video streaming ke Firestore |
| `make test` | `go test ./...` |
| `make vet` | `go vet ./...` |
| `make fmt` | `gofmt -w .` + cek sisa file belum format |
| `make docker-build` / `make docker-run` | Image lokal, port 8080 |
| `make deploy PROJECT_ID=... TMDB_TOKEN=...` | Deploy ke Cloud Run |
| `make deploy-cron PROJECT_ID=... TMDB_TOKEN=...` | Deploy service cron |
| `make clean` | Hapus `bin/` |

## Structure

```
backend/
├── cmd/
│   ├── server/          # Entry API (main.go + router.go)
│   ├── notifier/        # Cron "episode baru" → FCM
│   └── seed/            # Seed katalog video
├── internal/
│   ├── config/          # Baca env → Config
│   ├── firebase/        # Wrapper Firebase Admin (Auth + Firestore + Messaging)
│   ├── handlers/        # HTTP handlers + response helpers
│   ├── middleware/      # auth, cors, logging, recovery, verifier
│   ├── models/          # Struct domain (user, profile, history, dll)
│   ├── notify/          # Logic scan mylist TV → TMDB → FCM
│   ├── repository/      # Akses Firestore (satu file per aggregate)
│   ├── service/         # Business rules + unit test
│   └── tmdb/            # Client TMDB (raw JSON pass-through)
├── Dockerfile           # Multi-stage: golang-alpine → distroless
├── Makefile
└── go.mod / go.sum
```

Pola: `handler → service → repository`. Handler diuji lewat service; business rules ada di `service` (banyak unit test di sana).

## Health Check

```bash
make run
curl http://localhost:8080/healthz     # atau /v1/healthz
```

## Tests

```bash
make test     # go test ./...
make vet
make fmt
```

CI menjalankan build + vet + test + docker build di tiap push ke `backend/**` — lihat [`docs/deployment.md`](../docs/deployment.md).
