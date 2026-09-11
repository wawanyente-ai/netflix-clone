// Command notifier is the Cloud Scheduler cron job. It scans every user's
// watchlist for TV titles, asks TMDB whether a newer episode has aired since
// the last notification, and sends FCM pushes when it has.
//
// Deploy: same image, separate Cloud Run service with ROLE=cron, triggered by
// Cloud Scheduler (weekly).
package main

import (
	"context"
	"flag"
	"log/slog"
	"os"
	"time"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/firebase"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/notify"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/tmdb"
)

func main() {
	accountPath := flag.String("service-account", os.Getenv("FIREBASE_SERVICE_ACCOUNT_PATH"), "path to service account JSON")
	projectID := flag.String("project", os.Getenv("GCP_PROJECT_ID"), "Firebase project ID")
	tmdbToken := flag.String("tmdb-token", os.Getenv("TMDB_ACCESS_TOKEN"), "TMDB v3 token")
	flag.Parse()

	logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()

	app, err := firebase.New(ctx, *accountPath, *projectID, logger)
	if err != nil {
		logger.Error("firebase init failed", "err", err)
		os.Exit(1)
	}
	defer app.Close()

	provider := &notify.Providers{
		DB:     app.Firestore(),
		FCM:    app.Messaging(),
		TMDB:   tmdb.New(*tmdbToken),
		Logger: logger,
	}
	summary, err := provider.Run(ctx)
	if err != nil {
		logger.Error("cron failed", "err", err)
		os.Exit(1)
	}
	logger.Info("cron complete",
		"users", summary.Users,
		"titles_checked", summary.Checked,
		"notifications_sent", summary.Sent,
	)
}
