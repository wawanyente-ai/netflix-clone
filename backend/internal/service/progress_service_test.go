package service

import (
	"context"
	"errors"
	"testing"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
)

type fakeProgressStore struct {
	items map[string]*models.WatchProgress
}

func newFakeProgressStore() *fakeProgressStore {
	return &fakeProgressStore{items: map[string]*models.WatchProgress{}}
}

func (f *fakeProgressStore) List(_ context.Context, _, _ string) ([]*models.WatchProgress, error) {
	out := make([]*models.WatchProgress, 0, len(f.items))
	for _, v := range f.items {
		out = append(out, v)
	}
	return out, nil
}

func (f *fakeProgressStore) Upsert(_ context.Context, _, _, key string, p *models.WatchProgress) error {
	f.items[key] = p
	return nil
}

func (f *fakeProgressStore) Remove(_ context.Context, _, _, key string) error {
	delete(f.items, key)
	return nil
}

func testProgressSvc() (*ProgressService, *fakeProgressStore) {
	store := newFakeProgressStore()
	return NewProgressService(store, testSvcLogger()), store
}

func TestProgress_SaveComputesCompletion(t *testing.T) {
	svc, _ := testProgressSvc()
	p, err := svc.Save(context.Background(), "u1", "p1", models.MediaTypeMovie, 7, ProgressInput{Position: 120, Duration: 240})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if p.Completion != 0.5 {
		t.Fatalf("want completion 0.5, got %v", p.Completion)
	}
}

func TestProgress_SaveClampsCompletionToOne(t *testing.T) {
	svc, _ := testProgressSvc()
	p, err := svc.Save(context.Background(), "u1", "p1", models.MediaTypeMovie, 7, ProgressInput{Position: 99999, Duration: 100})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if p.Completion != 1 {
		t.Fatalf("want completion clamped to 1, got %v", p.Completion)
	}
}

func TestProgress_RejectsBadInput(t *testing.T) {
	svc, _ := testProgressSvc()
	_, err := svc.Save(context.Background(), "u1", "p1", models.MediaTypeMovie, 7, ProgressInput{Position: -1, Duration: 100})
	if !errors.Is(err, ErrInvalidProgress) {
		t.Fatalf("want ErrInvalidProgress, got %v", err)
	}
	_, err = svc.Save(context.Background(), "u1", "p1", models.MediaTypeMovie, 7, ProgressInput{Position: 10, Duration: 0})
	if !errors.Is(err, ErrInvalidProgress) {
		t.Fatalf("want ErrInvalidProgress, got %v", err)
	}
}

func TestProgress_OverwritesByMediaKey(t *testing.T) {
	svc, store := testProgressSvc()
	ctx := context.Background()
	if _, err := svc.Save(ctx, "u1", "p1", models.MediaTypeMovie, 12, ProgressInput{Position: 10, Duration: 100}); err != nil {
		t.Fatal(err)
	}
	if _, err := svc.Save(ctx, "u1", "p1", models.MediaTypeMovie, 12, ProgressInput{Position: 50, Duration: 100}); err != nil {
		t.Fatal(err)
	}
	if len(store.items) != 1 {
		t.Fatalf("want single progress entry, got %d", len(store.items))
	}
	if store.items["movie:12"].Position != 50 {
		t.Fatalf("want position 50, got %v", store.items["movie:12"].Position)
	}
}
