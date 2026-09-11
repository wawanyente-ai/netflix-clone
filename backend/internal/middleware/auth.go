package middleware

import (
	"context"
	"log/slog"
	"net/http"
	"strings"

	"firebase.google.com/go/v4/auth"
)

type ctxKey int

const (
	uidKey ctxKey = iota
	tokenKey
)

// UID returns the authenticated user ID from the request context.
// Empty string when the request is unauthenticated.
func UID(ctx context.Context) string {
	if v, ok := ctx.Value(uidKey).(string); ok {
		return v
	}
	return ""
}

// VerifiedToken returns the decoded Firebase token (claims) from the
// request context, or nil when absent.
func VerifiedToken(ctx context.Context) *auth.Token {
	if v, ok := ctx.Value(tokenKey).(*auth.Token); ok {
		return v
	}
	return nil
}

// Authenticate validates the Firebase ID token from the Authorization header
// and injects the verified UID into the request context.
// Fails closed in production. Dev-only bypass when ALLOW_UNAUTHENTICATED_DEV
// is set: requests pass with a synthetic dev-user identity.
func Authenticate(verifier TokenVerifier, allowUnauthDev bool, logger *slog.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if allowUnauthDev {
				logger.Warn("auth bypassed (dev only): accepting request without ID token",
					"method", r.Method, "path", r.URL.Path)
				ctx := context.WithValue(r.Context(), uidKey, devUserUID)
				ctx = context.WithValue(ctx, tokenKey, devToken())
				next.ServeHTTP(w, r.WithContext(ctx))
				return
			}

			if verifier == nil || !verifier.Enabled() {
				unauthorized(w)
				return
			}

			token := strings.TrimPrefix(r.Header.Get("Authorization"), "Bearer ")
			if token == "" || token == r.Header.Get("Authorization") {
				unauthorized(w)
				return
			}

			decoded, err := verifier.VerifyIDToken(r.Context(), token)
			if err != nil {
				logger.Warn("invalid id token", "err", err, "path", r.URL.Path)
				unauthorized(w)
				return
			}

			ctx := context.WithValue(r.Context(), uidKey, decoded.UID)
			ctx = context.WithValue(ctx, tokenKey, decoded)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// devUserUID is the synthetic identity used in local development.
const devUserUID = "dev-user"

// devToken fabricates a token matching devUserUID so handlers (e.g. sign-in)
// see plausible claims. Firestore docs for dev-user become test fixtures.
func devToken() *auth.Token {
	return &auth.Token{
		UID: devUserUID,
		Claims: map[string]any{
			"email":                     "dev@local",
			"name":                      "Dev User",
			"firebase.sign_in_provider": "local",
		},
	}
}

func unauthorized(w http.ResponseWriter) {
	http.Error(w, `{"error":"unauthorized"}`, http.StatusUnauthorized)
}
