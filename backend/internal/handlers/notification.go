package handlers

import (
<<<<<<< HEAD
    "encoding/json"
    "net/http"
    "strconv"
    "github.com/gorilla/mux"
    "todo-app/internal/models"
=======
	"encoding/json"
	"net/http"
	"fitness/internal/models"
	"strconv"
>>>>>>> feature
)

type NotificationHandler struct{}

func NewNotificationHandler() *NotificationHandler {
<<<<<<< HEAD
    return &NotificationHandler{}
}

func (h *NotificationHandler) List(w http.ResponseWriter, r *http.Request) {
    userID := getUserIDFromToken(r)
    notifications, err := models.GetUserNotifications(userID)
    if err != nil {
        http.Error(w, "Could not get notifications", http.StatusInternalServerError)
        return
    }
    json.NewEncoder(w).Encode(notifications)
}

func (h *NotificationHandler) MarkAsRead(w http.ResponseWriter, r *http.Request) {
    vars := mux.Vars(r)
    notificationID, err := strconv.ParseUint(vars["id"], 10, 32)
    if err != nil {
        http.Error(w, "Invalid notification ID", http.StatusBadRequest)
        return
    }

    err = models.MarkNotificationAsRead(uint(notificationID))
    if err != nil {
        http.Error(w, "Could not mark notification as read", http.StatusInternalServerError)
        return
    }

    w.WriteHeader(http.StatusOK)
}

func (h *NotificationHandler) CheckDueTasks(w http.ResponseWriter, r *http.Request) {
    err := models.CheckDueTasks()
    if err != nil {
        http.Error(w, "Could not check due tasks", http.StatusInternalServerError)
        return
    }
    w.WriteHeader(http.StatusOK)
=======
	return &NotificationHandler{}
}

func (h *NotificationHandler) GetNotifications(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value("user_id").(uint)

	notifications, err := models.GetUserNotifications(userID)
	if err != nil {
		http.Error(w, "Не удалось получить уведомления", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(notifications)
}

func (h *NotificationHandler) MarkAsRead(w http.ResponseWriter, r *http.Request) {
	notificationID := r.URL.Query().Get("id")
	if notificationID == "" {
		http.Error(w, "ID уведомления не указан", http.StatusBadRequest)
		return
	}

	id, err := strconv.ParseUint(notificationID, 10, 32)
	if err != nil {
		http.Error(w, "Неверный формат ID", http.StatusBadRequest)
		return
	}

	err = models.MarkNotificationAsRead(uint(id))
	if err != nil {
		http.Error(w, "Не удалось обновить статус уведомления", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (h *NotificationHandler) CreateNotification(w http.ResponseWriter, r *http.Request) {
	var req struct {
		UserID  uint                    `json:"user_id"`
		Type    models.NotificationType `json:"type"`
		Message string                  `json:"message"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Неверный формат запроса", http.StatusBadRequest)
		return
	}

	notification, err := models.CreateNotification(req.UserID, req.Type, req.Message)
	if err != nil {
		http.Error(w, "Не удалось создать уведомление", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(notification)
>>>>>>> feature
} 