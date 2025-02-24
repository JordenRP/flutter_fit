package models

import (
	"fitness/internal/db"
	"time"
	"encoding/json"
)

type Meal struct {
	Name        string  `json:"name"`
	Time        string  `json:"time"`
	Calories    int     `json:"calories"`
	Proteins    float64 `json:"proteins"`
	Fats        float64 `json:"fats"`
	Carbs       float64 `json:"carbs"`
	Description string  `json:"description"`
}

type MealDay struct {
	DayOfWeek int    `json:"day_of_week"` // 1 = Понедельник, 7 = Воскресенье
	Meals     []Meal `json:"meals"`
}

type MealPlan struct {
	ID          uint      `json:"id"`
	UserID      uint      `json:"user_id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	StartDate   time.Time `json:"start_date"`
	EndDate     time.Time `json:"end_date"`
	Days        []MealDay `json:"days"`
}

func CreateMealPlan(userID uint, name, description string, startDate, endDate time.Time, days []MealDay) (*MealPlan, error) {
	daysJSON, err := json.Marshal(days)
	if err != nil {
		return nil, err
	}

	var id uint
	err = db.DB.QueryRow(
		`INSERT INTO meal_plans (user_id, name, description, start_date, end_date, days) 
		VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`,
		userID, name, description, startDate, endDate, daysJSON,
	).Scan(&id)
	if err != nil {
		return nil, err
	}

	return &MealPlan{
		ID:          id,
		UserID:      userID,
		Name:        name,
		Description: description,
		StartDate:   startDate,
		EndDate:     endDate,
		Days:        days,
	}, nil
}

func GetUserMealPlans(userID uint) ([]MealPlan, error) {
	rows, err := db.DB.Query(
		`SELECT id, user_id, name, description, start_date, end_date, days 
		FROM meal_plans 
		WHERE user_id = $1 
		ORDER BY start_date DESC`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var plans []MealPlan
	for rows.Next() {
		var p MealPlan
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