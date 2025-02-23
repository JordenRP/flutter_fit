package models

import (
	"fitness/internal/db"
	"time"
)

type Progress struct {
	ID          uint      `json:"id"`
	UserID      uint      `json:"user_id"`
	Date        time.Time `json:"date"`
	Weight      float64   `json:"weight"`      // вес в кг
	Chest       float64   `json:"chest"`       // обхват груди в см
	Waist       float64   `json:"waist"`       // обхват талии в см
	Hips        float64   `json:"hips"`        // обхват бедер в см
	Biceps      float64   `json:"biceps"`      // обхват бицепса в см
	Thigh       float64   `json:"thigh"`       // обхват бедра в см
	Notes       string    `json:"notes"`       // заметки
}

func CreateProgress(userID uint, date time.Time, weight, chest, waist, hips, biceps, thigh float64, notes string) (*Progress, error) {
	var id uint
	err := db.DB.QueryRow(
		`INSERT INTO progress (user_id, date, weight, chest, waist, hips, biceps, thigh, notes) 
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id`,
		userID, date, weight, chest, waist, hips, biceps, thigh, notes,
	).Scan(&id)
	if err != nil {
		return nil, err
	}

	return &Progress{
		ID:     id,
		UserID: userID,
		Date:   date,
		Weight: weight,
		Chest:  chest,
		Waist:  waist,
		Hips:   hips,
		Biceps: biceps,
		Thigh:  thigh,
		Notes:  notes,
	}, nil
}

func GetUserProgress(userID uint) ([]Progress, error) {
	rows, err := db.DB.Query(
		`SELECT id, user_id, date, weight, chest, waist, hips, biceps, thigh, notes 
		FROM progress 
		WHERE user_id = $1 
		ORDER BY date DESC`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var progress []Progress
	for rows.Next() {
		var p Progress
		err := rows.Scan(&p.ID, &p.UserID, &p.Date, &p.Weight, &p.Chest, &p.Waist, &p.Hips, &p.Biceps, &p.Thigh, &p.Notes)
		if err != nil {
			return nil, err
		}
		progress = append(progress, p)
	}
	return progress, nil
} 