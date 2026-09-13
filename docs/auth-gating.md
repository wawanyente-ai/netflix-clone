# Auth Gating Rules — Netflix Clone

Aturan akses fitur vs status autentikasi. Reference untuk semua agent AI & developer.

## Flow

1. **Fresh install** → wajib lewat **Onboarding** (4 slide + page indicator). Tombol "Get Started" → Sign In sheet; user bisa pilih sign-in atau tutup.
2. Setelah onboarding → **main app (guest mode)**. Tidak wajib login untuk pakai aplikasi.
3. Tab + halaman browsing terbuka untuk guest. Fitur personal di-gate oleh `AppRouter.requireAuth`.

Status login disimpan di `UserDefaults["isSignedIn"]`, dikelola `AppRouter` (`completeSignIn`, `signOut`).

## Matriks Akses

| Fitur | Guest (tanpa login) | Signed-in |
|---|---|---|
| Onboarding | wajib sekali | — |
| Home — rails, hero, filter | ✅ | ✅ |
| Search — trending + hasil | ✅ | ✅ |
| Title Detail — info, cast, episode, trailer | ✅ | ✅ |
| Video Player (konten demo katalog) | ✅ | ✅ |
| Klip — browsing | ✅ | ✅ |
| **My List** save/unsave (Home hero, Klip) | 🔒 sheet sign-in | ✅ |
| **Download** (Title Detail) | 🔒 sheet sign-in | ✅ |
| **Netflix Saya** — profil, download, riwayat | 🔒 prompt sign-in | ✅ |
| **Continue Watching** rail | disembunyikan | ✅ |
| **Watch History** (riwayat) | disembunyikan | ✅ |

## Mechanisme Implementasi

- `AppRouter.requireAuth(action)` di `netflix-clone/Features/Navigation/AppRouter.swift`:
  - signed-in → langsung eksekusi `action`
  - guest → simpan `pendingAction` + tampilkan `showSignInSheet = true`
- Sheet = `AuthSheetView` (Google/Apple, stand-in icon sementara). Login sukses → `completeSignIn()` → jalan `pendingAction`.
- `NetflixSayaPage` menerima `isSignedIn` + `onSignInTap`; guest melihat prompt login, bukan data.

## Backend

Backend server (Go, `backend/`) butuh ID token Firebase untuk semua route `/v1/*`. Untuk dev lokal tanpa iOS token:

- `ALLOW_UNAUTHENTICATED_DEV=true` di `backend/.env` → semua request dianggap user `dev-user` (synthetic token `dev@local`). **Wajib false di production.**
- Token TMDB **hanya di server** (`backend/internal/tmdb`), iOS tidak pegang token.

## Status Auth (selesai)

- **Real sign-in (Google)**: Firebase iOS SDK (GoogleSignIn, `AuthService`) + `POST /v1/auth/signin` → backend verifikasi token → get-or-create user di Firestore (`users/{uid}`: `email`, `displayName`, `provider`, `createdAt`). Info user **tersimpan**, bukan sekadar flag.
- `completeSignIn` → `AuthService.signInWithGoogle()` → Firebase ID token → `BackendConfig.idToken` → `POST /v1/auth/signin` → simpan user + profiles.
- `isSignedIn` = ada session valid: app cadangkan user+profiles ke `UserDefaults` (`cachedBackendUser`, `cachedProfiles`) lalu validasi ulang token ke backend saat launch. Token invalid/expired (401) → logout bersih. Backend offline → session cache tetap login.
- Profil default user baru = `displayName` user (bukan hardcoded).
- Signed-in state tidak semata flag: `restoreSessionIfNeeded` me-refresh session + fallback cache.

## Tantangan Ke Depan (Fase 8)