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

// ProfileHandler serves profile CRUD.
type ProfileHandler struct {
	service *service.ProfileService
	logger  *slog.Logger
}

func NewProfileHandler(svc *service.ProfileService, logger *slog.Logger) *ProfileHandler {
	return &ProfileHandler{service: svc, logger: logger}
}

type createProfileRequest struct {
	Name        string `json:"name"`
	AvatarColor string `json:"avatarColor"`
	IsKid       bool   `json:"isKid"`
}

type updateProfileRequest struct {
	Name        *string `json:"name"`
	AvatarColor *string `json:"avatarColor"`
	IsKid       *bool   `json:"isKid"`
}

// List returns the caller's profiles.
func (h *ProfileHandler) List(w http.ResponseWriter, r *http.Request) {
	uid := middleware.UID(r.Context())
	profiles, err := h.service.List(r.Context(), uid)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to list profiles", h.logger, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"profiles": profiles})
}

// Create adds a new profile.
func (h *ProfileHandler) Create(w http.ResponseWriter, r *http.Request) {
	var req createProfileRequest
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body", h.logger, err)
		return
	}

	p := &models.Profile{Name: req.Name, AvatarColor: req.AvatarColor, IsKid: req.IsKid}
	created, err := h.service.Create(r.Context(), middleware.UID(r.Context()), p)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrInvalidName), errors.Is(err, service.ErrInvalidAvatar):
			writeError(w, http.StatusBadRequest, err.Error(), h.logger, nil)
		case errors.Is(err, service.ErrProfileLimit):
			writeError(w, http.StatusConflict, err.Error(), h.logger, nil)
		default:
			writeError(w, http.StatusInternalServerError, "failed to create profile", h.logger, err)
		}
		return
	}
	writeJSON(w, http.StatusCreated, created)
}

// Update applies partial changes to a profile.
func (h *ProfileHandler) Update(w http.ResponseWriter, r *http.Request) {
	profileID := chi.URLParam(r, "profileId")
	if profileID == "" {
		writeError(w, http.StatusBadRequest, "profileId required", h.logger, nil)
		return
	}

	var req updateProfileRequest
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body", h.logger, err)
		return
	}

	fields := map[string]any{}
	if req.Name != nil {
		fields["name"] = *req.Name
	}
	if req.AvatarColor != nil {
		fields["avatarColor"] = *req.AvatarColor
	}
	if req.IsKid != nil {
		fields["isKid"] = *req.IsKid
	}
	if len(fields) == 0 {
		writeError(w, http.StatusBadRequest, "no fields to update", h.logger, nil)
		return
	}

	err := h.service.Update(r.Context(), middleware.UID(r.Context()), profileID, fields)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrInvalidName), errors.Is(err, service.ErrInvalidAvatar):
			writeError(w, http.StatusBadRequest, err.Error(), h.logger, nil)
		case errors.Is(err, service.ErrProfileNotFound):
			writeError(w, http.StatusNotFound, err.Error(), h.logger, nil)
		default:
			writeError(w, http.StatusInternalServerError, "failed to update profile", h.logger, err)
		}
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"updated": true})
}

// Delete removes a profile.
func (h *ProfileHandler) Delete(w http.ResponseWriter, r *http.Request) {
	profileID := chi.URLParam(r, "profileId")
	if profileID == "" {
		writeError(w, http.StatusBadRequest, "profileId required", h.logger, nil)
		return
	}
	err := h.service.Delete(r.Context(), middleware.UID(r.Context()), profileID)
	if err != nil {
		if errors.Is(err, service.ErrProfileNotFound) {
			writeError(w, http.StatusNotFound, err.Error(), h.logger, nil)
		} else {
			writeError(w, http.StatusInternalServerError, "failed to delete profile", h.logger, err)
		}
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"deleted": true})
}
