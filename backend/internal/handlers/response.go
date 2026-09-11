package handlers

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"strconv"
)

type errorBody struct {
	Error string `json:"error"`
}

func writeJSON(w http.ResponseWriter, status int, data any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(data)
}

func writeError(w http.ResponseWriter, status int, msg string, logger *slog.Logger, err error) {
	if logger != nil && err != nil {
		logger.Error("request failed", "status", status, "msg", msg, "err", err)
	}
	writeJSON(w, status, errorBody{Error: msg})
}

func decodeJSON(r *http.Request, dst any) error {
	dec := json.NewDecoder(r.Body)
	return dec.Decode(dst)
}

// parseIntDefault parses a positive integer query param, falling back to def.
func parseIntDefault(r *http.Request, key string, def int) int {
	raw := r.URL.Query().Get(key)
	if raw == "" {
		return def
	}
	n, err := strconv.Atoi(raw)
	if err != nil || n <= 0 {
		return def
	}
	return n
}
