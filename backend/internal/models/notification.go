package models

import (
	"fitness/internal/db"
	"time"
)

type NotificationType string

const (
	TrainingReminder NotificationType = "training_reminder"
	MealReminder     NotificationType = "meal_reminder"
	ProgressReminder NotificationType = "progress_reminder"
	GeneralTip       NotificationType = "general_tip"
)

type Notification struct {
	ID        uint            `json:"id"`
	UserID    uint            `json:"user_id"`
	Type      NotificationType `json:"type"`
	Message   string          `json:"message"`
	IsRead    bool            `json:"is_read"`
	CreatedAt time.Time       `json:"created_at"`
}

func CreateNotification(userID uint, notificationType NotificationType, message string) (*Notification, error) {
	var id uint
	err := db.DB.QueryRow(
		`INSERT INTO notifications (user_id, type, message, is_read, created_at) 
		VALUES ($1, $2, $3, false, $4) RETURNING id`,
		userID, notificationType, message, time.Now(),
	).Scan(&id)
	if err != nil {
		return nil, err
	}

	return &Notification{
		ID:        id,
		UserID:    userID,
		Type:      notificationType,
		Message:   message,
		IsRead:    false,
		CreatedAt: time.Now(),
	}, nil
}

func GetUserNotifications(userID uint) ([]Notification, error) {
	rows, err := db.DB.Query(
		`SELECT id, user_id, type, message, is_read, created_at 
		FROM notifications 
		WHERE user_id = $1 
		ORDER BY created_at DESC`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var notifications []Notification
	for rows.Next() {
		var n Notification
		err := rows.Scan(&n.ID, &n.UserID, &n.Type, &n.Message, &n.IsRead, &n.CreatedAt)
		if err != nil {
			return nil, err
		}
		notifications = append(notifications, n)
	}
	return notifications, nil
}

func MarkNotificationAsRead(notificationID uint) error {
	_, err := db.DB.Exec(
		"UPDATE notifications SET is_read = true WHERE id = $1",
		notificationID,
	)
	return err
} 