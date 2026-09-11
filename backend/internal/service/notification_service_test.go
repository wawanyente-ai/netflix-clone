package service

import (
	"context"
	"errors"
	"testing"

	"firebase.google.com/go/v4/messaging"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/repository"
)

type fakeDeviceStore struct {
	tokens map[string]bool
}

func (f *fakeDeviceStore) Upsert(_ context.Context, _ string, d *models.Device) error {
	f.tokens[d.FCMToken] = true
	return nil
}
func (f *fakeDeviceStore) List(_ context.Context, _ string) ([]string, error) {
	out := make([]string, 0, len(f.tokens))
	for t := range f.tokens {
		out = append(out, t)
	}
	return out, nil
}
func (f *fakeDeviceStore) Remove(_ context.Context, _, token string) error {
	delete(f.tokens, token)
	return nil
}

type fakeNotifStore struct {
	items []*models.AppNotification
}

func (f *fakeNotifStore) List(_ context.Context, _ string, n int) ([]*models.AppNotification, error) {
	if n > len(f.items) {
		n = len(f.items)
	}
	return f.items[:n], nil
}
func (f *fakeNotifStore) Create(_ context.Context, _ string, n *models.AppNotification) (string, error) {
	f.items = append(f.items, n)
	return n.NotificationID, nil
}
func (f *fakeNotifStore) MarkRead(_ context.Context, _, notifID string) error {
	for _, n := range f.items {
		if n.NotificationID == notifID {
			n.IsRead = true
			return nil
		}
	}
	return repository.ErrNotFound
}

type fakeMsg struct {
	got []*messaging.Message
}

func (f *fakeMsg) SendEach(_ context.Context, msgs []*messaging.Message) (*messaging.BatchResponse, error) {
	f.got = append(f.got, msgs...)
	return &messaging.BatchResponse{SuccessCount: len(msgs), FailureCount: 0}, nil
}

func testNotifSvc() (*NotificationService, *fakeDeviceStore, *fakeNotifStore, *fakeMsg) {
	devices := &fakeDeviceStore{tokens: map[string]bool{}}
	store := &fakeNotifStore{}
	msg := &fakeMsg{}
	return NewNotificationService(devices, store, msg, testSvcLogger()), devices, store, msg
}

func TestNotify_RegisterDevice(t *testing.T) {
	svc, devices, _, _ := testNotifSvc()
	err := svc.RegisterDevice(context.Background(), "u1", &models.Device{FCMToken: "tok-1", Platform: "ios"})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !devices.tokens["tok-1"] {
		t.Fatal("expected token stored")
	}
}

func TestNotify_RejectEmptyToken(t *testing.T) {
	svc, _, _, _ := testNotifSvc()
	err := svc.RegisterDevice(context.Background(), "u1", &models.Device{Platform: "ios"})
	if !errors.Is(err, ErrEmptyFCMToken) {
		t.Fatalf("want ErrEmptyFCMToken, got %v", err)
	}
}

func TestNotify_RejectInvalidPlatform(t *testing.T) {
	svc, _, _, _ := testNotifSvc()
	err := svc.RegisterDevice(context.Background(), "u1", &models.Device{FCMToken: "t", Platform: "carrier-pigeon"})
	if !errors.Is(err, ErrInvalidPlatform) {
		t.Fatalf("want ErrInvalidPlatform, got %v", err)
	}
}

func TestNotify_SendPushWithoutDevice(t *testing.T) {
	svc, _, _, _ := testNotifSvc()
	_, err := svc.SendPush(context.Background(), "u1", PushInput{Title: "T", Body: "B"})
	if !errors.Is(err, ErrNoDeviceTokens) {
		t.Fatalf("want ErrNoDeviceTokens, got %v", err)
	}
}

func TestNotify_SendPushDeliversAndPersists(t *testing.T) {
	svc, _, store, msg := testNotifSvc()
	ctx := context.Background()
	_ = svc.RegisterDevice(ctx, "u1", &models.Device{FCMToken: "tok-a", Platform: "ios"})
	_ = svc.RegisterDevice(ctx, "u1", &models.Device{FCMToken: "tok-b", Platform: "ios"})

	success, err := svc.SendPush(ctx, "u1", PushInput{Title: "New Episode", Body: "S5E3", MediaType: models.MediaTypeTV, MediaID: 82856})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if success != 2 {
		t.Fatalf("want 2 deliveries, got %d", success)
	}
	if len(store.items) != 1 {
		t.Fatalf("want 1 inbox record, got %d", len(store.items))
	}
	if store.items[0].Body != "S5E3" || store.items[0].MediaID != 82856 {
		t.Fatalf("unexpected record: %+v", store.items[0])
	}
	if len(msg.got) != 2 {
		t.Fatalf("want 2 FCM messages, got %d", len(msg.got))
	}
	if msg.got[0].Data["mediaId"] != "82856" {
		t.Fatalf("want data mediaId 82856, got %v", msg.got[0].Data["mediaId"])
	}
}

func TestNotify_MarkReadMissing(t *testing.T) {
	svc, _, _, _ := testNotifSvc()
	err := svc.MarkRead(context.Background(), "u1", "nope")
	if !errors.Is(err, ErrNotifNotFound) {
		t.Fatalf("want ErrNotifNotFound, got %v", err)
	}
}
