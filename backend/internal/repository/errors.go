package repository

import (
	"errors"

	"google.golang.org/api/iterator"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// ErrNotFound is returned when a Firestore document does not exist.
var ErrNotFound = errors.New("not found")

// ErrIterDone is the normal end-of-iteration sentinel.
var ErrIterDone = iterator.Done

// errIsNotFound reports whether a Firestore error means the document is missing.
func errIsNotFound(err error) bool {
	return status.Code(err) == codes.NotFound
}

// errIsIterDone reports whether iteration reached its natural end.
func errIsIterDone(err error) bool {
	return errors.Is(err, iterator.Done)
}
