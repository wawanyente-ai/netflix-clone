package handlers

import (
	"errors"
	"log/slog"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/tmdb"
)

// ContentHandler proxies TMDB endpoints server-side, keeping the API token
// out of clients. Responses pass through as raw TMDB JSON.
type ContentHandler struct {
	client *tmdb.Client
	logger *slog.Logger
}

func NewContentHandler(client *tmdb.Client, logger *slog.Logger) *ContentHandler {
	return &ContentHandler{client: client, logger: logger}
}

// proxy forwards a GET to TMDB and writes the raw JSON body.
func (h *ContentHandler) proxy(w http.ResponseWriter, r *http.Request, path string) {
	if !h.client.Enabled() {
		writeError(w, http.StatusServiceUnavailable, "TMDB not configured", h.logger, nil)
		return
	}
	raw, err := h.client.Fetch(r.Context(), path, r.URL.Query())
	if err != nil {
		var sErr *tmdb.StatusError
		if errors.As(err, &sErr) && sErr.HTTPStatus() == http.StatusNotFound {
			writeError(w, http.StatusNotFound, "not found", h.logger, nil)
			return
		}
		writeError(w, http.StatusBadGateway, "TMDB upstream error", h.logger, err)
		return
	}
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(raw)
}

// Trending proxies /trending/all/{week|day}.
func (h *ContentHandler) Trending(w http.ResponseWriter, r *http.Request) {
	window := r.URL.Query().Get("time_window")
	if window != "day" {
		window = "week"
	}
	h.proxy(w, r, "/trending/all/"+window)
}

// Search proxies /search/multi.
func (h *ContentHandler) Search(w http.ResponseWriter, r *http.Request) {
	if r.URL.Query().Get("query") == "" {
		writeError(w, http.StatusBadRequest, "query required", h.logger, nil)
		return
	}
	h.proxy(w, r, "/search/multi")
}

// List proxies a collection endpoint: /movie/popular, /tv/top_rated, etc.
func (h *ContentHandler) List(w http.ResponseWriter, r *http.Request) {
	h.proxy(w, r, "/"+chi.URLParam(r, "kind")+"/"+chi.URLParam(r, "listName"))
}

// Detail proxies /movie/{id} or /tv/{id}.
func (h *ContentHandler) Detail(w http.ResponseWriter, r *http.Request) {
	id, ok := mediaID(w, r)
	if !ok {
		return
	}
	h.proxy(w, r, "/"+chi.URLParam(r, "kind")+"/"+strconv.FormatInt(id, 10))
}

// Videos proxies /movie/{id}/videos or /tv/{id}/videos.
func (h *ContentHandler) Videos(w http.ResponseWriter, r *http.Request) {
	id, ok := mediaID(w, r)
	if !ok {
		return
	}
	h.proxy(w, r, "/"+chi.URLParam(r, "kind")+"/"+strconv.FormatInt(id, 10)+"/videos")
}

// Recommendations proxies /movie/{id}/recommendations or /tv/{id}/recommendations.
func (h *ContentHandler) Recommendations(w http.ResponseWriter, r *http.Request) {
	id, ok := mediaID(w, r)
	if !ok {
		return
	}
	h.proxy(w, r, "/"+chi.URLParam(r, "kind")+"/"+strconv.FormatInt(id, 10)+"/recommendations")
}

// Season proxies /tv/{id}/season/{n}.
func (h *ContentHandler) Season(w http.ResponseWriter, r *http.Request) {
	id, ok := mediaID(w, r)
	if !ok {
		return
	}
	n := chi.URLParam(r, "season")
	if n == "" {
		writeError(w, http.StatusBadRequest, "season required", h.logger, nil)
		return
	}
	h.proxy(w, r, "/"+chi.URLParam(r, "kind")+"/"+strconv.FormatInt(id, 10)+"/season/"+n)
}

// Genres proxies /genre/{movie|tv}/list.
func (h *ContentHandler) Genres(w http.ResponseWriter, r *http.Request) {
	h.proxy(w, r, "/genre/"+chi.URLParam(r, "kind")+"/list")
}

// DiscoverMovie proxies /discover/movie with surface params.
func (h *ContentHandler) DiscoverMovie(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	if g := q.Get("genre"); g != "" {
		q.Set("with_genres", g)
	}
	if s := q.Get("sort"); s != "" {
		q.Set("sort_by", s)
	} else {
		q.Set("sort_by", "popularity.desc")
	}
	h.proxy(w, r, "/discover/movie")
}

// mediaID parses the numeric :id route param.
func mediaID(w http.ResponseWriter, r *http.Request) (int64, bool) {
	raw := chi.URLParam(r, "id")
	id, err := strconv.ParseInt(raw, 10, 64)
	if err != nil || id <= 0 {
		writeError(w, http.StatusBadRequest, "invalid id", nil, nil)
		return 0, false
	}
	return id, true
}
