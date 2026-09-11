package models

// Video is a playable catalog entry (open-license demo content).
// The Firestore document ID is the video ID.
type Video struct {
	VideoID     string   `json:"videoId" firestore:"-"`
	Title       string   `json:"title" firestore:"title"`
	Description string   `json:"description" firestore:"description"`
	PosterURL   string   `json:"posterUrl" firestore:"posterUrl"`
	StreamURL   string   `json:"streamUrl" firestore:"streamUrl"`
	Duration    int      `json:"duration" firestore:"duration"` // seconds
	Qualities   []string `json:"qualities" firestore:"qualities"`
	Categories  []string `json:"categories" firestore:"categories"`
}
