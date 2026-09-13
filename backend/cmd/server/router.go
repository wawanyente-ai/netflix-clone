package main

import (
	"log/slog"
	"net/http"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/config"
	fb "github.com/wawanyente-ai/netflix-clone/backend/internal/firebase"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/handlers"
	mymw "github.com/wawanyente-ai/netflix-clone/backend/internal/middleware"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/repository"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/service"

	"github.com/go-chi/chi/v5"
	chimw "github.com/go-chi/chi/v5/middleware"
)

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
