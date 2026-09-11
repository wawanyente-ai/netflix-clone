// Package firebase wraps the Firebase Admin SDK and exposes Auth, Firestore,
// and FCM clients from a single App instance.
package firebase

import (
	"context"
	"log/slog"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

// App bundles the Firebase Auth verifier, Firestore database, and FCM client.
type App struct {
	authClient *auth.Client
	db         *firestore.Client
	fcm        *messaging.Client
	logger     *slog.Logger
}

// New initializes a Firebase App. accountPath may be empty to use
// Application Default Credentials. Returns nil App when no credentials are
// configured (callers must handle the disabled state).
func New(ctx context.Context, accountPath, projectID string, logger *slog.Logger) (*App, error) {
	var opts []option.ClientOption
	if accountPath != "" {
		opts = append(opts, option.WithCredentialsFile(accountPath))
	}
	app, err := firebase.NewApp(ctx, &firebase.Config{ProjectID: projectID}, opts...)
	if err != nil {
		return nil, err
	}
	authClient, err := app.Auth(ctx)
	if err != nil {
		return nil, err
	}
	db, err := app.Firestore(ctx)
	if err != nil {
		return nil, err
	}
	fcm, err := app.Messaging(ctx)
	if err != nil {
		return nil, err
	}
	return &App{authClient: authClient, db: db, fcm: fcm, logger: logger}, nil
}

// VerifyIDToken validates a Firebase ID token and returns its claims.
func (a *App) VerifyIDToken(ctx context.Context, idToken string) (*auth.Token, error) {
	return a.authClient.VerifyIDToken(ctx, idToken)
}

// Enabled always true: a nonnil App has working clients.
func (a *App) Enabled() bool { return true }

// Firestore returns the database client.
func (a *App) Firestore() *firestore.Client { return a.db }

// Messaging returns the FCM client.
func (a *App) Messaging() *messaging.Client { return a.fcm }

// Close releases Firestore client resources.
func (a *App) Close() error {
	if a != nil && a.db != nil {
		return a.db.Close()
	}
	return nil
}
