package models

import "time"

// HistoryEntry logs a watched title. The Firestore document ID is the
// auto-generated timestamp key used for cursor pagination.
type HistoryEntry struct {
	MediaID    int64     `json:"mediaId" firestore:"mediaId"`
	MediaType  string    `json:"mediaType" firestore:"mediaType"`
	Title      string    `json:"title" firestore:"title"`
	PosterPath string    `json:"posterPath" firestore:"posterPath"`
	Completed  bool      `json:"completed" firestore:"completed"`
	WatchedAt  time.Time `json:"watchedAt" firestore:"watchedAt"`
}
