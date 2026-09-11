package handlers

import (
	"errors"
	"log/slog"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/middleware"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/service"
)

// mediaParams holds validated media-path parameters.
type mediaParams struct {
	profileID string
	mediaType models.MediaType
	mediaID   int64
}

// parseMediaParams validates profileId/mediaType/mediaId URL params and
// verifies the profile belongs to the caller. Writes the error response and
// returns ok=false when validation fails.
func parseMediaParams(w http.ResponseWriter, r *http.Request, profileSvc *service.ProfileService, logger *slog.Logger) (mediaParams, bool) {
	var p mediaParams
	p.profileID = chi.URLParam(r, "profileId")
	p.mediaType = models.MediaType(chi.URLParam(r, "mediaType"))
	rawID := chi.URLParam(r, "mediaId")

	if p.profileID == "" || !p.mediaType.Valid() {
		writeError(w, http.StatusBadRequest, "invalid profile or mediaType", logger, nil)
		return p, false
	}
	id, err := strconv.ParseInt(rawID, 10, 64)
	if err != nil || id <= 0 {
		writeError(w, http.StatusBadRequest, "invalid mediaId", logger, nil)
		return p, false
	}
	p.mediaID = id

	uid := middleware.UID(r.Context())
	if _, err := profileSvc.Get(r.Context(), uid, p.profileID); err != nil {
		if errors.Is(err, service.ErrProfileNotFound) {
			writeError(w, http.StatusForbidden, "profile not found", logger, nil)
		} else {
			writeError(w, http.StatusInternalServerError, "failed to verify profile", logger, err)
		}
		return p, false
	}
	return p, true
}

// parseProfileParam validates only the profileId param and owner check.
func parseProfileParam(w http.ResponseWriter, r *http.Request, profileSvc *service.ProfileService, logger *slog.Logger) (string, bool) {
	profileID := chi.URLParam(r, "profileId")
	if profileID == "" {
		writeError(w, http.StatusBadRequest, "profileId required", logger, nil)
		return "", false
	}
	uid := middleware.UID(r.Context())
	if _, err := profileSvc.Get(r.Context(), uid, profileID); err != nil {
		if errors.Is(err, service.ErrProfileNotFound) {
			writeError(w, http.StatusForbidden, "profile not found", logger, nil)
		} else {
			writeError(w, http.StatusInternalServerError, "failed to verify profile", logger, err)
		}
		return "", false
	}
	return profileID, true
}
