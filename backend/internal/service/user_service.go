package service

import (
	"context"
	"errors"
	"log/slog"
	"time"

	"firebase.google.com/go/v4/auth"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/repository"
)

// ErrServiceConflict is returned when a user document already exists.
var ErrUserConflict = errors.New("user already exists")

// UserStore abstracts user persistence for testability.
type UserStore interface {
	GetUser(ctx context.Context, uid string) (*models.User, error)
	CreateUser(ctx context.Context, u *models.User) error
}

// UserService handles sign-in lifecycle: get-or-create a user from a
// verified Firebase ID token's claims.
type UserService struct {
	store  UserStore
	logger *slog.Logger
}

func NewUserService(store UserStore, logger *slog.Logger) *UserService {
	return &UserService{store: store, logger: logger}
}

// GetOrCreateUser returns the existing user or creates one from token claims.
// Idempotent: repeated sign-ins never duplicate documents.
func (s *UserService) GetOrCreateUser(ctx context.Context, tok *auth.Token) (*models.User, error) {
	uid := tok.UID

	existing, err := s.store.GetUser(ctx, uid)
	if err == nil {
		return existing, nil
	}
	if !errors.Is(err, repository.ErrNotFound) {
		return nil, err
	}

	u := &models.User{
		UID:         uid,
		Email:       stringClaim(tok, "email"),
		DisplayName: stringClaim(tok, "name"),
		Provider:    stringClaim(tok, "firebase.sign_in_provider"),
		CreatedAt:   time.Now().UTC(),
	}
	if u.DisplayName == "" {
		u.DisplayName = emailPrefix(u.Email)
	}

	if err := s.store.CreateUser(ctx, u); err != nil {
		// Lost a race with a concurrent sign-in: the user exists now.
		if existing, getErr := s.store.GetUser(ctx, uid); getErr == nil {
			return existing, nil
		}
		return nil, err
	}
	s.logger.Info("user created", "uid", uid, "provider", u.Provider)
	return u, nil
}

func stringClaim(tok *auth.Token, key string) string {
	if v, ok := tok.Claims[key].(string); ok {
		return v
	}
	return ""
}

func emailPrefix(email string) string {
	for i, r := range email {
		if r == '@' {
			return email[:i]
		}
	}
	return email
}
