package repository

import (
	"context"

	"cloud.google.com/go/firestore"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
)

// ProfileRepo persists Netflix-style profiles under users/{uid}/profiles.
type ProfileRepo struct {
	db *firestore.Client
}

func NewProfileRepo(db *firestore.Client) *ProfileRepo {
	return &ProfileRepo{db: db}
}

func (r *ProfileRepo) profilesCol(uid string) *firestore.CollectionRef {
	return r.db.Collection("users").Doc(uid).Collection("profiles")
}

// List returns all profiles sorted by creation time.
func (r *ProfileRepo) List(ctx context.Context, uid string) ([]*models.Profile, error) {
	iter := r.profilesCol(uid).OrderBy("createdAt", firestore.Asc).Documents(ctx)
	defer iter.Stop()

	out := make([]*models.Profile, 0)
	for {
		doc, err := iter.Next()
		if err != nil && errIsIterDone(err) {
			break
		}
		if err != nil {
			return nil, err
		}
		var p models.Profile
		if err := doc.DataTo(&p); err != nil {
			return nil, err
		}
		p.ProfileID = doc.Ref.ID
		out = append(out, &p)
	}
	return out, nil
}

// Count returns the number of profiles (for the max-profiles limit).
func (r *ProfileRepo) Count(ctx context.Context, uid string) (int, error) {
	iter := r.profilesCol(uid).Documents(ctx)
	defer iter.Stop()

	n := 0
	for {
		_, err := iter.Next()
		if err != nil && errIsIterDone(err) {
			break
		}
		if err != nil {
			return 0, err
		}
		n++
	}
	return n, nil
}

// Get fetches one profile. Returns repository.ErrNotFound when missing.
func (r *ProfileRepo) Get(ctx context.Context, uid, profileID string) (*models.Profile, error) {
	snap, err := r.profilesCol(uid).Doc(profileID).Get(ctx)
	if err != nil {
		if errIsNotFound(err) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	var p models.Profile
	if err := snap.DataTo(&p); err != nil {
		return nil, err
	}
	p.ProfileID = snap.Ref.ID
	return &p, nil
}

// Create stores a new profile and returns its document ID.
func (r *ProfileRepo) Create(ctx context.Context, uid string, p *models.Profile) (string, error) {
	ref := r.profilesCol(uid).Doc(p.ProfileID)
	if _, err := ref.Set(ctx, p); err != nil {
		return "", err
	}
	return ref.ID, nil
}

// Update merges the given fields into a profile. Returns ErrNotFound when
// the profile does not exist.
func (r *ProfileRepo) Update(ctx context.Context, uid, profileID string, fields map[string]any) error {
	ref := r.profilesCol(uid).Doc(profileID)
	updates := make([]firestore.Update, 0, len(fields))
	for k, v := range fields {
		updates = append(updates, firestore.Update{Path: k, Value: v})
	}
	_, err := ref.Update(ctx, updates)
	if err != nil && errIsNotFound(err) {
		return ErrNotFound
	}
	return err
}

// Delete removes a profile. Returns ErrNotFound when missing.
func (r *ProfileRepo) Delete(ctx context.Context, uid, profileID string) error {
	ref := r.profilesCol(uid).Doc(profileID)
	_, err := ref.Delete(ctx)
	if err != nil && errIsNotFound(err) {
		return ErrNotFound
	}
	return err
}
