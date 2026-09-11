package models

import "time"

// User is a Netflix clone account (Firebase Auth user).
// UID is the Firestore document ID, not a stored field.
type User struct {
	UID         string    `json:"uid" firestore:"-"`
	Email       string    `json:"email" firestore:"email"`
	DisplayName string    `json:"displayName" firestore:"displayName"`
	Provider    string    `json:"provider" firestore:"provider"` // google.com | apple.com
	CreatedAt   time.Time `json:"createdAt" firestore:"createdAt"`
}
