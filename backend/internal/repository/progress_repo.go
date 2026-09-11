package repository

import (
	"context"

	"cloud.google.com/go/firestore"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
)

// ProgressRepo persists continue-watching state under
// users/{uid}/profiles/{id}/progress.
type ProgressRepo struct {
	db *firestore.Client
}

func NewProgressRepo(db *firestore.Client) *ProgressRepo {
	return &ProgressRepo{db: db}
}

func (r *ProgressRepo) progressCol(uid, profileID string) *firestore.CollectionRef {
	return r.db.Collection("users").Doc(uid).Collection("profiles").Doc(profileID).Collection("progress")
}

// List returns in-progress titles, most recent first.
func (r *ProgressRepo) List(ctx context.Context, uid, profileID string) ([]*models.WatchProgress, error) {
	iter := r.progressCol(uid, profileID).OrderBy("updatedAt", firestore.Desc).Documents(ctx)
	defer iter.Stop()

	out := make([]*models.WatchProgress, 0)
	for {
		doc, err := iter.Next()
		if err != nil && errIsIterDone(err) {
			break
		}
		if err != nil {
			return nil, err
		}
		var p models.WatchProgress
		if err := doc.DataTo(&p); err != nil {
			return nil, err
		}
		out = append(out, &p)
	}
	return out, nil
}

// Upsert saves playback position (last-write-wins).
func (r *ProgressRepo) Upsert(ctx context.Context, uid, profileID, key string, p *models.WatchProgress) error {
	_, err := r.progressCol(uid, profileID).Doc(key).Set(ctx, p)
	return err
}

// Remove clears progress (e.g. marked complete). Returns ErrNotFound when absent.
func (r *ProgressRepo) Remove(ctx context.Context, uid, profileID, key string) error {
	_, err := r.progressCol(uid, profileID).Doc(key).Delete(ctx)
	if err != nil && errIsNotFound(err) {
		return ErrNotFound
	}
	return err
}
