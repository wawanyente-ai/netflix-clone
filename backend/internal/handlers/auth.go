package handlers

import (
	"io"
	"log/slog"
	"net/http"

	fb "github.com/wawanyente-ai/netflix-clone/backend/internal/firebase"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/middleware"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/service"
)

// AuthHandler serves authentication endpoints.
type AuthHandler struct {
	app        *fb.App
	userSvc    *service.UserService
	profileSvc *service.ProfileService
	logger     *slog.Logger
}

func NewAuthHandler(app *fb.App, userSvc *service.UserService, profileSvc *service.ProfileService, logger *slog.Logger) *AuthHandler {
	return &AuthHandler{app: app, userSvc: userSvc, profileSvc: profileSvc, logger: logger}
}

// SignInResponse is the payload returned after successful token verification.
type SignInResponse struct {
	User     *models.User      `json:"user"`
	Profiles []*models.Profile `json:"profiles"`
}

// signInRequest is an optional body. The token itself arrives via the
// `Authorization` header; `idToken` in the body is accepted for compatibility
// with the documented payload but not required.
type signInRequest struct {
	IDToken     string `json:"idToken"`
	DisplayName string `json:"displayName"`
}

// SignIn verifies the Firebase ID token (done by the auth middleware), creates
// the user on first sign-in, and returns the user plus profiles. No second
// token round-trip: claims are read from the request context.
func (h *AuthHandler) SignIn(w http.ResponseWriter, r *http.Request) {
	tok := middleware.VerifiedToken(r.Context())
	if tok == nil {
		writeError(w, http.StatusUnauthorized, "unauthorized", h.logger, nil)
		return
	}

	var req signInRequest
	if r.Body != nil && r.ContentLength > 0 {
		if err := decodeJSON(r, &req); err != nil && err != io.EOF {
			writeError(w, http.StatusBadRequest, "invalid request body", h.logger, err)
			return
		}
	}

	uid := middleware.UID(r.Context())
	user, err := h.userSvc.GetOrCreateUser(r.Context(), tok, req.DisplayName)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to create user", h.logger, err)
		return
	}

	profiles, err := h.profileSvc.List(r.Context(), uid)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to list profiles", h.logger, err)
		return
	}

	writeJSON(w, http.StatusOK, SignInResponse{User: user, Profiles: profiles})
}
