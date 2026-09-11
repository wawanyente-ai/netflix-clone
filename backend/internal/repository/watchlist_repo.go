package repository

import (
	"context"

	"cloud.google.com/go/firestore"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
)

// WatchlistRepo persists saved titles under users/{uid}/profiles/{id}/mylist.
type WatchlistRepo struct {
	db *firestore.Client
}

func NewWatchlistRepo(db *firestore.Client) *WatchlistRepo {
	return &WatchlistRepo{db: db}
}

func (r *WatchlistRepo) mylistCol(uid, profileID string) *firestore.CollectionRef {
	return r.db.Collection("users").Doc(uid).Collection("profiles").Doc(profileID).Collection("mylist")
}

// List returns all saved titles, newest first (requires the read profile).
func (r *WatchlistRepo) List(ctx context.Context, uid, profileID string) ([]*models.WatchlistItem, error) {
	iter := r.mylistCol(uid, profileID).OrderBy("addedAt", firestore.Desc).Documents(ctx)
	defer iter.Stop()

	out := make([]*models.WatchlistItem, 0)
	for {
		doc, err := iter.Next()
		if err != nil && errIsIterDone(err) {
			break
		}
		if err != nil {
			return nil, err
		}
		var item models.WatchlistItem
		if err := doc.DataTo(&item); err != nil {
			return nil, err
		}
		out = append(out, &item)
	}
	return out, nil
}

// Exists reports whether a title is saved.
func (r *WatchlistRepo) Exists(ctx context.Context, uid, profileID, key string) (bool, error) {
	snap, err := r.mylistCol(uid, profileID).Doc(key).Get(ctx)
	if err != nil {
		if errIsNotFound(err) {
			return false, nil
		}
		return false, err
	}
	return snap.Exists(), nil
}

// Add saves a title.
func (r *WatchlistRepo) Add(ctx context.Context, uid, profileID, key string, item *models.WatchlistItem) error {
	_, err := r.mylistCol(uid, profileID).Doc(key).Set(ctx, item)
	return err
}

// Remove deletes a saved title. Returns ErrNotFound when absent.
func (r *WatchlistRepo) Remove(ctx context.Context, uid, profileID, key string) error {
	_, err := r.mylistCol(uid, profileID).Doc(key).Delete(ctx)
	if err != nil && errIsNotFound(err) {
		return ErrNotFound
	}
	return err
}
