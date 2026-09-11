package repository

import (
	"context"

	"cloud.google.com/go/firestore"

	"github.com/wawanyente-ai/netflix-clone/backend/internal/models"
)

// UserRepo persists users under users/{uid}.
type UserRepo struct {
	db *firestore.Client
}

func NewUserRepo(db *firestore.Client) *UserRepo {
	return &UserRepo{db: db}
}

// usersDoc returns a client reference to a specific user.
func (r *UserRepo) usersDoc(uid string) *firestore.DocumentRef {
	return r.db.Collection("users").Doc(uid)
}

// GetUser fetches a user by Firebase UID. Returns repository.ErrNotFound
// when the user does not exist.
func (r *UserRepo) GetUser(ctx context.Context, uid string) (*models.User, error) {
	snap, err := r.usersDoc(uid).Get(ctx)
	if err != nil {
		if errIsNotFound(err) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	var u models.User
	if err := snap.DataTo(&u); err != nil {
		return nil, err
	}
	u.UID = snap.Ref.ID
	return &u, nil
}

// CreateUser stores a new user document.
func (r *UserRepo) CreateUser(ctx context.Context, u *models.User) error {
	_, err := r.usersDoc(u.UID).Set(ctx, u)
	return err
}
