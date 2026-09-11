package main

import (
	"context"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/go-chi/chi/v5"
	chimw "github.com/go-chi/chi/v5/middleware"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/config"
	fb "github.com/wawanyente-ai/netflix-clone/backend/internal/firebase"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/handlers"
	mymw "github.com/wawanyente-ai/netflix-clone/backend/internal/middleware"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/notify"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/repository"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/service"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/tmdb"
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

// newRouter assembles the full route table. Handlers are built only when the
// Firebase app is available; with nil app, protected routes fail closed.
func newRouter(app *fb.App, cfg *config.Config, logger *slog.Logger) http.Handler {
	r := chi.NewRouter()
	r.Use(chimw.RequestID)
	r.Use(mymw.Recovery(logger))
	r.Use(mymw.Logging(logger))
	r.Use(mymw.CORS(cfg.CORSAllowedOrigins))

	health := handlers.NewHealthHandler()
	r.Get("/healthz", health.Healthz)
	r.Get("/v1/healthz", health.Healthz)

	r.Group(func(pr chi.Router) {
		pr.Use(mymw.Authenticate(app, cfg.AllowUnauthDev, logger))

		if app == nil {
			return
		}

		db := app.Firestore()
		userRepo := repository.NewUserRepo(db)
		profileRepo := repository.NewProfileRepo(db)
		watchlistRepo := repository.NewWatchlistRepo(db)
		progressRepo := repository.NewProgressRepo(db)
		historyRepo := repository.NewHistoryRepo(db)
		deviceRepo := repository.NewDeviceRepo(db)
		notifRepo := repository.NewNotificationRepo(db)
		videoRepo := repository.NewVideoRepo(db)

		userSvc := service.NewUserService(userRepo, logger)
		profileSvc := service.NewProfileService(profileRepo, logger)
		watchlistSvc := service.NewWatchlistService(watchlistRepo, logger)
		progressSvc := service.NewProgressService(progressRepo, logger)
		historySvc := service.NewHistoryService(historyRepo, logger)
		notifSvc := service.NewNotificationService(deviceRepo, notifRepo, app.Messaging(), logger)

		authH := handlers.NewAuthHandler(app, userSvc, profileSvc, logger)
		profileH := handlers.NewProfileHandler(profileSvc, logger)
		watchlistH := handlers.NewWatchlistHandler(profileSvc, watchlistSvc, logger)
		progressH := handlers.NewProgressHandler(profileSvc, progressSvc, logger)
		historyH := handlers.NewHistoryHandler(profileSvc, historySvc, logger)
		notifH := handlers.NewNotificationHandler(notifSvc, logger)
		contentH := handlers.NewContentHandler(tmdbClient(cfg), logger)
		videoH := handlers.NewVideoHandler(videoRepo, logger)

		// Auth
		pr.Post("/v1/auth/signin", authH.SignIn)

		// Profiles
		pr.Get("/v1/profiles", profileH.List)
		pr.Post("/v1/profiles", profileH.Create)
		pr.Patch("/v1/profiles/{profileId}", profileH.Update)
		pr.Delete("/v1/profiles/{profileId}", profileH.Delete)

		// My List
		pr.Get("/v1/profiles/{profileId}/mylist", watchlistH.List)
		pr.Post("/v1/profiles/{profileId}/mylist/{mediaType}/{mediaId}", watchlistH.Add)
		pr.Put("/v1/profiles/{profileId}/mylist/{mediaType}/{mediaId}", watchlistH.Toggle)
		pr.Delete("/v1/profiles/{profileId}/mylist/{mediaType}/{mediaId}", watchlistH.Remove)

		// Continue Watching
		pr.Get("/v1/profiles/{profileId}/progress", progressH.List)
		pr.Put("/v1/profiles/{profileId}/progress/{mediaType}/{mediaId}", progressH.Save)
		pr.Delete("/v1/profiles/{profileId}/progress/{mediaType}/{mediaId}", progressH.Remove)

		// Watch History
		pr.Get("/v1/profiles/{profileId}/history", historyH.List)
		pr.Post("/v1/profiles/{profileId}/history", historyH.Log)

		// Notifications
		pr.Post("/v1/notifications/device/register", notifH.RegisterDevice)
		pr.Delete("/v1/notifications/device/{fcmToken}", notifH.UnregisterDevice)
		pr.Get("/v1/notifications", notifH.List)
		pr.Patch("/v1/notifications/{notificationId}/read", notifH.MarkRead)

		// Content (TMDB proxy) — protected to limit abuse.
		pr.Get("/v1/content/trending", contentH.Trending)
		pr.Get("/v1/content/search", contentH.Search)
		pr.Get("/v1/content/genres/{kind}", contentH.Genres)
		pr.Get("/v1/content/{kind}/list/{listName}", contentH.List)
		pr.Get("/v1/content/{kind}/data/{id}", contentH.Detail)
		pr.Get("/v1/content/{kind}/data/{id}/videos", contentH.Videos)
		pr.Get("/v1/content/{kind}/data/{id}/recommendations", contentH.Recommendations)
		pr.Get("/v1/content/{kind}/data/{id}/season/{season}", contentH.Season)
		pr.Get("/v1/content/discover", contentH.DiscoverMovie)

		// Stream catalog
		pr.Get("/v1/videos", videoH.List)
		pr.Get("/v1/videos/{videoId}", videoH.Get)
	})

	return r
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
