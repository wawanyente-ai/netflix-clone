// Package notify implements the weekly "new episodes" cron job.
package notify

import (
	"context"
	"encoding/json"
	"errors"
	"log/slog"
	"net/url"
	"strconv"

	"cloud.google.com/go/firestore"
	"firebase.google.com/go/v4/messaging"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/repository"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/service"
	"github.com/wawanyente-ai/netflix-clone/backend/internal/tmdb"
)

// Providers bundles the clients the cron job needs.
type Providers struct {
	DB     *firestore.Client
	FCM    *messaging.Client
	TMDB   *tmdb.Client
	Logger *slog.Logger
}

// Summary counts the run outcome.
type Summary struct {
	Users   int `json:"users"`
	Checked int `json:"titles_checked"`
	Sent    int `json:"notifications_sent"`
}

// lastEpisode mirrors the TMDB last_episode_to_air payload we care about.
type lastEpisode struct {
	Name          string `json:"name"`
	EpisodeNumber int    `json:"episode_number"`
	SeasonNumber  int    `json:"season_number"`
	AirDate       string `json:"air_date"`
}

type tvDetail struct {
	ID      int64       `json:"id"`
	Name    string      `json:"name"`
	LastEpi lastEpisode `json:"last_episode_to_air"`
}

// Run scans all users and pushes notifications for fresh episodes.
func (p *Providers) Run(ctx context.Context) (Summary, error) {
	var sum Summary

	userIDs, err := p.allUserIDs(ctx)
	if err != nil {
		return sum, err
	}
	sum.Users = len(userIDs)

	devices := repository.NewDeviceRepo(p.DB)
	notifStore := repository.NewNotificationRepo(p.DB)
	notifSvc := service.NewNotificationService(devices, notifStore, p.FCM, p.Logger)

	for _, uid := range userIDs {
		saved, err := p.watchlistTVTitles(ctx, uid)
		if err != nil {
			p.Logger.Warn("watchlist scan failed", "uid", uid, "err", err)
			continue
		}
		for _, item := range saved {
			sum.Checked++
			sent, err := p.maybeNotify(ctx, uid, item, notifSvc)
			if err != nil {
				p.Logger.Warn("notification step failed", "uid", uid, "mediaId", item.MediaID, "err", err)
				continue
			}
			if sent {
				sum.Sent++
			}
		}
	}
	return sum, nil
}

// watchlistTVTitles returns TV titles saved in any of the user's profiles.
func (p *Providers) watchlistTVTitles(ctx context.Context, uid string) ([]*models.WatchlistItem, error) {
	profiles := p.DB.Collection("users").Doc(uid).Collection("profiles")
	var out []*models.WatchlistItem

	profIter := profiles.Documents(ctx)
	for {
		prof, err := profIter.Next()
		if err != nil {
			if errIsDone(err) {
				break
			}
			return nil, err
		}
		mylist := profiles.Doc(prof.Ref.ID).Collection("mylist")
		itemIter := mylist.Documents(ctx)
		for {
			doc, err := itemIter.Next()
			if err != nil {
				if errIsDone(err) {
					break
				}
				return nil, err
			}
			var item models.WatchlistItem
			if err := doc.DataTo(&item); err != nil {
				return nil, err
			}
			if item.MediaType == string(models.MediaTypeTV) {
				out = append(out, &item)
			}
		}
	}
	return out, nil
}

// allUserIDs returns every user document ID.
func (p *Providers) allUserIDs(ctx context.Context) ([]string, error) {
	iter := p.DB.Collection("users").Documents(ctx)
	var ids []string
	for {
		doc, err := iter.Next()
		if err != nil {
			if errIsDone(err) {
				break
			}
			return nil, err
		}
		ids = append(ids, doc.Ref.ID)
	}
	return ids, nil
}

// maybeNotify sends a push when the show's latest air date is newer than the
// last one seen. Returns true when a notification was sent.
func (p *Providers) maybeNotify(ctx context.Context, uid string, item *models.WatchlistItem, notifSvc *service.NotificationService) (bool, error) {
	tracker := p.DB.Collection("users").Doc(uid).Collection("tracker").Doc(strconv.FormatInt(item.MediaID, 10))
	lastNotified := p.lastNotifiedAirDate(ctx, tracker)

	detail, err := p.fetchTVDetail(ctx, item.MediaID)
	if err != nil {
		return false, err
	}
	airDate := detail.LastEpi.AirDate
	if airDate == "" || airDate == lastNotified {
		return false, nil // nothing new
	}

	body := "S" + strconv.Itoa(detail.LastEpi.SeasonNumber) +
		"E" + strconv.Itoa(detail.LastEpi.EpisodeNumber) +
		" — " + detail.LastEpi.Name
	if _, err := notifSvc.SendPush(ctx, uid, service.PushInput{
		Title:     detail.Name,
		Body:      body,
		MediaType: models.MediaTypeTV,
		MediaID:   item.MediaID,
	}); err != nil {
		return false, err
	}

	if _, err := tracker.Set(ctx, map[string]any{"airDate": airDate}); err != nil {
		return false, err
	}
	return true, nil
}

// lastNotifiedAirDate reads the tracked air date for a title.
func (p *Providers) lastNotifiedAirDate(ctx context.Context, ref *firestore.DocumentRef) string {
	snap, err := ref.Get(ctx)
	if err != nil {
		return ""
	}
	var v struct {
		AirDate string `firestore:"airDate"`
	}
	if err := snap.DataTo(&v); err != nil {
		return ""
	}
	return v.AirDate
}

// fetchTVDetail pulls /tv/{id} and decodes the last-aired episode.
func (p *Providers) fetchTVDetail(ctx context.Context, id int64) (*tvDetail, error) {
	raw, err := p.TMDB.Fetch(ctx, "/tv/"+strconv.FormatInt(id, 10), url.Values{})
	if err != nil {
		return nil, err
	}
	var d tvDetail
	if err := json.Unmarshal(raw, &d); err != nil {
		return nil, err
	}
	return &d, nil
}

func errIsDone(err error) bool {
	return errors.Is(err, repository.ErrIterDone)
}
