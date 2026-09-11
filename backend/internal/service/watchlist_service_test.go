package service

import (
	"context"
	"errors"
	"testing"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
)

type fakeWatchlistStore struct {
	items map[string]*models.WatchlistItem
}

func newFakeWatchlistStore() *fakeWatchlistStore {
	return &fakeWatchlistStore{items: map[string]*models.WatchlistItem{}}
}

func (f *fakeWatchlistStore) List(_ context.Context, _, _ string) ([]*models.WatchlistItem, error) {
	out := make([]*models.WatchlistItem, 0, len(f.items))
	for _, v := range f.items {
		out = append(out, v)
	}
	return out, nil
}

func (f *fakeWatchlistStore) Exists(_ context.Context, _, _, key string) (bool, error) {
	_, ok := f.items[key]
	return ok, nil
}

func (f *fakeWatchlistStore) Add(_ context.Context, _, _, key string, item *models.WatchlistItem) error {
	f.items[key] = item
	return nil
}

func (f *fakeWatchlistStore) Remove(_ context.Context, _, _, key string) error {
	delete(f.items, key)
	return nil
}

func testWatchlistSvc() (*WatchlistService, *fakeWatchlistStore) {
	store := newFakeWatchlistStore()
	return NewWatchlistService(store, testSvcLogger()), store
}

func TestWatchlist_SaveIdempotent(t *testing.T) {
	svc, store := testWatchlistSvc()
	ctx := context.Background()
	err := svc.Save(ctx, "u1", "p1", models.MediaTypeMovie, 123, WatchlistInput{Title: "Inception"})
	if err != nil {
		t.Fatalf("first save: %v", err)
	}
	err = svc.Save(ctx, "u1", "p1", models.MediaTypeMovie, 123, WatchlistInput{Title: "Inception"})
	if err != nil {
		t.Fatalf("second save should be idempotent: %v", err)
	}
	if got := len(store.items); got != 1 {
		t.Fatalf("want 1 stored item, got %d", got)
	}
}

func TestWatchlist_Toggle(t *testing.T) {
	svc, store := testWatchlistSvc()
	ctx := context.Background()

	saved, err := svc.Toggle(ctx, "u1", "p1", models.MediaTypeTV, 999, WatchlistInput{Title: "Stranger Things"})
	if err != nil {
		t.Fatalf("toggle on: %v", err)
	}
	if !saved {
		t.Fatal("want saved=true after toggle on")
	}
	saved, err = svc.Toggle(ctx, "u1", "p1", models.MediaTypeTV, 999, WatchlistInput{})
	if err != nil {
		t.Fatalf("toggle off: %v", err)
	}
	if saved {
		t.Fatal("want saved=false after toggle off")
	}
	if len(store.items) != 0 {
		t.Fatalf("want empty store, got %d", len(store.items))
	}
}

func TestWatchlist_InvalidMediaType(t *testing.T) {
	svc, _ := testWatchlistSvc()
	err := svc.Save(context.Background(), "u1", "p1", "clip", 1, WatchlistInput{})
	if !errors.Is(err, ErrInvalidMediaType) {
		t.Fatalf("want ErrInvalidMediaType, got %v", err)
	}
}

func TestWatchlist_MovieAndTVSameIDCoexist(t *testing.T) {
	svc, store := testWatchlistSvc()
	ctx := context.Background()
	if err := svc.Save(ctx, "u1", "p1", models.MediaTypeMovie, 42, WatchlistInput{}); err != nil {
		t.Fatal(err)
	}
	if err := svc.Save(ctx, "u1", "p1", models.MediaTypeTV, 42, WatchlistInput{}); err != nil {
		t.Fatal(err)
	}
	if got := len(store.items); got != 2 {
		t.Fatalf("want 2 items (movie:42, tv:42), got %d", got)
	}
}
