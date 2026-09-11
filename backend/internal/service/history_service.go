package service

import (
	"context"
	"log/slog"
	"time"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/repository"
)

// DefaultHistoryPageSize and max are applied when the client omits limit.
const (
	DefaultHistoryPageSize = 20
	MaxHistoryPageSize     = 50
)

// HistoryStore abstracts watch-history persistence (cursor pagination).
type HistoryStore interface {
	List(ctx context.Context, uid, profileID string, limit int, cursor *repository.HistoryCursor) ([]*models.HistoryEntry, *repository.HistoryCursor, error)
	Add(ctx context.Context, uid, profileID string, entry *models.HistoryEntry) error
}

// HistoryService logs and pages through watch history.
type HistoryService struct {
	store  HistoryStore
	logger *slog.Logger
}

func NewHistoryService(store HistoryStore, logger *slog.Logger) *HistoryService {
	return &HistoryService{store: store, logger: logger}
}

// List returns one page, clamping the page size.
func (s *HistoryService) List(ctx context.Context, uid, profileID string, limit int, cursor *repository.HistoryCursor) ([]*models.HistoryEntry, *repository.HistoryCursor, error) {
	if limit <= 0 {
		limit = DefaultHistoryPageSize
	}
	if limit > MaxHistoryPageSize {
		limit = MaxHistoryPageSize
	}
	return s.store.List(ctx, uid, profileID, limit, cursor)
}

// Log records a watched title.
func (s *HistoryService) Log(ctx context.Context, uid, profileID string, mediaType models.MediaType, mediaID int64, title, posterPath string, completed bool) error {
	if !mediaType.Valid() {
		return ErrInvalidMediaType
	}
	if mediaID <= 0 {
		return ErrInvalidMediaID
	}
	entry := &models.HistoryEntry{
		MediaID:    mediaID,
		MediaType:  string(mediaType),
		Title:      title,
		PosterPath: posterPath,
		Completed:  completed,
		WatchedAt:  time.Now().UTC(),
	}
	return s.store.Add(ctx, uid, profileID, entry)
}
