package models

import (
	"fitness/internal/db"
	"time"
)

type Nutrition struct {
	ID          uint      `json:"id"`
	UserID      uint      `json:"user_id"`
	Date        time.Time `json:"date"`
	MealType    string    `json:"meal_type"`
	FoodName    string    `json:"food_name"`
	Calories    int       `json:"calories"`
	Proteins    float64   `json:"proteins"`
	Fats        float64   `json:"fats"`
	Carbs       float64   `json:"carbs"`
}

func CreateNutrition(userID uint, date time.Time, mealType, foodName string, calories int, proteins, fats, carbs float64) (*Nutrition, error) {
	var id uint
	err := db.DB.QueryRow(
		"INSERT INTO nutrition (user_id, date, meal_type, food_name, calories, proteins, fats, carbs) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id",
		userID, date, mealType, foodName, calories, proteins, fats, carbs,
	).Scan(&id)
	if err != nil {
		return nil, err
	}

	return &Nutrition{
		ID:       id,
		UserID:   userID,
		Date:     date,
		MealType: mealType,
		FoodName: foodName,
		Calories: calories,
		Proteins: proteins,
		Fats:     fats,
		Carbs:    carbs,
	}, nil
}

func GetUserNutrition(userID uint) ([]Nutrition, error) {
	rows, err := db.DB.Query(
		"SELECT id, user_id, date, meal_type, food_name, calories, proteins, fats, carbs FROM nutrition WHERE user_id = $1 ORDER BY date DESC",
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var nutritions []Nutrition
	for rows.Next() {
		var n Nutrition
		err := rows.Scan(&n.ID, &n.UserID, &n.Date, &n.MealType, &n.FoodName, &n.Calories, &n.Proteins, &n.Fats, &n.Carbs)
		if err != nil {
			return nil, err
		}
		nutritions = append(nutritions, n)
	}
	return nutritions, nil
}