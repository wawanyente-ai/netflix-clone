package service

import "log/slog"

type slogDiscard struct{}

func (slogDiscard) Write(p []byte) (int, error) { return len(p), nil }

func testSvcLogger() *slog.Logger {
	return slog.New(slog.NewTextHandler(slogDiscard{}, nil))
}
