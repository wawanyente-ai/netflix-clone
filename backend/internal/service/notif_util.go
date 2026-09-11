package service

import (
	"strconv"

	"github.com/google/uuid"
)

func newNotifID() string {
	return uuid.NewString()
}

func intJoin(n int64) string {
	return strconv.FormatInt(n, 10)
}
