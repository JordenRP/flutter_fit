package models

import (
	"fitness/internal/db"
	"time"
	"encoding/json"
)

type Exercise struct {
	Name        string `json:"name"`
	Sets        int    `json:"sets"`
	Reps        int    `json:"reps"`
	Weight      float64 `json:"weight"`
	Description string `json:"description"`
}

type TrainingDay struct {
	DayOfWeek  int        `json:"day_of_week"` // 1 = Понедельник, 7 = Воскресенье
	Exercises  []Exercise `json:"exercises"`
}

type TrainingPlan struct {
	ID          uint      `json:"id"`
	UserID      uint      `json:"user_id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	StartDate   time.Time `json:"start_date"`
	EndDate     time.Time `json:"end_date"`
	Days        []TrainingDay `json:"days"`
}

func CreateTrainingPlan(userID uint, name, description string, startDate, endDate time.Time, days []TrainingDay) (*TrainingPlan, error) {
	daysJSON, err := json.Marshal(days)
	if err != nil {
		return nil, err
	}

	var id uint
	err = db.DB.QueryRow(
		`INSERT INTO training_plans (user_id, name, description, start_date, end_date, days) 
		VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`,
		userID, name, description, startDate, endDate, daysJSON,
	).Scan(&id)
	if err != nil {
		return nil, err
	}

	return &TrainingPlan{
		ID:          id,
		UserID:      userID,
		Name:        name,
		Description: description,
		StartDate:   startDate,
		EndDate:     endDate,
		Days:        days,
	}, nil
}

func GetUserTrainingPlans(userID uint) ([]TrainingPlan, error) {
	rows, err := db.DB.Query(
		`SELECT id, user_id, name, description, start_date, end_date, days 
		FROM training_plans 
		WHERE user_id = $1 
		ORDER BY start_date DESC`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var plans []TrainingPlan
	for rows.Next() {
		var p TrainingPlan
		var daysJSON []byte
		err := rows.Scan(&p.ID, &p.UserID, &p.Name, &p.Description, &p.StartDate, &p.EndDate, &daysJSON)
		if err != nil {
			return nil, err
		}
		
		err = json.Unmarshal(daysJSON, &p.Days)
		if err != nil {
			return nil, err
		}
		
		plans = append(plans, p)
	}
	return plans, nil
} 