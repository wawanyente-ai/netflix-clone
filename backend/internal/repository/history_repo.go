package repository

import (
	"context"
	"time"

	"cloud.google.com/go/firestore"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
)

// HistoryCursor is the opaque pagination token pointing after a specific
// (watchedAt, document key) pair.
type HistoryCursor struct {
	WatchedAt time.Time `json:"watchedAt"`
	Key       string    `json:"key"` // last document ID, tie-break
}

// HistoryRepo persists watch history under
// users/{uid}/profiles/{id}/history.
type HistoryRepo struct {
	db *firestore.Client
}

func NewHistoryRepo(db *firestore.Client) *HistoryRepo {
	return &HistoryRepo{db: db}
}

func (r *HistoryRepo) historyCol(uid, profileID string) *firestore.CollectionRef {
	return r.db.Collection("users").Doc(uid).Collection("profiles").Doc(profileID).Collection("history")
}

// List returns history newest-first. Fetches limit+1 to detect more pages.
// The returned next cursor is non-nil when a subsequent page exists.
func (r *HistoryRepo) List(ctx context.Context, uid, profileID string, limit int, cursor *HistoryCursor) ([]*models.HistoryEntry, *HistoryCursor, error) {
	q := r.historyCol(uid, profileID).
		OrderBy("watchedAt", firestore.Desc).
		OrderBy(firestore.DocumentID, firestore.Desc).
		Limit(limit + 1)
	if cursor != nil {
		q = q.StartAfter(cursor.WatchedAt, cursor.Key)
	}

	iter := q.Documents(ctx)
	defer iter.Stop()

	entries := make([]*models.HistoryEntry, 0)
	docIDs := make([]string, 0)
	stop := false
	for !stop {
		doc, err := iter.Next()
		if err != nil {
			if errIsIterDone(err) {
				break
			}
			return nil, nil, err
		}
		var e models.HistoryEntry
		if err := doc.DataTo(&e); err != nil {
			return nil, nil, err
		}
		entries = append(entries, &e)
		docIDs = append(docIDs, doc.Ref.ID)
		stop = len(entries) > limit
	}

	hasMore := len(entries) > limit
	if hasMore {
		entries = entries[:limit]
		docIDs = docIDs[:limit]
	}

	var next *HistoryCursor
	if hasMore && len(entries) > 0 {
		next = &HistoryCursor{
			WatchedAt: entries[len(entries)-1].WatchedAt,
			Key:       docIDs[len(docIDs)-1],
		}
	}
	return entries, next, nil
}

// Add logs a watch event under an auto-generated document ID.
func (r *HistoryRepo) Add(ctx context.Context, uid, profileID string, entry *models.HistoryEntry) error {
	_, _, err := r.historyCol(uid, profileID).Add(ctx, entry)
	return err
}
