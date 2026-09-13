package service

import (
	"context"
	"errors"
	"testing"

	"firebase.google.com/go/v4/auth"
	"github.com/google/uuid"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/repository"
)

type fakeStore struct {
	users map[string]*models.User
}

func (f *fakeStore) GetUser(_ context.Context, uid string) (*models.User, error) {
	if u, ok := f.users[uid]; ok {
		return u, nil
	}
	return nil, repository.ErrNotFound
}

func (f *fakeStore) CreateUser(_ context.Context, u *models.User) error {
	if _, ok := f.users[u.UID]; ok {
		return errors.New("already exists")
	}
	f.users[u.UID] = u
	return nil
}

func testToken(uid string, claims map[string]any) *auth.Token {
	return &auth.Token{UID: uid, Claims: claims}
}

func testSvc() (*UserService, *fakeStore) {
	store := &fakeStore{users: map[string]*models.User{}}
	return NewUserService(store, testSvcLogger()), store
}

func TestGetOrCreateUser_CreatesOnFirstSignIn(t *testing.T) {
	svc, store := testSvc()
	uid := uuid.NewString()
	tok := testToken(uid, map[string]any{
		"email":                     "ahmad@example.com",
		"name":                      "Ahmad Reza",
		"firebase.sign_in_provider": "google.com",
	})

	u, err := svc.GetOrCreateUser(context.Background(), tok, "")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if u.UID != uid {
		t.Fatalf("want uid %s, got %s", uid, u.UID)
	}
	if u.Email != "ahmad@example.com" {
		t.Fatalf("want email ahmad@example.com, got %s", u.Email)
	}
	if u.DisplayName != "Ahmad Reza" {
		t.Fatalf("want displayName Ahmad Reza, got %s", u.DisplayName)
	}
	if u.Provider != "google.com" {
		t.Fatalf("want provider google.com, got %s", u.Provider)
	}
	if _, ok := store.users[uid]; !ok {
		t.Fatal("expected user to be persisted")
	}
}

func TestGetOrCreateUser_Idempotent(t *testing.T) {
	svc, _ := testSvc()
	uid := uuid.NewString()
	tok := testToken(uid, map[string]any{"email": "a@example.com"})

	first, err := svc.GetOrCreateUser(context.Background(), tok, "")
	if err != nil {
		t.Fatalf("first sign-in failed: %v", err)
	}
	second, err := svc.GetOrCreateUser(context.Background(), tok, "")
	if err != nil {
		t.Fatalf("second sign-in failed: %v", err)
	}
	if first.UID != second.UID || second.CreatedAt.IsZero() {
		t.Fatal("idempotent sign-in should return same user")
	}
}

func TestGetOrCreateUser_FallsBackToEmail(t *testing.T) {
	svc, _ := testSvc()
	tok := testToken(uuid.NewString(), map[string]any{"email": "dewi@example.com"})

	u, err := svc.GetOrCreateUser(context.Background(), tok, "")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if u.DisplayName != "Dewi" {
		t.Fatalf("want displayName Dewi, got %s", u.DisplayName)
	}
}

func TestGetOrCreateUser_EmailNameFromFirstAndLastName(t *testing.T) {
	svc, _ := testSvc()
	tok := testToken(uuid.NewString(), map[string]any{"email": "dewi.maya@example.com"})

	u, err := svc.GetOrCreateUser(context.Background(), tok, "")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if u.DisplayName != "Dewi Maya" {
		t.Fatalf("want displayName Dewi Maya, got %s", u.DisplayName)
	}
}

func TestGetOrCreateUser_UsesPreferredNameWhenTokenHasNoName(t *testing.T) {
	svc, _ := testSvc()
	tok := testToken(uuid.NewString(), map[string]any{"email": "dewi@example.com"})

	u, err := svc.GetOrCreateUser(context.Background(), tok, "  Dewi Lestari  ")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if u.DisplayName != "Dewi Lestari" {
		t.Fatalf("want displayName Dewi Lestari, got %q", u.DisplayName)
	}
}

func TestGetOrCreateUser_TokenNameWinsOverPreferred(t *testing.T) {
	svc, _ := testSvc()
	tok := testToken(uuid.NewString(), map[string]any{
		"email": "budi@example.com",
		"name":  "Budi Santoso",
	})

	u, err := svc.GetOrCreateUser(context.Background(), tok, "Nama Salah")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if u.DisplayName != "Budi Santoso" {
		t.Fatalf("want displayName Budi Santoso (token name wins), got %q", u.DisplayName)
	}
}
