package handlers

import (
	"encoding/base64"
	"encoding/json"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/repository"
)

// historyCursorCodec encodes/decodes the pagination token for clients.
var historyCursorCodec = base64.RawURLEncoding

func encodeCursor(c *repository.HistoryCursor) string {
	if c == nil {
		return ""
	}
	b, err := json.Marshal(c)
	if err != nil {
		return ""
	}
	return historyCursorCodec.EncodeToString(b)
}

func decodeCursor(raw string) (*repository.HistoryCursor, error) {
	if raw == "" {
		return nil, nil
	}
	b, err := historyCursorCodec.DecodeString(raw)
	if err != nil {
		return nil, err
	}
	var c repository.HistoryCursor
	if err := json.Unmarshal(b, &c); err != nil {
		return nil, err
	}
	return &c, nil
}
