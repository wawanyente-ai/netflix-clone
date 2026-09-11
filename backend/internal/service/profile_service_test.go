package service

import (
	"context"
	"errors"
	"strings"
	"testing"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/repository"
)

type fakeProfileStore struct {
	byUID map[string][]*models.Profile
}

func newFakeProfileStore() *fakeProfileStore {
	return &fakeProfileStore{byUID: map[string][]*models.Profile{}}
}

func (f *fakeProfileStore) List(_ context.Context, uid string) ([]*models.Profile, error) {
	return f.byUID[uid], nil
}

func (f *fakeProfileStore) Count(_ context.Context, uid string) (int, error) {
	return len(f.byUID[uid]), nil
}

func (f *fakeProfileStore) Get(_ context.Context, uid, profileID string) (*models.Profile, error) {
	for _, p := range f.byUID[uid] {
		if p.ProfileID == profileID {
			return p, nil
		}
	}
	return nil, repository.ErrNotFound
}

func (f *fakeProfileStore) Create(_ context.Context, uid string, p *models.Profile) (string, error) {
	f.byUID[uid] = append(f.byUID[uid], p)
	return p.ProfileID, nil
}

func (f *fakeProfileStore) Update(_ context.Context, uid, profileID string, fields map[string]any) error {
	for _, p := range f.byUID[uid] {
		if p.ProfileID == profileID {
			if v, ok := fields["name"]; ok {
				p.Name = v.(string)
			}
			if v, ok := fields["avatarColor"]; ok {
				p.AvatarColor = v.(string)
			}
			if v, ok := fields["isKid"]; ok {
				p.IsKid = v.(bool)
			}
			return nil
		}
	}
	return repository.ErrNotFound
}

func (f *fakeProfileStore) Delete(_ context.Context, uid, profileID string) error {
	profiles := f.byUID[uid]
	for i, p := range profiles {
		if p.ProfileID == profileID {
			f.byUID[uid] = append(profiles[:i], profiles[i+1:]...)
			return nil
		}
	}
	return repository.ErrNotFound
}

func testProfileSvc() (*ProfileService, *fakeProfileStore) {
	store := newFakeProfileStore()
	return NewProfileService(store, testSvcLogger()), store
}

func TestProfile_RejectInvalidName(t *testing.T) {
	svc, _ := testProfileSvc()
	_, err := svc.Create(context.Background(), "u1", &models.Profile{Name: strings.Repeat("X", 31)})
	if !errors.Is(err, ErrInvalidName) {
		t.Fatalf("want ErrInvalidName, got %v", err)
	}
}

func TestProfile_RejectInvalidAvatar(t *testing.T) {
	svc, _ := testProfileSvc()
	_, err := svc.Create(context.Background(), "u1", &models.Profile{Name: "Ok", AvatarColor: "neon"})
	if !errors.Is(err, ErrInvalidAvatar) {
		t.Fatalf("want ErrInvalidAvatar, got %v", err)
	}
}

func TestProfile_EnforceMaxLimit(t *testing.T) {
	svc, store := testProfileSvc()
	ctx := context.Background()
	for i := 0; i < MaxProfilesPerUser; i++ {
		if _, err := svc.Create(ctx, "u1", &models.Profile{Name: "P"}); err != nil {
			t.Fatalf("create %d failed: %v", i, err)
		}
	}
	_, err := svc.Create(ctx, "u1", &models.Profile{Name: "P"})
	if !errors.Is(err, ErrProfileLimit) {
		t.Fatalf("want ErrProfileLimit, got %v", err)
	}
	if got := len(store.byUID["u1"]); got != MaxProfilesPerUser {
		t.Fatalf("want %d stored, got %d", MaxProfilesPerUser, got)
	}
}

func TestProfile_UpdateNotFound(t *testing.T) {
	svc, _ := testProfileSvc()
	err := svc.Update(context.Background(), "u1", "nope", map[string]any{"name": "X"})
	if !errors.Is(err, ErrProfileNotFound) {
		t.Fatalf("want ErrProfileNotFound, got %v", err)
	}
}

func TestProfile_CreateAssignsID(t *testing.T) {
	svc, _ := testProfileSvc()
	p, err := svc.Create(context.Background(), "u1", &models.Profile{Name: "Ahmad"})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if p.ProfileID == "" {
		t.Fatal("expected generated profile ID")
	}
	if p.CreatedAt.IsZero() {
		t.Fatal("expected createdAt set")
	}
}
