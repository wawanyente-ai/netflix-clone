# Backend API — Netflix Clone

Go + chi + Firebase (Auth, Firestore). Deploy: Cloud Run (asia-southeast2).

## Base URL

Production: `https://<service-name>-<hash>.a.run.app` (set after `make deploy`)
Local: `http://localhost:8080`

## Auth

Every request (except `/healthz`) needs:
```
Authorization: Bearer <Firebase ID Token>
```
Token di-verify server-side. Kalau expired/invalid → `401 {"error":"unauthorized"}`.

### `POST /v1/auth/signin`
Verify Firebase ID token, buat user Firestore kalau belum ada.

Request:
```json
{ "idToken": "<firebase-id-token>", "displayName": "optional" }
```
Response `200`:
```json
{
  "user": {
    "uid": "...",
    "email": "...",
    "displayName": "...",
    "createdAt": "ISO-8601"
  },
  "profiles": []
}
```

## Profiles

| Method | Path | Desc |
|---|---|---|
| GET | `/v1/profiles` | list |
| POST | `/v1/profiles` | create |
| PATCH | `/v1/profiles/{id}` | update (name/avatar/isKid) |
| DELETE | `/v1/profiles/{id}` | delete |

```json
{ "name": "Ahmad", "avatarColor": "blue", "isKid": false }
```

## My List

| Method | Path |
|---|---|
| GET | `/v1/profiles/{id}/mylist` |
| POST | `/v1/profiles/{id}/mylist/{mediaType}/{mediaId}` |
| DELETE | `/v1/profiles/{id}/mylist/{mediaType}/{mediaId}` |
| PUT | `/v1/profiles/{id}/mylist/{mediaType}/{mediaId}` (toggle) |

`mediaType` = `movie` | `tv`.

## Continue Watching

| Method | Path |
|---|---|
| GET | `/v1/profiles/{id}/progress` |
| PUT | `/v1/profiles/{id}/progress/{mediaType}/{mediaId}` — `{ "position": 372, "completion": 0.45 }` |
| DELETE | `/v1/profiles/{id}/progress/{mediaType}/{mediaId}` (mark complete) |

## Watch History

| Method | Path |
|---|---|
| GET | `/v1/profiles/{id}/history?limit=20&cursor=` |
| POST | `/v1/profiles/{id}/history` — `{ "mediaId": 12, "mediaType": "movie", "completed": false }` |

## Notifications

| Method | Path |
|---|---|
| POST | `/v1/notifications/device/register` — `{ "fcmToken": "...", "platform": "ios" }` |
| GET | `/v1/notifications` |
| PATCH | `/v1/notifications/{id}/read` |

## Content (TMDB Proxy)

TMDB token only server-side. iOS client never touching TMDB.

| Method | Path |
|---|---|
| GET | `/v1/content/trending?time_window=week` |
| GET | `/v1/content/search?query=` |
| GET | `/v1/content/genres/movie` → `/v1/content/genres/tv` |
| GET | `/v1/content/{kind}/list/{listName}` — contoh `movie/list/popular`, `tv/list/top_rated` |
| GET | `/v1/content/{kind}/data/{id}` — detail `movie`/`tv` |
| GET | `/v1/content/{kind}/data/{id}/videos` |
| GET | `/v1/content/{kind}/data/{id}/recommendations` |
| GET | `/v1/content/{kind}/data/{id}/season/{season}` |
| GET | `/v1/content/discover?genre=&sort=` |

Response = raw JSON TMDB (pass-through). `503` kalau token belum diset di server.

## Videos (Streaming Catalog)

| Method | Path |
|---|---|
| GET | `/v1/videos` |
| GET | `/v1/videos/{videoId}` |

```json
{
  "videoId": "big-buck-bunny",
  "title": "Big Buck Bunny",
  "description": "...",
  "posterUrl": "...",
  "streamUrl": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
  "duration": 596,
  "qualities": ["360p", "720p", "1080p"],
  "categories": ["Animation", "Family"]
}
```
Seed catalog: `make seed` (butuh service account + project).

## Errors

Semua error JSON:
```json
{ "error": "human-readable message" }
```

| Code | Meaning |
|---|---|
| 400 | bad request body/params |
| 401 | missing/invalid ID token |
| 403 | not owner (misal akses profile orang lain) |
| 404 | resource not found |
| 500 | internal error |

## Dev Mode

Tanpa Firebase credentials:
- `ALLOW_UNAUTHENTICATED_DEV=false` → protected routes selalu `401` (fails closed).
- `ALLOW_UNAUTHENTICATED_DEV=true` → request lewat tanpa token, UID = `dev-user`. **Jangan di production.**

Test cepat local:
```bash
make run
curl http://localhost:8080/healthz
```

## Deploy

```bash
make deploy PROJECT_ID=<your-gcp-project> TMDB_TOKEN=<tmdb-v3-access-token>
```
Setelah deploy:
1. Upload `firebase/firestore.rules` (Firebase console atau `firebase deploy --only firestore`).
2. Seed catalog: `make seed` dengan service account.
3. Cron (mingguan): `make deploy-cron PROJECT_ID=... TMDB_TOKEN=...` lalu Cloud Scheduler HTTP GET ke URL service `netflix-backend-cron`.

## Cron Job — "Episode Baru" Notifier

`cmd/notifier` / `ROLE=cron`:
- Scan semua user → mylist yang `mediaType=tv`
- TMDB `/tv/{id}` → `last_episode_to_air.air_date`
- Kalau lebih baru dari tracker `users/{uid}/tracker/{mediaId}` → kirim FCM + catat
- Notifikasi terekam juga di inbox `users/{uid}/notifications`

Test lokal:
```bash
make run-cron
```