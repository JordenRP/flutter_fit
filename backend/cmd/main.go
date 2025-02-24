package main

import (
	"log"
	"net/http"
	"os"
	"github.com/gorilla/mux"
<<<<<<< HEAD
	"todo-app/internal/handlers"
	"todo-app/internal/db"
	"todo-app/internal/middleware"
	"time"
	"todo-app/internal/models"
=======
	"fitness/internal/handlers"
	"fitness/internal/db"
>>>>>>> feature
)

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "http://localhost:3000")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		w.Header().Set("Access-Control-Allow-Credentials", "true")
		
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
	r.Use(corsMiddleware)
	
<<<<<<< HEAD
	jwtSecret := []byte("your-secret-key")
	authHandler := handlers.NewAuthHandler(string(jwtSecret))
	taskHandler := handlers.NewTaskHandler()
	notificationHandler := handlers.NewNotificationHandler()
	categoryHandler := handlers.NewCategoryHandler()
=======
	const jwtSecret = "your-secret-key"
	authHandler := handlers.NewAuthHandler(jwtSecret)
	workoutHandler := handlers.NewWorkoutHandler()
	nutritionHandler := handlers.NewNutritionHandler()
	progressHandler := handlers.NewProgressHandler()
	trainingPlanHandler := handlers.NewTrainingPlanHandler()
	mealPlanHandler := handlers.NewMealPlanHandler()
	notificationHandler := handlers.NewNotificationHandler()
>>>>>>> feature

	// Public routes
	r.HandleFunc("/api/auth/login", authHandler.Login).Methods("POST", "OPTIONS")
	r.HandleFunc("/api/auth/register", authHandler.Register).Methods("POST", "OPTIONS")

<<<<<<< HEAD
	taskRouter := r.PathPrefix("/api/tasks").Subrouter()
	taskRouter.Use(middleware.AuthMiddleware(jwtSecret))
	taskRouter.HandleFunc("", taskHandler.Create).Methods("POST", "OPTIONS")
	taskRouter.HandleFunc("", taskHandler.List).Methods("GET", "OPTIONS")
	taskRouter.HandleFunc("/{id}", taskHandler.Update).Methods("PUT", "OPTIONS")
	taskRouter.HandleFunc("/{id}", taskHandler.Delete).Methods("DELETE", "OPTIONS")

	categoryRouter := r.PathPrefix("/api/categories").Subrouter()
	categoryRouter.Use(middleware.AuthMiddleware(jwtSecret))
	categoryRouter.HandleFunc("", categoryHandler.List).Methods("GET", "OPTIONS")
	categoryRouter.HandleFunc("", categoryHandler.Create).Methods("POST", "OPTIONS")
	categoryRouter.HandleFunc("/{id}", categoryHandler.Delete).Methods("DELETE", "OPTIONS")
	categoryRouter.HandleFunc("/{id}/tasks", categoryHandler.GetTasks).Methods("GET", "OPTIONS")
	categoryRouter.HandleFunc("/tasks/{id}", categoryHandler.UpdateTaskCategory).Methods("PUT", "OPTIONS")

	notificationRouter := r.PathPrefix("/api/notifications").Subrouter()
	notificationRouter.Use(middleware.AuthMiddleware(jwtSecret))
	notificationRouter.HandleFunc("", notificationHandler.List).Methods("GET", "OPTIONS")
	notificationRouter.HandleFunc("/{id}/read", notificationHandler.MarkAsRead).Methods("POST", "OPTIONS")
	notificationRouter.HandleFunc("/check", notificationHandler.CheckDueTasks).Methods("POST", "OPTIONS")

	go func() {
		ticker := time.NewTicker(15 * time.Minute)
		for range ticker.C {
			if err := models.CheckDueTasks(); err != nil {
				log.Printf("Error checking due tasks: %v", err)
			}
		}
	}()
=======
	// Protected routes
	api := r.PathPrefix("/api").Subrouter()
	api.Use(handlers.AuthMiddleware(jwtSecret))

	api.HandleFunc("/workouts", workoutHandler.CreateWorkout).Methods("POST", "OPTIONS")
	api.HandleFunc("/workouts", workoutHandler.GetWorkouts).Methods("GET", "OPTIONS")

	api.HandleFunc("/nutrition", nutritionHandler.CreateNutrition).Methods("POST", "OPTIONS")
	api.HandleFunc("/nutrition", nutritionHandler.GetNutrition).Methods("GET", "OPTIONS")

	api.HandleFunc("/progress", progressHandler.CreateProgress).Methods("POST", "OPTIONS")
	api.HandleFunc("/progress", progressHandler.GetProgress).Methods("GET", "OPTIONS")
	api.HandleFunc("/progress/stats", progressHandler.GetStats).Methods("POST", "OPTIONS")
	api.HandleFunc("/progress/chart", progressHandler.GetChartData).Methods("POST", "OPTIONS")

	api.HandleFunc("/training-plans", trainingPlanHandler.CreateTrainingPlan).Methods("POST", "OPTIONS")
	api.HandleFunc("/training-plans", trainingPlanHandler.GetTrainingPlans).Methods("GET", "OPTIONS")

	api.HandleFunc("/meal-plans", mealPlanHandler.CreateMealPlan).Methods("POST", "OPTIONS")
	api.HandleFunc("/meal-plans", mealPlanHandler.GetMealPlans).Methods("GET", "OPTIONS")

	// Notification routes
	api.HandleFunc("/notifications", notificationHandler.GetNotifications).Methods("GET", "OPTIONS")
	api.HandleFunc("/notifications/mark-read", notificationHandler.MarkAsRead).Methods("POST", "OPTIONS")
	api.HandleFunc("/notifications", notificationHandler.CreateNotification).Methods("POST", "OPTIONS")

	r.Use(corsMiddleware)
>>>>>>> feature

	log.Println("Server starting on port 8080...")
	if err := http.ListenAndServe(":8080", r); err != nil {
		log.Fatal(err)
	}
}