package models

import (
	"strconv"
	"time"
)

// MediaType identifies whether a title is a movie or a TV show.
type MediaType string

const (
	MediaTypeMovie MediaType = "movie"
	MediaTypeTV    MediaType = "tv"
)

// Valid reports whether the media type is supported.
func (m MediaType) Valid() bool {
	return m == MediaTypeMovie || m == MediaTypeTV
}

// WatchlistItem is a saved title. The Firestore document ID equals
// the composite key "mediaType:mediaId" (see MediaKey).
type WatchlistItem struct {
	MediaID    int64     `json:"mediaId" firestore:"mediaId"`
	MediaType  string    `json:"mediaType" firestore:"mediaType"`
	Title      string    `json:"title" firestore:"title"`
	PosterPath string    `json:"posterPath" firestore:"posterPath"`
	AddedAt    time.Time `json:"addedAt" firestore:"addedAt"`
}

// MediaKey builds the composite document key "movie:123".
func MediaKey(mediaType MediaType, mediaID int64) string {
	return string(mediaType) + ":" + strconv.FormatInt(mediaID, 10)
}

// WatchProgress tracks playback position for continue-watching.
// The Firestore document ID equals the composite MediaKey.
type WatchProgress struct {
	MediaID     int64     `json:"mediaId" firestore:"mediaId"`
	MediaType   string    `json:"mediaType" firestore:"mediaType"`
	Title       string    `json:"title" firestore:"title"`
	PosterPath  string    `json:"posterPath" firestore:"posterPath"`
	Position    float64   `json:"position" firestore:"position"`     // seconds
	Duration    float64   `json:"duration" firestore:"duration"`     // seconds
	Completion  float64   `json:"completion" firestore:"completion"` // 0..1
	UpdatedAt   time.Time `json:"updatedAt" firestore:"updatedAt"`
}
