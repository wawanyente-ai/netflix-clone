package middleware

import (
	"context"

	"firebase.google.com/go/v4/auth"
)

// TokenVerifier validates Firebase ID tokens. Implemented by the Firebase
// App wrapper and fakes in tests.
type TokenVerifier interface {
	// VerifyIDToken returns the token claims or an error when invalid.
	VerifyIDToken(ctx context.Context, idToken string) (*auth.Token, error)
	// Enabled reports whether token verification is available.
	Enabled() bool
}
