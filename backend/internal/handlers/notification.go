package handlers

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/middleware"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/service"
)

// NotificationHandler serves device registration and the notification inbox.
type NotificationHandler struct {
	svc    *service.NotificationService
	logger *slog.Logger
}

func NewNotificationHandler(svc *service.NotificationService, logger *slog.Logger) *NotificationHandler {
	return &NotificationHandler{svc: svc, logger: logger}
}

type deviceRegisterRequest struct {
	FCMToken string `json:"fcmToken"`
	Platform string `json:"platform"`
}

// RegisterDevice stores the caller's FCM token.
func (h *NotificationHandler) RegisterDevice(w http.ResponseWriter, r *http.Request) {
	uid := middleware.UID(r.Context())
	var req deviceRegisterRequest
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body", h.logger, err)
		return
	}
	d := &models.Device{FCMToken: req.FCMToken, Platform: req.Platform}
	if err := h.svc.RegisterDevice(r.Context(), uid, d); err != nil {
		switch {
		case errors.Is(err, service.ErrEmptyFCMToken), errors.Is(err, service.ErrInvalidPlatform):
			writeError(w, http.StatusBadRequest, err.Error(), h.logger, nil)
		default:
			writeError(w, http.StatusInternalServerError, "failed to register device", h.logger, err)
		}
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"registered": true})
}

// UnregisterDevice removes a device token (e.g. push disabled).
func (h *NotificationHandler) UnregisterDevice(w http.ResponseWriter, r *http.Request) {
	uid := middleware.UID(r.Context())
	token := chi.URLParam(r, "fcmToken")
	if token == "" {
		writeError(w, http.StatusBadRequest, "fcmToken required", h.logger, nil)
		return
	}
	if err := h.svc.UnregisterDevice(r.Context(), uid, token); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to unregister device", h.logger, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"registered": false})
}

// List returns the notification inbox.
func (h *NotificationHandler) List(w http.ResponseWriter, r *http.Request) {
	uid := middleware.UID(r.Context())
	items, err := h.svc.List(r.Context(), uid, parseIntDefault(r, "limit", 50))
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to list notifications", h.logger, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"notifications": items})
}

// MarkRead flags a notification as read.
func (h *NotificationHandler) MarkRead(w http.ResponseWriter, r *http.Request) {
	uid := middleware.UID(r.Context())
	notifID := chi.URLParam(r, "notificationId")
	if notifID == "" {
		writeError(w, http.StatusBadRequest, "notificationId required", h.logger, nil)
		return
	}
	if err := h.svc.MarkRead(r.Context(), uid, notifID); err != nil {
		if errors.Is(err, service.ErrNotifNotFound) {
			writeError(w, http.StatusNotFound, err.Error(), h.logger, nil)
		} else {
			writeError(w, http.StatusInternalServerError, "failed to mark notification read", h.logger, err)
		}
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"read": true})
}
