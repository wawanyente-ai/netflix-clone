// Package tmdb is a thin client for the TMDB v3 API. It exists so the access
// token never ships inside the iOS app; content flows through this proxy.
package tmdb

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"time"
)

// BaseURL is the TMDB v3 root.
const BaseURL = "https://api.themoviedb.org/3"

// Client talks to TMDB with bearer auth.
type Client struct {
	token   string
	baseURL string
	http    *http.Client
}

// New builds a client. An empty token yields an unusable client (handlers
// must check Enabled).
func New(token string) *Client {
	return &Client{
		token:   token,
		baseURL: BaseURL,
		http: &http.Client{
			Timeout: 15 * time.Second,
		},
	}
}

// Enabled reports whether a token is configured.
func (c *Client) Enabled() bool { return c != nil && c.token != "" }

// Fetch performs a GET against the given TMDB path and returns the raw JSON
// body, so DTO shape changes upstream never break the proxy.
func (c *Client) Fetch(ctx context.Context, path string, query url.Values) (json.RawMessage, error) {
	if !c.Enabled() {
		return nil, ErrNotConfigured
	}
	u := c.baseURL + path
	if len(query) > 0 {
		u += "?" + query.Encode()
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+c.token)
	req.Header.Set("Accept", "application/json")

	resp, err := c.http.Do(req)
	if err != nil {
		return nil, fmt.Errorf("tmdb request: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(io.LimitReader(resp.Body, 8<<20))
	if err != nil {
		return nil, err
	}
	if resp.StatusCode != http.StatusOK {
		return nil, &StatusError{Status: resp.StatusCode, Body: truncate(string(body))}
	}
	return json.RawMessage(body), nil
}

func truncate(s string) string {
	if len(s) > 200 {
		return s[:200]
	}
	return s
}
