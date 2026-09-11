package service

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/repository"
)

type fakeHistoryStore struct {
	entries []*models.HistoryEntry
}

func (f *fakeHistoryStore) List(_ context.Context, _, _ string, limit int, cursor *repository.HistoryCursor) ([]*models.HistoryEntry, *repository.HistoryCursor, error) {
	if cursor == nil {
		out := min(limit, len(f.entries))
		next := &repository.HistoryCursor{}
		if out < len(f.entries) && out > 0 {
			next.WatchedAt = f.entries[out-1].WatchedAt
			next.Key = "k"
		}
		return f.entries[:out], next, nil
	}
	return []*models.HistoryEntry{}, nil, nil
}

func (f *fakeHistoryStore) Add(_ context.Context, _, _ string, entry *models.HistoryEntry) error {
	f.entries = append(f.entries, entry)
	return nil
}

func testHistorySvc() (*HistoryService, *fakeHistoryStore) {
	store := &fakeHistoryStore{}
	return NewHistoryService(store, testSvcLogger()), store
}

func TestHistory_RejectsInvalidMediaType(t *testing.T) {
	svc, _ := testHistorySvc()
	err := svc.Log(context.Background(), "u1", "p1", "clip", 1, "T", "", false)
	if !errors.Is(err, ErrInvalidMediaType) {
		t.Fatalf("want ErrInvalidMediaType, got %v", err)
	}
}

func TestHistory_RejectsZeroMediaID(t *testing.T) {
	svc, _ := testHistorySvc()
	err := svc.Log(context.Background(), "u1", "p1", models.MediaTypeMovie, 0, "T", "", false)
	if !errors.Is(err, ErrInvalidMediaID) {
		t.Fatalf("want ErrInvalidMediaID, got %v", err)
	}
}

func TestHistory_LogSetsTimestamp(t *testing.T) {
	svc, store := testHistorySvc()
	before := time.Now().UTC()
	if err := svc.Log(context.Background(), "u1", "p1", models.MediaTypeMovie, 7, "Inception", "", false); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	entry := store.entries[0]
	if entry.MediaID != 7 || entry.Title != "Inception" {
		t.Fatalf("unexpected entry: %+v", entry)
	}
	if entry.WatchedAt.Before(before) {
		t.Fatal("watchedAt should be set at log time")
	}
}

func TestHistory_ClampsLimit(t *testing.T) {
	svc, _ := testHistorySvc()
	_, _, err := svc.List(context.Background(), "u1", "p1", -5, nil)
	if err != nil {
		// no-op: clamping verified implicitly; must not panic
		t.Fatalf("list with bad limit must not error: %v", err)
	}
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
