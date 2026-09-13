package main

import (
	"context"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	fb "github.com/wawanyente-ai/netflix-clone/backend/internal/firebase"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/notify"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/tmdb"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/config"
)

func main() {
	cfg := config.Load()
	logger := newLogger(cfg.LogLevel)
	slog.SetDefault(logger)

	ctx := context.Background()

	app, err := setupFirebase(ctx, cfg, logger)
	if err != nil {
		logger.Error("firebase setup failed", "err", err)
		os.Exit(1)
	}
	defer app.Close()

	// Cron worker mode: invoked by Cloud Scheduler via ROLE=cron.
	if cfg.Role == "cron" {
		runCron(ctx, app, cfg, logger)
		return
	}

	r := newRouter(app, cfg, logger)

	srv := &http.Server{
		Addr:              ":" + cfg.Port,
		Handler:           r,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       15 * time.Second,
		WriteTimeout:      30 * time.Second,
		IdleTimeout:       60 * time.Second,
	}

	go func() {
		logger.Info("server started", "addr", srv.Addr, "env", cfg.Env)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Error("server error", "err", err)
			os.Exit(1)
		}
	}()

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)
	<-stop

	logger.Info("shutting down")
	shutdownCtx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	_ = srv.Shutdown(shutdownCtx)
	logger.Info("server stopped")
}

// runCron executes the weekly "new episodes" notifier and exits.
func runCron(ctx context.Context, app *fb.App, cfg *config.Config, logger *slog.Logger) {
	runCtx, cancel := context.WithTimeout(ctx, 5*time.Minute)
	defer cancel()

	provider := &notify.Providers{
		DB:     app.Firestore(),
		FCM:    app.Messaging(),
		TMDB:   tmdb.New(cfg.TMDBAPIToken),
		Logger: logger,
	}
	summary, err := provider.Run(runCtx)
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

// tmdbClient builds the upstream proxy (nil when no token configured).
func tmdbClient(cfg *config.Config) *tmdb.Client {
	if cfg.TMDBAPIToken == "" {
		return tmdb.New("")
	}
	return tmdb.New(cfg.TMDBAPIToken)
}

func newLogger(level string) *slog.Logger {
	var lvl slog.Level
	switch level {
	case "debug":
		lvl = slog.LevelDebug
	case "warn":
		lvl = slog.LevelWarn
	case "error":
		lvl = slog.LevelError
	default:
		lvl = slog.LevelInfo
	}
	return slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: lvl}))
}

// setupFirebase initializes the Firebase App (Auth + Firestore).
// Without credentials, returns a nil App (auth middleware fails closed).
func setupFirebase(ctx context.Context, cfg *config.Config, logger *slog.Logger) (*fb.App, error) {
	if cfg.FirebaseAccountPath == "" && cfg.GCPProjectID == "" {
		logger.Warn("no Firebase credentials configured; auth middleware disabled")
		return nil, nil
	}
	app, err := fb.New(ctx, cfg.FirebaseAccountPath, cfg.GCPProjectID, logger)
	if err != nil {
		if cfg.AllowUnauthDev {
			logger.Warn("Firebase init failed; continuing with auth disabled (dev only)", "err", err)
			return nil, nil
		}
		return nil, err
	}
	logger.Info("Firebase Auth + Firestore ready")
	return app, nil
}
