package handlers

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/repository"
)

// VideoHandler serves the streaming catalog.
type VideoHandler struct {
	repo   *repository.VideoRepo
	logger *slog.Logger
}

func NewVideoHandler(repo *repository.VideoRepo, logger *slog.Logger) *VideoHandler {
	return &VideoHandler{repo: repo, logger: logger}
}

// List returns all playable videos.
func (h *VideoHandler) List(w http.ResponseWriter, r *http.Request) {
	videos, err := h.repo.List(r.Context())
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to list videos", h.logger, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"videos": videos})
}

// Get returns a single video.
func (h *VideoHandler) Get(w http.ResponseWriter, r *http.Request) {
	videoID := chi.URLParam(r, "videoId")
	if videoID == "" {
		writeError(w, http.StatusBadRequest, "videoId required", h.logger, nil)
		return
	}
	v, err := h.repo.Get(r.Context(), videoID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			writeError(w, http.StatusNotFound, "video not found", h.logger, nil)
		} else {
			writeError(w, http.StatusInternalServerError, "failed to load video", h.logger, err)
		}
		return
	}
	writeJSON(w, http.StatusOK, v)
}
