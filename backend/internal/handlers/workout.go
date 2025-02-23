package handlers

import (
	"encoding/json"
	"net/http"
	"fitness/internal/models"
	"time"
)

type WorkoutHandler struct{}

type WorkoutRequest struct {
	Date        string `json:"date"`
	Type        string `json:"type"`
	Duration    int    `json:"duration"`
	Description string `json:"description"`
}

func NewWorkoutHandler() *WorkoutHandler {
	return &WorkoutHandler{}
}

func (h *WorkoutHandler) CreateWorkout(w http.ResponseWriter, r *http.Request) {
	var req WorkoutRequest
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

	workout, err := models.CreateWorkout(userID, date, req.Type, req.Duration, req.Description)
	if err != nil {
		http.Error(w, "Could not create workout", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(workout)
}

func (h *WorkoutHandler) GetWorkouts(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value("user_id").(uint)

	workouts, err := models.GetUserWorkouts(userID)
	if err != nil {
		http.Error(w, "Could not get workouts", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(workouts)
}