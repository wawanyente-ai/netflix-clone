package models

import "time"

// Profile is a Netflix-style sub-account under a user (e.g. "Ahmad", "Anak").
// ProfileID is the Firestore document ID.
type Profile struct {
	ProfileID   string    `json:"profileId" firestore:"-"`
	Name        string    `json:"name" firestore:"name"`
	AvatarColor string    `json:"avatarColor" firestore:"avatarColor"` // blue | pink | turquoise | turquoise1
	IsKid       bool      `json:"isKid" firestore:"isKid"`
	CreatedAt   time.Time `json:"createdAt" firestore:"createdAt"`
}
