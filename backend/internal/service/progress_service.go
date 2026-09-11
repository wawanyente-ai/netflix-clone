package service

import (
	"context"
	"errors"
	"log/slog"
	"time"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
)

// Progress errors.
var (
	ErrInvalidProgress  = errors.New("position and duration must be > 0")
	ErrProgressNotFound = errors.New("no progress found")
)

// ProgressInput carries playback state from the client.
type ProgressInput struct {
	Position   float64
	Duration   float64
	Title      string
	PosterPath string
}

// ProgressStore abstracts continue-watching persistence.
type ProgressStore interface {
	List(ctx context.Context, uid, profileID string) ([]*models.WatchProgress, error)
	Upsert(ctx context.Context, uid, profileID, key string, p *models.WatchProgress) error
	Remove(ctx context.Context, uid, profileID, key string) error
}

// ProgressService maintains continue-watching state.
type ProgressService struct {
	store  ProgressStore
	logger *slog.Logger
}

func NewProgressService(store ProgressStore, logger *slog.Logger) *ProgressService {
	return &ProgressService{store: store, logger: logger}
}

// Save stores playback position and computes completion ratio.
func (s *ProgressService) Save(ctx context.Context, uid, profileID string, mediaType models.MediaType, mediaID int64, in ProgressInput) (*models.WatchProgress, error) {
	if !mediaType.Valid() {
		return nil, ErrInvalidMediaType
	}
	if in.Position < 0 || in.Duration <= 0 {
		return nil, ErrInvalidProgress
	}
	completion := in.Position / in.Duration
	if completion > 1 {
		completion = 1
	}

	p := &models.WatchProgress{
		MediaID:    mediaID,
		MediaType:  string(mediaType),
		Title:      in.Title,
		PosterPath: in.PosterPath,
		Position:   in.Position,
		Duration:   in.Duration,
		Completion: completion,
		UpdatedAt:  time.Now().UTC(),
	}
	key := models.MediaKey(mediaType, mediaID)
	if err := s.store.Upsert(ctx, uid, profileID, key, p); err != nil {
		return nil, err
	}
	return p, nil
}

// List returns continue-watching entries, most recent first.
func (s *ProgressService) List(ctx context.Context, uid, profileID string) ([]*models.WatchProgress, error) {
	return s.store.List(ctx, uid, profileID)
}

// Remove clears playback tracking (e.g. title finished).
func (s *ProgressService) Remove(ctx context.Context, uid, profileID string, mediaType models.MediaType, mediaID int64) error {
	if !mediaType.Valid() {
		return ErrInvalidMediaType
	}
	return s.store.Remove(ctx, uid, profileID, models.MediaKey(mediaType, mediaID))
}
