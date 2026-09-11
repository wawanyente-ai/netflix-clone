package handlers

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/middleware"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/service"
)

// ProgressHandler serves continue-watching endpoints.
type ProgressHandler struct {
	profileSvc  *service.ProfileService
	progressSvc *service.ProgressService
	logger      *slog.Logger
}

func NewProgressHandler(profileSvc *service.ProfileService, progressSvc *service.ProgressService, logger *slog.Logger) *ProgressHandler {
	return &ProgressHandler{profileSvc: profileSvc, progressSvc: progressSvc, logger: logger}
}

type progressBody struct {
	Position   *float64 `json:"position"`
	Duration   *float64 `json:"duration"`
	Title      string   `json:"title"`
	PosterPath string   `json:"posterPath"`
}

// List returns the profile's in-progress titles.
func (h *ProgressHandler) List(w http.ResponseWriter, r *http.Request) {
	profileID, ok := parseProfileParam(w, r, h.profileSvc, h.logger)
	if !ok {
		return
	}
	items, err := h.progressSvc.List(r.Context(), middleware.UID(r.Context()), profileID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to list progress", h.logger, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

// Save upserts playback position.
func (h *ProgressHandler) Save(w http.ResponseWriter, r *http.Request) {
	profileID, ok := parseProfileParam(w, r, h.profileSvc, h.logger)
	if !ok {
		return
	}

	var body progressBody
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body", h.logger, err)
		return
	}
	if body.Position == nil || body.Duration == nil {
		writeError(w, http.StatusBadRequest, "position and duration required", h.logger, nil)
		return
	}

	mediaType, mediaID, ok := parseProgressParams(w, r, h.profileSvc, h.logger)
	if !ok {
		return
	}
	updated, err := h.progressSvc.Save(r.Context(), middleware.UID(r.Context()), profileID, mediaType, mediaID,
		service.ProgressInput{
			Position:   *body.Position,
			Duration:   *body.Duration,
			Title:      body.Title,
			PosterPath: body.PosterPath,
		})
	if err != nil {
		switch {
		case errors.Is(err, service.ErrInvalidProgress), errors.Is(err, service.ErrInvalidMediaType):
			writeError(w, http.StatusBadRequest, err.Error(), h.logger, nil)
		default:
			writeError(w, http.StatusInternalServerError, "failed to save progress", h.logger, err)
		}
		return
	}
	writeJSON(w, http.StatusOK, updated)
}

// Remove clears progress (title finished or discarded).
func (h *ProgressHandler) Remove(w http.ResponseWriter, r *http.Request) {
	profileID, ok := parseProfileParam(w, r, h.profileSvc, h.logger)
	if !ok {
		return
	}
	mediaType, mediaID, ok := parseProgressParams(w, r, h.profileSvc, h.logger)
	if !ok {
		return
	}
	if err := h.progressSvc.Remove(r.Context(), middleware.UID(r.Context()), profileID, mediaType, mediaID); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to remove progress", h.logger, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"removed": true})
}

// parseProgressParams extracts media params for progress routes (validate
// through the shared helper to reuse profile ownership checks).
func parseProgressParams(w http.ResponseWriter, r *http.Request, profileSvc *service.ProfileService, logger *slog.Logger) (models.MediaType, int64, bool) {
	p, ok := parseMediaParams(w, r, profileSvc, logger)
	if !ok {
		return "", 0, false
	}
	return p.mediaType, p.mediaID, true
}
