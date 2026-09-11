package handlers

import (
	"log/slog"
	"net/http"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/middleware"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/service"
)

// WatchlistHandler serves saved-title endpoints.
type WatchlistHandler struct {
	profileSvc   *service.ProfileService
	watchlistSvc *service.WatchlistService
	logger       *slog.Logger
}

func NewWatchlistHandler(profileSvc *service.ProfileService, watchlistSvc *service.WatchlistService, logger *slog.Logger) *WatchlistHandler {
	return &WatchlistHandler{profileSvc: profileSvc, watchlistSvc: watchlistSvc, logger: logger}
}

type watchlistBody struct {
	Title      string `json:"title"`
	PosterPath string `json:"posterPath"`
}

// List returns the profile's saved titles.
func (h *WatchlistHandler) List(w http.ResponseWriter, r *http.Request) {
	profileID, ok := parseProfileParam(w, r, h.profileSvc, h.logger)
	if !ok {
		return
	}
	items, err := h.watchlistSvc.List(r.Context(), middleware.UID(r.Context()), profileID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to list watchlist", h.logger, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

// Add saves a title.
func (h *WatchlistHandler) Add(w http.ResponseWriter, r *http.Request) {
	p, ok := parseMediaParams(w, r, h.profileSvc, h.logger)
	if !ok {
		return
	}
	var body watchlistBody
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body", h.logger, err)
		return
	}
	err := h.watchlistSvc.Save(r.Context(), middleware.UID(r.Context()), p.profileID, p.mediaType, p.mediaID,
		service.WatchlistInput{Title: body.Title, PosterPath: body.PosterPath})
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to save title", h.logger, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"saved": true})
}

// Remove unsaves a title.
func (h *WatchlistHandler) Remove(w http.ResponseWriter, r *http.Request) {
	p, ok := parseMediaParams(w, r, h.profileSvc, h.logger)
	if !ok {
		return
	}
	err := h.watchlistSvc.Remove(r.Context(), middleware.UID(r.Context()), p.profileID, p.mediaType, p.mediaID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to remove title", h.logger, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"saved": false})
}

// Toggle flips saved state and reports the result.
func (h *WatchlistHandler) Toggle(w http.ResponseWriter, r *http.Request) {
	p, ok := parseMediaParams(w, r, h.profileSvc, h.logger)
	if !ok {
		return
	}
	var body watchlistBody
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body", h.logger, err)
		return
	}
	saved, err := h.watchlistSvc.Toggle(r.Context(), middleware.UID(r.Context()), p.profileID, p.mediaType, p.mediaID,
		service.WatchlistInput{Title: body.Title, PosterPath: body.PosterPath})
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to toggle title", h.logger, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"saved": saved})
}
