package service

import (
	"context"
	"errors"
	"log/slog"
	"time"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
)

// Watchlist errors.
var ErrInvalidMediaType = errors.New("mediaType must be movie or tv")

// ErrInvalidMediaID guards against non-positive media IDs.
var ErrInvalidMediaID = errors.New("invalid mediaId")

// WatchlistInput carries the client-supplied fields for save actions.
type WatchlistInput struct {
	Title      string
	PosterPath string
}

// WatchlistStore abstracts watchlist persistence.
type WatchlistStore interface {
	List(ctx context.Context, uid, profileID string) ([]*models.WatchlistItem, error)
	Exists(ctx context.Context, uid, profileID, key string) (bool, error)
	Add(ctx context.Context, uid, profileID, key string, item *models.WatchlistItem) error
	Remove(ctx context.Context, uid, profileID, key string) error
}

// WatchlistService provides the save/unsave logic including toggle.
type WatchlistService struct {
	store  WatchlistStore
	logger *slog.Logger
}

func NewWatchlistService(store WatchlistStore, logger *slog.Logger) *WatchlistService {
	return &WatchlistService{store: store, logger: logger}
}

// Save adds a title if not already present. Idempotent.
func (s *WatchlistService) Save(ctx context.Context, uid, profileID string, mediaType models.MediaType, mediaID int64, in WatchlistInput) error {
	if !mediaType.Valid() {
		return ErrInvalidMediaType
	}
	key := models.MediaKey(mediaType, mediaID)
	exists, err := s.store.Exists(ctx, uid, profileID, key)
	if err != nil {
		return err
	}
	if exists {
		return nil
	}
	item := &models.WatchlistItem{
		MediaID:    mediaID,
		MediaType:  string(mediaType),
		Title:      in.Title,
		PosterPath: in.PosterPath,
		AddedAt:    time.Now().UTC(),
	}
	return s.store.Add(ctx, uid, profileID, key, item)
}

// Remove deletes a title. Returns ErrWatchlistNotFound when absent.
func (s *WatchlistService) Remove(ctx context.Context, uid, profileID string, mediaType models.MediaType, mediaID int64) error {
	if !mediaType.Valid() {
		return ErrInvalidMediaType
	}
	key := models.MediaKey(mediaType, mediaID)
	return s.store.Remove(ctx, uid, profileID, key)
}

// Toggle removes the title when saved, adds it otherwise, and reports the
// resulting state (saved=true after save, false after removal).
func (s *WatchlistService) Toggle(ctx context.Context, uid, profileID string, mediaType models.MediaType, mediaID int64, in WatchlistInput) (bool, error) {
	key := models.MediaKey(mediaType, mediaID)
	exists, err := s.store.Exists(ctx, uid, profileID, key)
	if err != nil {
		return false, err
	}
	if exists {
		if err := s.store.Remove(ctx, uid, profileID, key); err != nil {
			return false, err
		}
		return false, nil
	}
	item := &models.WatchlistItem{
		MediaID:    mediaID,
		MediaType:  string(mediaType),
		Title:      in.Title,
		PosterPath: in.PosterPath,
		AddedAt:    time.Now().UTC(),
	}
	if err := s.store.Add(ctx, uid, profileID, key, item); err != nil {
		return false, err
	}
	return true, nil
}

// List returns saved titles.
func (s *WatchlistService) List(ctx context.Context, uid, profileID string) ([]*models.WatchlistItem, error) {
	return s.store.List(ctx, uid, profileID)
}
