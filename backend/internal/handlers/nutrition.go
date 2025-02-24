package handlers

import (
	"encoding/json"
	"net/http"
	"fitness/internal/models"
	"time"
)

type NutritionHandler struct{}

type NutritionRequest struct {
	Date     string  `json:"date"`
	MealType string  `json:"meal_type"`
	FoodName string  `json:"food_name"`
	Calories int     `json:"calories"`
	Proteins float64 `json:"proteins"`
	Fats     float64 `json:"fats"`
	Carbs    float64 `json:"carbs"`
}

func NewNutritionHandler() *NutritionHandler {
	return &NutritionHandler{}
}

func (h *NutritionHandler) CreateNutrition(w http.ResponseWriter, r *http.Request) {
	var req NutritionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	userID := r.Context().Value("user_id").(uint)
	date, err := time.Parse("2006-01-02", req.Date)
	if err != nil {
		http.Error(w, "Invalid date format", http.StatusBadRequest)
		return
	}

	nutrition, err := models.CreateNutrition(userID, date, req.MealType, req.FoodName, req.Calories, req.Proteins, req.Fats, req.Carbs)
	if err != nil {
		http.Error(w, "Could not create nutrition entry", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(nutrition)
}

func (h *NutritionHandler) GetNutrition(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value("user_id").(uint)

	nutrition, err := models.GetUserNutrition(userID)
	if err != nil {
		http.Error(w, "Could not get nutrition entries", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(nutrition)
}