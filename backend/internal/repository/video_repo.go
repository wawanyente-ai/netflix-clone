package repository

import (
	"context"

	"cloud.google.com/go/firestore"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
)

// VideoRepo reads the public content catalog at content/videos.
type VideoRepo struct {
	db *firestore.Client
}

func NewVideoRepo(db *firestore.Client) *VideoRepo {
	return &VideoRepo{db: db}
}

func (r *VideoRepo) videosCol() *firestore.CollectionRef {
	return r.db.Collection("content").Doc("catalog").Collection("videos")
}

// List returns all playable videos.
func (r *VideoRepo) List(ctx context.Context) ([]*models.Video, error) {
	iter := r.videosCol().OrderBy("title", firestore.Asc).Documents(ctx)
	defer iter.Stop()

	out := make([]*models.Video, 0)
	for {
		doc, err := iter.Next()
		if err != nil && errIsIterDone(err) {
			break
		}
		if err != nil {
			return nil, err
		}
		var v models.Video
		if err := doc.DataTo(&v); err != nil {
			return nil, err
		}
		v.VideoID = doc.Ref.ID
		out = append(out, &v)
	}
	return out, nil
}

// Get returns one video. Returns ErrNotFound when missing.
func (r *VideoRepo) Get(ctx context.Context, videoID string) (*models.Video, error) {
	snap, err := r.videosCol().Doc(videoID).Get(ctx)
	if err != nil {
		if errIsNotFound(err) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	var v models.Video
	if err := snap.DataTo(&v); err != nil {
		return nil, err
	}
	v.VideoID = snap.Ref.ID
	return &v, nil
}

// Seed writes one catalog entry (idempotent).
func (r *VideoRepo) Seed(ctx context.Context, v *models.Video) error {
	_, err := r.videosCol().Doc(v.VideoID).Set(ctx, v)
	return err
}
