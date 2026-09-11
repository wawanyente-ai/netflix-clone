package middleware

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"firebase.google.com/go/v4/auth"
	"log/slog"
)

type fakeVerifier struct {
	enabled bool
	token   string
	err     error
}

func (f *fakeVerifier) VerifyIDToken(ctx context.Context, idToken string) (*auth.Token, error) {
	if f.err != nil {
		return nil, f.err
	}
	return &auth.Token{UID: f.token}, nil
}

func (f *fakeVerifier) Enabled() bool { return f.enabled }

func noopHandler() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		uid := UID(r.Context())
		if uid == "" {
			w.WriteHeader(http.StatusAccepted)
			return
		}
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(uid))
	})
}

func logger() *slog.Logger {
	return slog.New(slog.NewTextHandler(discard{}, nil))
}

type discard struct{}

func (discard) Write(p []byte) (int, error) { return len(p), nil }

func TestAuthenticate_RejectsNoToken(t *testing.T) {
	v := &fakeVerifier{enabled: true}
	h := Authenticate(v, false, logger())(noopHandler())

	req := httptest.NewRequest(http.MethodGet, "/v1/profiles", nil)
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)

	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("want 401, got %d", rec.Code)
	}
}

func TestAuthenticate_RejectsInvalidToken(t *testing.T) {
	v := &fakeVerifier{enabled: true, err: errors.New("expired")}
	h := Authenticate(v, false, logger())(noopHandler())

	req := httptest.NewRequest(http.MethodGet, "/v1/profiles", nil)
	req.Header.Set("Authorization", "Bearer abc")
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)

	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("want 401, got %d", rec.Code)
	}
}

func TestAuthenticate_PassesUID(t *testing.T) {
	v := &fakeVerifier{enabled: true, token: "user-123"}
	h := Authenticate(v, false, logger())(noopHandler())

	req := httptest.NewRequest(http.MethodGet, "/v1/profiles", nil)
	req.Header.Set("Authorization", "Bearer good-token")
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("want 200, got %d", rec.Code)
	}
	if body := rec.Body.String(); body != "user-123" {
		t.Fatalf("want uid user-123, got %q", body)
	}
}

func TestAuthenticate_DisabledFailsClosed(t *testing.T) {
	v := &fakeVerifier{enabled: false} // nil-equivalent: no credentials
	h := Authenticate(v, false, logger())(noopHandler())

	req := httptest.NewRequest(http.MethodGet, "/v1/profiles", nil)
	req.Header.Set("Authorization", "Bearer abc")
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)

	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("want 401 (fails closed), got %d", rec.Code)
	}
}

func TestAuthenticate_DevBypass(t *testing.T) {
	v := &fakeVerifier{enabled: false}
	h := Authenticate(v, true, logger())(noopHandler())

	req := httptest.NewRequest(http.MethodGet, "/v1/profiles", nil)
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("want 200 (dev bypass), got %d", rec.Code)
	}
	if body := rec.Body.String(); body != "dev-user" {
		t.Fatalf("want dev-user, got %q", body)
	}
}

func TestAuthenticate_DevBypassStashesToken(t *testing.T) {
	v := &fakeVerifier{enabled: true}
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		tok := VerifiedToken(r.Context())
		if tok == nil || tok.UID != "dev-user" {
			w.WriteHeader(http.StatusTeapot)
			return
		}
		if tok.Claims["email"] != "dev@local" {
			w.WriteHeader(http.StatusTeapot)
			return
		}
		w.WriteHeader(http.StatusOK)
	})
	h := Authenticate(v, true, logger())(handler)

	req := httptest.NewRequest(http.MethodGet, "/v1/profiles", nil)
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("want 200 with synthetic token, got %d", rec.Code)
	}
}
