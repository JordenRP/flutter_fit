package handlers

import (
	"encoding/json"
	"net/http"
	"fitness/internal/models"
	"time"
)

type ProgressHandler struct{}

type ProgressRequest struct {
	Date    string  `json:"date"`
	Weight  float64 `json:"weight"`
	Chest   float64 `json:"chest"`
	Waist   float64 `json:"waist"`
	Hips    float64 `json:"hips"`
	Biceps  float64 `json:"biceps"`
	Thigh   float64 `json:"thigh"`
	Notes   string  `json:"notes"`
}

func NewProgressHandler() *ProgressHandler {
	return &ProgressHandler{}
}

func (h *ProgressHandler) CreateProgress(w http.ResponseWriter, r *http.Request) {
	var req ProgressRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Неверный формат запроса", http.StatusBadRequest)
		return
	}

	userID := r.Context().Value("user_id").(uint)
	date, err := time.Parse("2006-01-02", req.Date)
	if err != nil {
		http.Error(w, "Неверный формат даты", http.StatusBadRequest)
		return
	}

	progress, err := models.CreateProgress(
		userID, 
		date, 
		req.Weight,
		req.Chest,
		req.Waist,
		req.Hips,
		req.Biceps,
		req.Thigh,
		req.Notes,
	)
	if err != nil {
		http.Error(w, "Не удалось сохранить прогресс", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(progress)
}

func (h *ProgressHandler) GetProgress(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value("user_id").(uint)

	progress, err := models.GetUserProgress(userID)
	if err != nil {
		http.Error(w, "Не удалось получить данные о прогрессе", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(progress)
} 