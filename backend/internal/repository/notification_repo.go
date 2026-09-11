package repository

import (
	"context"

	"cloud.google.com/go/firestore"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
)

// NotificationRepo persists user-facing notifications under
// users/{uid}/notifications.
type NotificationRepo struct {
	db *firestore.Client
}

func NewNotificationRepo(db *firestore.Client) *NotificationRepo {
	return &NotificationRepo{db: db}
}

func (r *NotificationRepo) notifCol(uid string) *firestore.CollectionRef {
	return r.db.Collection("users").Doc(uid).Collection("notifications")
}

// List returns notifications newest-first, limited to n.
func (r *NotificationRepo) List(ctx context.Context, uid string, n int) ([]*models.AppNotification, error) {
	iter := r.notifCol(uid).OrderBy("createdAt", firestore.Desc).Limit(n).Documents(ctx)
	defer iter.Stop()

	out := make([]*models.AppNotification, 0)
	for {
		doc, err := iter.Next()
		if err != nil && errIsIterDone(err) {
			break
		}
		if err != nil {
			return nil, err
		}
		var n models.AppNotification
		if err := doc.DataTo(&n); err != nil {
			return nil, err
		}
		n.NotificationID = doc.Ref.ID
		out = append(out, &n)
	}
	return out, nil
}

// Create stores a new notification. Returns its document ID.
func (r *NotificationRepo) Create(ctx context.Context, uid string, n *models.AppNotification) (string, error) {
	ref := r.notifCol(uid).Doc(n.NotificationID)
	if _, err := ref.Set(ctx, n); err != nil {
		return "", err
	}
	return ref.ID, nil
}

// MarkRead sets isRead on one notification. Returns ErrNotFound when missing.
func (r *NotificationRepo) MarkRead(ctx context.Context, uid, notifID string) error {
	_, err := r.notifCol(uid).Doc(notifID).Update(ctx, []firestore.Update{
		{Path: "isRead", Value: true},
	})
	if err != nil && errIsNotFound(err) {
		return ErrNotFound
	}
	return err
}
