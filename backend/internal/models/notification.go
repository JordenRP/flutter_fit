package models

import (
<<<<<<< HEAD
    "time"
    "todo-app/internal/db"
)

type Notification struct {
    ID        uint      `json:"id"`
    UserID    uint      `json:"user_id"`
    TaskID    uint      `json:"task_id"`
    Message   string    `json:"message"`
    CreatedAt time.Time `json:"created_at"`
    Read      bool      `json:"read"`
}

func CreateNotification(userID, taskID uint, message string) error {
    _, err := db.DB.Exec(
        `INSERT INTO notifications (user_id, task_id, message, created_at, read) 
         VALUES ($1, $2, $3, NOW(), false)`,
        userID, taskID, message,
    )
    return err
}

func GetUserNotifications(userID uint) ([]Notification, error) {
    rows, err := db.DB.Query(
        `SELECT id, user_id, task_id, message, created_at, read 
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
        err := rows.Scan(&n.ID, &n.UserID, &n.TaskID, &n.Message, &n.CreatedAt, &n.Read)
        if err != nil {
            return nil, err
        }
        notifications = append(notifications, n)
    }
    return notifications, nil
}

func MarkNotificationAsRead(id uint) error {
    _, err := db.DB.Exec(
        "UPDATE notifications SET read = true WHERE id = $1",
        id,
    )
    return err
}

func CheckDueTasks() error {
    _, err := db.DB.Exec(`
        INSERT INTO notifications (user_id, task_id, message, created_at, read)
        SELECT 
            user_id,
            id as task_id,
            CASE 
                WHEN due_date < NOW() THEN 'Задача просрочена: ' || title
                WHEN due_date < NOW() + INTERVAL '1 day' THEN 'Задача должна быть выполнена сегодня: ' || title
                WHEN due_date < NOW() + INTERVAL '3 days' THEN 'До срока выполнения задачи осталось менее 3 дней: ' || title
                ELSE 'Новая задача создана: ' || title
            END as message,
            NOW(),
            false
        FROM tasks
        WHERE 
            completed = false 
            AND (
                due_date < NOW() 
                OR due_date < NOW() + INTERVAL '1 day'
                OR due_date < NOW() + INTERVAL '3 days'
                OR id NOT IN (SELECT task_id FROM notifications)
            )
            AND NOT EXISTS (
                SELECT 1 FROM notifications n 
                WHERE n.task_id = tasks.id 
                AND n.created_at > NOW() - INTERVAL '1 hour'
            )
    `)
    return err
=======
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
>>>>>>> feature
} 