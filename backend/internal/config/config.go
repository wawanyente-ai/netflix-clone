package config

import (
	"os"
	"strings"
)

// Config holds all runtime configuration loaded from environment variables.
type Config struct {
	Env                 string   // development | production
	Port                string   // HTTP listen port
	Role                string   // api | cron (default api)
	LogLevel            string   // debug | info | warn | error
	GCPProjectID        string   // Firebase project ID
	FirebaseAccountPath string   // path to service account JSON (optional; else ADC)
	AllowUnauthDev      bool     // dev-only: accept requests without valid ID token when Firebase not configured
	CORSAllowedOrigins  []string // comma-separated list of allowed origins
	TMDBAPIToken        string   // TMDB v3 access token (server-side only)
}

// Load reads configuration from environment variables with sane defaults.
func Load() *Config {
	return &Config{
		Env:                 getEnv("ENV", "development"),
		Port:                getEnv("PORT", "8080"),
		Role:                getEnv("ROLE", "api"),
		LogLevel:            getEnv("LOG_LEVEL", "info"),
		GCPProjectID:        os.Getenv("GCP_PROJECT_ID"),
		FirebaseAccountPath: os.Getenv("FIREBASE_SERVICE_ACCOUNT_PATH"),
		AllowUnauthDev:      getEnv("ALLOW_UNAUTHENTICATED_DEV", "false") == "true",
		CORSAllowedOrigins:  splitCSV(os.Getenv("CORS_ALLOWED_ORIGINS")),
		TMDBAPIToken:        os.Getenv("TMDB_ACCESS_TOKEN"),
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func splitCSV(s string) []string {
	if strings.TrimSpace(s) == "" {
		return nil
	}
	parts := strings.Split(s, ",")
	out := make([]string, 0, len(parts))
	for _, p := range parts {
		if t := strings.TrimSpace(p); t != "" {
			out = append(out, t)
		}
	}
	return out
}
