package service

import (
	"context"
	"errors"
	"log/slog"
	"strings"
	"time"
	"unicode"

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
// preferredName is an optional client-supplied name (e.g. Sign in with Apple,
// which does not always expose the profile name in the token). It is only used
// as a fallback when the token carries no `name` claim.
func (s *UserService) GetOrCreateUser(ctx context.Context, tok *auth.Token, preferredName string) (*models.User, error) {
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
		u.DisplayName = strings.TrimSpace(preferredName)
	}
	if u.DisplayName == "" {
		u.DisplayName = displayNameFromEmail(u.Email)
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

// displayNameFromEmail derives a human-readable name from an email address.
// "dewi.maya@example.com" → "Dewi Maya"; "dewi85@example.com" → "Dewi85".
func displayNameFromEmail(email string) string {
	prefix := email
	if i := strings.IndexByte(email, '@'); i >= 0 {
		prefix = email[:i]
	}
	parts := strings.FieldsFunc(prefix, func(r rune) bool {
		return r == '.' || r == '_' || r == '-'
	})
	names := make([]string, 0, len(parts))
	for _, p := range parts {
		if p = strings.TrimSpace(p); p == "" {
			continue
		}
		names = append(names, capitalizeWord(p))
	}
	if len(names) == 0 {
		return ""
	}
	return strings.Join(names, " ")
}

// capitalizeWord uppercases the first letter and lowercases the rest:
// "dewi" → "Dewi", "MAYA" → "Maya".
func capitalizeWord(w string) string {
	r := []rune(w)
	if len(r) == 0 {
		return ""
	}
	r[0] = unicode.ToUpper(r[0])
	for i := 1; i < len(r); i++ {
		r[i] = unicode.ToLower(r[i])
	}
	return string(r)
}
