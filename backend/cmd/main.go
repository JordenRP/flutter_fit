package main

import (
	"log"
	"net/http"
	"os"
	"github.com/gorilla/mux"
	"fitness/internal/handlers"
	"fitness/internal/db"
)

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "*")
		w.Header().Set("Access-Control-Allow-Headers", "*")
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func main() {
	err := db.InitDB(
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
	)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	r := mux.NewRouter()
	
	const jwtSecret = "your-secret-key"
	authHandler := handlers.NewAuthHandler(jwtSecret)
	workoutHandler := handlers.NewWorkoutHandler()
	nutritionHandler := handlers.NewNutritionHandler()

	// Public routes
	r.HandleFunc("/api/auth/login", authHandler.Login).Methods("POST", "OPTIONS")
	r.HandleFunc("/api/auth/register", authHandler.Register).Methods("POST", "OPTIONS")

	// Protected routes
	api := r.PathPrefix("/api").Subrouter()
	api.Use(handlers.AuthMiddleware(jwtSecret))

	api.HandleFunc("/workouts", workoutHandler.CreateWorkout).Methods("POST", "OPTIONS")
	api.HandleFunc("/workouts", workoutHandler.GetWorkouts).Methods("GET", "OPTIONS")

	api.HandleFunc("/nutrition", nutritionHandler.CreateNutrition).Methods("POST", "OPTIONS")
	api.HandleFunc("/nutrition", nutritionHandler.GetNutrition).Methods("GET", "OPTIONS")

	r.Use(corsMiddleware)

	log.Println("Server starting on port 8080...")
	if err := http.ListenAndServe(":8080", r); err != nil {
		log.Fatal(err)
	}
}