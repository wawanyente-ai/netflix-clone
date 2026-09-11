package handlers

import (
	"errors"
	"log/slog"
	"net/http"
	"strconv"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/middleware"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/service"
)

// HistoryHandler serves watch-history endpoints.
type HistoryHandler struct {
	profileSvc *service.ProfileService
	historySvc *service.HistoryService
	logger     *slog.Logger
}

func NewHistoryHandler(profileSvc *service.ProfileService, historySvc *service.HistoryService, logger *slog.Logger) *HistoryHandler {
	return &HistoryHandler{profileSvc: profileSvc, historySvc: historySvc, logger: logger}
}

type historyBody struct {
	MediaID    int64  `json:"mediaId"`
	MediaType  string `json:"mediaType"`
	Title      string `json:"title"`
	PosterPath string `json:"posterPath"`
	Completed  bool   `json:"completed"`
}

// List returns a page of watch history.
func (h *HistoryHandler) List(w http.ResponseWriter, r *http.Request) {
	profileID, ok := parseProfileParam(w, r, h.profileSvc, h.logger)
	if !ok {
		return
	}
	limit := parseHistoryLimit(r)
	cursor, err := decodeCursor(r.URL.Query().Get("cursor"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid cursor", h.logger, nil)
		return
	}

	items, next, err := h.historySvc.List(r.Context(), middleware.UID(r.Context()), profileID, limit, cursor)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to list history", h.logger, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"items":      items,
		"nextCursor": encodeCursor(next),
	})
}

// Log appends a watch event.
func (h *HistoryHandler) Log(w http.ResponseWriter, r *http.Request) {
	profileID, ok := parseProfileParam(w, r, h.profileSvc, h.logger)
	if !ok {
		return
	}
	var body historyBody
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body", h.logger, err)
		return
	}

	err := h.historySvc.Log(r.Context(), middleware.UID(r.Context()), profileID,
		models.MediaType(body.MediaType), body.MediaID, body.Title, body.PosterPath, body.Completed)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrInvalidMediaType), errors.Is(err, service.ErrInvalidMediaID):
			writeError(w, http.StatusBadRequest, err.Error(), h.logger, nil)
		default:
			writeError(w, http.StatusInternalServerError, "failed to log history", h.logger, err)
		}
		return
	}
	writeJSON(w, http.StatusCreated, map[string]any{"logged": true})
}

func parseHistoryLimit(r *http.Request) int {
	raw := r.URL.Query().Get("limit")
	if raw == "" {
		return service.DefaultHistoryPageSize
	}
	n, err := strconv.Atoi(raw)
	if err != nil || n <= 0 {
		return service.DefaultHistoryPageSize
	}
	return n
}
