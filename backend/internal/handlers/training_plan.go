package handlers

import (
	"encoding/json"
	"net/http"
	"fitness/internal/models"
	"time"
)

type TrainingPlanHandler struct{}

type TrainingPlanRequest struct {
	Name        string                `json:"name"`
	Description string                `json:"description"`
	StartDate   string                `json:"start_date"`
	EndDate     string                `json:"end_date"`
	Days        []models.TrainingDay  `json:"days"`
}

func NewTrainingPlanHandler() *TrainingPlanHandler {
	return &TrainingPlanHandler{}
}

func (h *TrainingPlanHandler) CreateTrainingPlan(w http.ResponseWriter, r *http.Request) {
	var req TrainingPlanRequest
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

	plan, err := models.CreateTrainingPlan(
		userID,
		req.Name,
		req.Description,
		startDate,
		endDate,
		req.Days,
	)
	if err != nil {
		http.Error(w, "Не удалось создать план тренировок", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(plan)
}

func (h *TrainingPlanHandler) GetTrainingPlans(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value("user_id").(uint)

	plans, err := models.GetUserTrainingPlans(userID)
	if err != nil {
		http.Error(w, "Не удалось получить планы тренировок", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(plans)
} 