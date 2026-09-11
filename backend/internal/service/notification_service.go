package service

import (
	"context"
	"errors"
	"log/slog"
	"time"

	"firebase.google.com/go/v4/messaging"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/repository"
)

// Notification errors.
var (
	ErrInvalidPlatform = errors.New("platform must be ios, android, or web")
	ErrNotifNotFound   = errors.New("notification not found")
	ErrEmptyFCMToken   = errors.New("fcmToken required")
	ErrNoDeviceTokens  = errors.New("no devices registered")
)

// Valid push platforms.
var validPlatforms = map[string]bool{"ios": true, "android": true, "web": true}

// PushInput is the content of a notification plus optional deep-link data.
type PushInput struct {
	Title     string
	Body      string
	MediaType models.MediaType
	MediaID   int64
}

// DeviceStore abstracts FCM token persistence.
type DeviceStore interface {
	Upsert(ctx context.Context, uid string, d *models.Device) error
	List(ctx context.Context, uid string) ([]string, error)
	Remove(ctx context.Context, uid, token string) error
}

// NotificationStore abstracts notification persistence.
type NotificationStore interface {
	List(ctx context.Context, uid string, n int) ([]*models.AppNotification, error)
	Create(ctx context.Context, uid string, n *models.AppNotification) (string, error)
	MarkRead(ctx context.Context, uid, notifID string) error
}

// MessagingClient sends FCM pushes.
type MessagingClient interface {
	SendEach(ctx context.Context, msgs []*messaging.Message) (*messaging.BatchResponse, error)
}

// NotificationService handles device registration, notification inbox, and
// push dispatch.
type NotificationService struct {
	devices  DeviceStore
	store    NotificationStore
	msg      MessagingClient
	logger   *slog.Logger
	maxInbox int
}

func NewNotificationService(devices DeviceStore, store NotificationStore, msg MessagingClient, logger *slog.Logger) *NotificationService {
	return &NotificationService{
		devices:  devices,
		store:    store,
		msg:      msg,
		logger:   logger,
		maxInbox: 50,
	}
}

// RegisterDevice upserts an FCM token.
func (s *NotificationService) RegisterDevice(ctx context.Context, uid string, d *models.Device) error {
	if d.FCMToken == "" {
		return ErrEmptyFCMToken
	}
	if !validPlatforms[d.Platform] {
		return ErrInvalidPlatform
	}
	d.UpdatedAt = time.Now().UTC()
	return s.devices.Upsert(ctx, uid, d)
}

// UnregisterDevice removes an FCM token.
func (s *NotificationService) UnregisterDevice(ctx context.Context, uid, token string) error {
	return s.devices.Remove(ctx, uid, token)
}

// List returns the notification inbox (newest first).
func (s *NotificationService) List(ctx context.Context, uid string, limit int) ([]*models.AppNotification, error) {
	if limit <= 0 || limit > s.maxInbox {
		limit = s.maxInbox
	}
	return s.store.List(ctx, uid, limit)
}

// MarkRead flags one notification as read.
func (s *NotificationService) MarkRead(ctx context.Context, uid, notifID string) error {
	err := s.store.MarkRead(ctx, uid, notifID)
	if errors.Is(err, repository.ErrNotFound) {
		return ErrNotifNotFound
	}
	return err
}

// Create stores a notification record.
func (s *NotificationService) Create(ctx context.Context, uid string, n *models.AppNotification) (string, error) {
	return s.store.Create(ctx, uid, n)
}

// SendPush delivers a notification to every device of a user via FCM and
// persists it to the inbox.
func (s *NotificationService) SendPush(ctx context.Context, uid string, in PushInput) (int, error) {
	tokens, err := s.devices.List(ctx, uid)
	if err != nil {
		return 0, err
	}
	if len(tokens) == 0 {
		return 0, ErrNoDeviceTokens
	}

	// Persist inbox record (avoid storing token in it).
	if !in.MediaType.Valid() {
		in.MediaType = models.MediaTypeMovie
	}
	notif := &models.AppNotification{
		NotificationID: newNotifID(),
		Title:          in.Title,
		Body:           in.Body,
		MediaType:      string(in.MediaType),
		MediaID:        in.MediaID,
		CreatedAt:      time.Now().UTC(),
	}
	if _, err := s.store.Create(ctx, uid, notif); err != nil {
		return 0, err
	}

	msgs := make([]*messaging.Message, 0, len(tokens))
	for _, token := range tokens {
		msgs = append(msgs, &messaging.Message{
			Token: token,
			Notification: &messaging.Notification{
				Title: in.Title,
				Body:  in.Body,
			},
			Data: map[string]string{
				"mediaType": string(in.MediaType),
				"mediaId":   intJoin(in.MediaID),
			},
		})
	}

	if s.msg == nil {
		s.logger.Warn("FCM client unavailable; notification recorded only", "uid", uid)
		return 0, nil
	}
	resp, err := s.msg.SendEach(ctx, msgs)
	if err != nil {
		return 0, err
	}
	if resp.FailureCount > 0 {
		s.logger.Warn("some FCM messages failed",
			"uid", uid, "success", resp.SuccessCount, "failure", resp.FailureCount)
	}
	return resp.SuccessCount, nil
}
