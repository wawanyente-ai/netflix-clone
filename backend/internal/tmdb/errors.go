package tmdb

import (
	"errors"
	"fmt"
)

// ErrNotConfigured means no TMDB token was provided.
var ErrNotConfigured = errors.New("TMDB not configured on server")

// StatusError carries an unexpected upstream TMDB response.
type StatusError struct {
	Status int
	Body   string
}

func (e *StatusError) Error() string {
	return fmt.Sprintf("tmdb upstream %d: %s", e.Status, e.Body)
}

// HTTPStatus reports the upstream status (for client mapping).
func (e *StatusError) HTTPStatus() int {
	return e.Status
}
