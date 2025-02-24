package models

import (
	"fitness/internal/db"
	"time"
)

type Workout struct {
	ID          uint      `json:"id"`
	UserID      uint      `json:"user_id"`
	Date        time.Time `json:"date"`
	Type        string    `json:"type"`
	Duration    int       `json:"duration"`
	Description string    `json:"description"`
}

func CreateWorkout(userID uint, date time.Time, workoutType string, duration int, description string) (*Workout, error) {
	var id uint
	err := db.DB.QueryRow(
		"INSERT INTO workouts (user_id, date, type, duration, description) VALUES ($1, $2, $3, $4, $5) RETURNING id",
		userID, date, workoutType, duration, description,
	).Scan(&id)
	if err != nil {
		return nil, err
	}

	return &Workout{
		ID:          id,
		UserID:      userID,
		Date:        date,
		Type:        workoutType,
		Duration:    duration,
		Description: description,
	}, nil
}

func GetUserWorkouts(userID uint) ([]Workout, error) {
	rows, err := db.DB.Query(
		"SELECT id, user_id, date, type, duration, description FROM workouts WHERE user_id = $1 ORDER BY date DESC",
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var workouts []Workout
	for rows.Next() {
		var w Workout
		err := rows.Scan(&w.ID, &w.UserID, &w.Date, &w.Type, &w.Duration, &w.Description)
		if err != nil {
			return nil, err
		}
		workouts = append(workouts, w)
	}
	return workouts, nil
}