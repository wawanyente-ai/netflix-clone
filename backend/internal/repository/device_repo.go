package repository

import (
	"context"

	"cloud.google.com/go/firestore"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
)

// DeviceRepo persists FCM device tokens under users/{uid}/devices.
type DeviceRepo struct {
	db *firestore.Client
}

func NewDeviceRepo(db *firestore.Client) *DeviceRepo {
	return &DeviceRepo{db: db}
}

func (r *DeviceRepo) devicesCol(uid string) *firestore.CollectionRef {
	return r.db.Collection("users").Doc(uid).Collection("devices")
}

// Upsert registers (or refreshes) a device token.
func (r *DeviceRepo) Upsert(ctx context.Context, uid string, d *models.Device) error {
	_, err := r.devicesCol(uid).Doc(d.FCMToken).Set(ctx, d)
	return err
}

// List returns all registered tokens for a user.
func (r *DeviceRepo) List(ctx context.Context, uid string) ([]string, error) {
	iter := r.devicesCol(uid).Documents(ctx)
	defer iter.Stop()

	var tokens []string
	for {
		doc, err := iter.Next()
		if err != nil && errIsIterDone(err) {
			break
		}
		if err != nil {
			return nil, err
		}
		tokens = append(tokens, doc.Ref.ID)
	}
	return tokens, nil
}

// Remove deletes a device token.
func (r *DeviceRepo) Remove(ctx context.Context, uid, token string) error {
	_, err := r.devicesCol(uid).Doc(token).Delete(ctx)
	if err != nil && errIsNotFound(err) {
		return ErrNotFound
	}
	return err
}
