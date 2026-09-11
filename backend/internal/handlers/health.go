package handlers

import (
	"net/http"
	"time"
)

// HealthHandler serves liveness/readiness probes for Cloud Run.
type HealthHandler struct {
	startedAt time.Time
}

func NewHealthHandler() *HealthHandler {
	return &HealthHandler{startedAt: time.Now()}
}

func (h *HealthHandler) Healthz(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]any{
		"status":  "ok",
		"service": "netflix-clone-backend",
		"uptime":  time.Since(h.startedAt).String(),
		"time":    time.Now().UTC().Format(time.RFC3339),
	})
}
