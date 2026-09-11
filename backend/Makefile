.PHONY: run run-cron build seed test vet fmt docker-build docker-run deploy deploy-cron clean

run:
	set -a && . ./.env && set +a && go run ./cmd/server

# Run the weekly "new episodes" cron once with local creds.
run-cron:
	set -a && . ./.env && set +a && go run ./cmd/server --role=cron

build:
	go build -o bin/server ./cmd/server
	go build -o bin/notifier ./cmd/notifier
	go build -o bin/seed ./cmd/seed

# Seed the streaming catalog into Firestore (requires service account + project).
seed:
	set -a && . ./.env && set +a && go run ./cmd/seed

test:
	go test ./...

vet:
	go vet ./...

fmt:
	gofmt -w .
	[ -z "$$(gofmt -l .)" ]

docker-build:
	docker build -t netflix-clone-backend .

docker-run:
	docker run --rm -p 8080:8080 -e PORT=8080 netflix-clone-backend

# Deploy to Cloud Run (requires gcloud + billing-enabled project).
# Region: asia-southeast2 (Jakarta). Adjust PROJECT_ID / SERVICE_NAME.
deploy:
	gcloud run deploy netflix-backend \
		--source . \
		--platform managed \
		--region asia-southeast2 \
		--allow-unauthenticated \
		--set-env-vars "ENV=production,GCP_PROJECT_ID=$(PROJECT_ID),TMDB_ACCESS_TOKEN=$(TMDB_TOKEN)" \
		--project $(PROJECT_ID)

# Deploy the same image as the cron worker service (invoked by Cloud Scheduler).
deploy-cron:
	gcloud run deploy netflix-backend-cron \
		--source . \
		--platform managed \
		--region asia-southeast2 \
		--allow-unauthenticated \
		--no-cpu-throttling \
		--set-env-vars "ENV=production,GCP_PROJECT_ID=$(PROJECT_ID),TMDB_ACCESS_TOKEN=$(TMDB_TOKEN),ROLE=cron" \
		--args cron \
		--project $(PROJECT_ID)

clean:
	rm -rf bin