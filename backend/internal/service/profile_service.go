package service

import (
	"context"
	"errors"
	"log/slog"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/repository"
)

// Profile limits.
const (
	MaxProfilesPerUser = 5
	MaxProfileNameLen  = 30
)

// Allowed avatar colors matching DesignSystem UserVariant tokens.
var AllowedAvatarColors = map[string]bool{
	"blue":       true,
	"pink":       true,
	"turquoise":  true,
	"turquoise1": true,
}

// Profile errors mapped to HTTP statuses by handlers.
var (
	ErrInvalidName     = errors.New("profile name required (max 30 chars)")
	ErrInvalidAvatar   = errors.New("invalid avatarColor")
	ErrProfileLimit    = errors.New("profile limit reached")
	ErrProfileNotFound = errors.New("profile not found")
)

// ProfileStore abstracts profile persistence.
type ProfileStore interface {
	List(ctx context.Context, uid string) ([]*models.Profile, error)
	Count(ctx context.Context, uid string) (int, error)
	Get(ctx context.Context, uid, profileID string) (*models.Profile, error)
	Create(ctx context.Context, uid string, p *models.Profile) (string, error)
	Update(ctx context.Context, uid, profileID string, fields map[string]any) error
	Delete(ctx context.Context, uid, profileID string) error
}

// ProfileService enforces profile business rules.
type ProfileService struct {
	store  ProfileStore
	logger *slog.Logger
}

func NewProfileService(store ProfileStore, logger *slog.Logger) *ProfileService {
	return &ProfileService{store: store, logger: logger}
}

// List returns the user's profiles.
func (s *ProfileService) List(ctx context.Context, uid string) ([]*models.Profile, error) {
	return s.store.List(ctx, uid)
}

// Get returns a profile owned by the user. Returns ErrProfileNotFound when
// missing or owned by another user (routes are scoped to the caller's uid,
// so "not found" covers both cases).
func (s *ProfileService) Get(ctx context.Context, uid, profileID string) (*models.Profile, error) {
	p, err := s.store.Get(ctx, uid, profileID)
	if errors.Is(err, repository.ErrNotFound) {
		return nil, ErrProfileNotFound
	}
	return p, err
}

// Create validates and persists a new profile.
func (s *ProfileService) Create(ctx context.Context, uid string, p *models.Profile) (*models.Profile, error) {
	if err := validateProfile(p); err != nil {
		return nil, err
	}
	count, err := s.store.Count(ctx, uid)
	if err != nil {
		return nil, err
	}
	if count >= MaxProfilesPerUser {
		return nil, ErrProfileLimit
	}

	p.ProfileID = uuid.NewString()
	p.CreatedAt = time.Now().UTC()
	newID, err := s.store.Create(ctx, uid, p)
	if err != nil {
		return nil, err
	}
	p.ProfileID = newID
	s.logger.Info("profile created", "uid", uid, "profileId", newID, "name", p.Name)
	return p, nil
}

// Update validates and applies partial profile updates.
func (s *ProfileService) Update(ctx context.Context, uid, profileID string, fields map[string]any) error {
	if name, ok := fields["name"].(string); ok {
		if err := validateName(name); err != nil {
			return err
		}
		fields["name"] = name
	}
	if avatar, ok := fields["avatarColor"].(string); ok {
		if !AllowedAvatarColors[avatar] {
			return ErrInvalidAvatar
		}
		fields["avatarColor"] = avatar
	}
	err := s.store.Update(ctx, uid, profileID, fields)
	if errors.Is(err, repository.ErrNotFound) {
		return ErrProfileNotFound
	}
	return err
}

// Delete removes a profile.
func (s *ProfileService) Delete(ctx context.Context, uid, profileID string) error {
	err := s.store.Delete(ctx, uid, profileID)
	if errors.Is(err, repository.ErrNotFound) {
		return ErrProfileNotFound
	}
	return err
}

func validateProfile(p *models.Profile) error {
	if err := validateName(p.Name); err != nil {
		return err
	}
	if p.AvatarColor != "" && !AllowedAvatarColors[p.AvatarColor] {
		return ErrInvalidAvatar
	}
	return nil
}

func validateName(name string) error {
	name = strings.TrimSpace(name)
	if name == "" || len([]rune(name)) > MaxProfileNameLen {
		return ErrInvalidName
	}
	return nil
}
