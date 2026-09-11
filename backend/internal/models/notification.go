package models

import "time"

// Device is an FCM-registered client under users/{uid}/devices.
// The Firestore document ID equals the FCM registration token.
type Device struct {
	FCMToken  string    `json:"fcmToken" firestore:"-"`
	Platform  string    `json:"platform" firestore:"platform"` // ios | android | web
	UpdatedAt time.Time `json:"updatedAt" firestore:"updatedAt"`
}

// AppNotification is a user-facing push notification record.
// The Firestore document ID is auto-generated.
type AppNotification struct {
	NotificationID string    `json:"notificationId" firestore:"-"`
	Title          string    `json:"title" firestore:"title"`
	Body           string    `json:"body" firestore:"body"`
	MediaType      string    `json:"mediaType" firestore:"mediaType"`
	MediaID        int64     `json:"mediaId" firestore:"mediaId"`
	IsRead         bool      `json:"isRead" firestore:"isRead"`
	CreatedAt      time.Time `json:"createdAt" firestore:"createdAt"`
}
