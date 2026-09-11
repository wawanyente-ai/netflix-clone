// Command seed writes the open-license streaming catalog into Firestore
// (content/catalog/videos). Run once after deploying rules:
//
//	go run ./cmd/seed
package main

import (
	"context"
	"flag"
	"log/slog"
	"os"

	fb "github.com/wawanyente-ai/netflix-clone/backend/internal/firebase"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/repository"
)

func main() {
	accountPath := flag.String("service-account", os.Getenv("FIREBASE_SERVICE_ACCOUNT_PATH"), "path to service account JSON")
	projectID := flag.String("project", os.Getenv("GCP_PROJECT_ID"), "Firebase project ID")
	flag.Parse()

	logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
	ctx := context.Background()

	app, err := fb.New(ctx, *accountPath, *projectID, logger)
	if err != nil {
		logger.Error("firebase init failed", "err", err)
		os.Exit(1)
	}
	defer app.Close()

	repo := repository.NewVideoRepo(app.Firestore())
	for _, v := range seedVideos() {
		if err := repo.Seed(ctx, v); err != nil {
			logger.Error("seed failed", "video", v.VideoID, "err", err)
			os.Exit(1)
		}
		logger.Info("seeded", "video", v.VideoID)
	}
	logger.Info("catalog seeded", "count", len(seedVideos()))
}

// seedVideos lists demo content. Hero entry uses a real HLS adaptive stream
// (Mux test stream of Big Buck Bunny); the rest use Google sample MP4s.
func seedVideos() []*models.Video {
	google := "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/"
	return []*models.Video{
		{
			VideoID:     "big-buck-bunny",
			Title:       "Big Buck Bunny",
			Description: "A giant rabbit with a heart bigger than himself; short film by the Blender Foundation.",
			PosterURL:   google + "images/BigBuckBunny.jpg",
			StreamURL:   "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
			Duration:    596,
			Qualities:   []string{"360p", "720p", "1080p"},
			Categories:  []string{"Animation", "Family"},
		},
		{
			VideoID:     "sintel",
			Title:       "Sintel",
			Description: "A lonely young woman fights for survival in a world captured by an evil dragon.",
			PosterURL:   google + "images/Sintel.jpg",
			StreamURL:   google + "Sintel.mp4",
			Duration:    888,
			Qualities:   []string{"1080p"},
			Categories:  []string{"Animation", "Fantasy"},
		},
		{
			VideoID:     "tears-of-steel",
			Title:       "Tears of Steel",
			Description: "A group of warriors and scientists bring a woman back to life in a post-apocalyptic Amsterdam.",
			PosterURL:   google + "images/TearsOfSteel.jpg",
			StreamURL:   google + "TearsOfSteel.mp4",
			Duration:    734,
			Qualities:   []string{"1080p"},
			Categories:  []string{"Sci-Fi", "Action"},
		},
		{
			VideoID:     "elephants-dream",
			Title:       "Elephants Dream",
			Description: "Two men explore a strange machine world where nothing is as it seems.",
			PosterURL:   google + "images/ElephantsDream.jpg",
			StreamURL:   google + "ElephantsDream.mp4",
			Duration:    654,
			Qualities:   []string{"1080p"},
			Categories:  []string{"Animation", "Sci-Fi"},
		},
	}
}
