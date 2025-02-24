package handlers

import (
	"encoding/json"
	"net/http"
	"fitness/internal/models"
	"time"
)

type MealPlanHandler struct{}

type MealPlanRequest struct {
	Name        string            `json:"name"`
	Description string            `json:"description"`
	StartDate   string            `json:"start_date"`
	EndDate     string            `json:"end_date"`
	Days        []models.MealDay  `json:"days"`
}

func NewMealPlanHandler() *MealPlanHandler {
	return &MealPlanHandler{}
}

func (h *MealPlanHandler) CreateMealPlan(w http.ResponseWriter, r *http.Request) {
	var req MealPlanRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Неверный формат запроса", http.StatusBadRequest)
		return
	}

	userID := r.Context().Value("user_id").(uint)
	
	startDate, err := time.Parse("2006-01-02", req.StartDate)
	if err != nil {
		http.Error(w, "Неверный формат даты начала", http.StatusBadRequest)
		return
	}

	endDate, err := time.Parse("2006-01-02", req.EndDate)
	if err != nil {
		http.Error(w, "Неверный формат даты окончания", http.StatusBadRequest)
		return
	}

	plan, err := models.CreateMealPlan(
		userID,
		req.Name,
		req.Description,
		startDate,
		endDate,
		req.Days,
	)
	if err != nil {
		http.Error(w, "Не удалось создать план питания", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(plan)
}

func (h *MealPlanHandler) GetMealPlans(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value("user_id").(uint)

	plans, err := models.GetUserMealPlans(userID)
	if err != nil {
		http.Error(w, "Не удалось получить планы питания", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(plans)
} 