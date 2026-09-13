package notify

import (
	"context"
	"encoding/json"
	"errors"
	"net/url"
	"strconv"

	"cloud.google.com/go/firestore"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/repository"
)

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
