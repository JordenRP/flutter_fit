package models

import (
	"fitness/internal/db"
	"time"
)

type Progress struct {
	ID          uint      `json:"id"`
	UserID      uint      `json:"user_id"`
	Date        time.Time `json:"date"`
	Weight      float64   `json:"weight"`      // вес в кг
	Chest       float64   `json:"chest"`       // обхват груди в см
	Waist       float64   `json:"waist"`       // обхват талии в см
	Hips        float64   `json:"hips"`        // обхват бедер в см
	Biceps      float64   `json:"biceps"`      // обхват бицепса в см
	Thigh       float64   `json:"thigh"`       // обхват бедра в см
	Notes       string    `json:"notes"`       // заметки
}

type ProgressStats struct {
	StartWeight     float64 `json:"start_weight"`
	CurrentWeight   float64 `json:"current_weight"`
	WeightChange    float64 `json:"weight_change"`
	StartChest      float64 `json:"start_chest"`
	CurrentChest    float64 `json:"current_chest"`
	ChestChange     float64 `json:"chest_change"`
	StartWaist      float64 `json:"start_waist"`
	CurrentWaist    float64 `json:"current_waist"`
	WaistChange     float64 `json:"waist_change"`
	StartHips       float64 `json:"start_hips"`
	CurrentHips     float64 `json:"current_hips"`
	HipsChange      float64 `json:"hips_change"`
	StartBiceps     float64 `json:"start_biceps"`
	CurrentBiceps   float64 `json:"current_biceps"`
	BicepsChange    float64 `json:"biceps_change"`
	StartThigh      float64 `json:"start_thigh"`
	CurrentThigh    float64 `json:"current_thigh"`
	ThighChange     float64 `json:"thigh_change"`
}

type MeasurementStats struct {
	Date    time.Time `json:"date"`
	Weight  float64   `json:"weight"`
	Chest   float64   `json:"chest"`
	Waist   float64   `json:"waist"`
	Hips    float64   `json:"hips"`
	Biceps  float64   `json:"biceps"`
	Thigh   float64   `json:"thigh"`
}

func CreateProgress(userID uint, date time.Time, weight, chest, waist, hips, biceps, thigh float64, notes string) (*Progress, error) {
	var id uint
	err := db.DB.QueryRow(
		`INSERT INTO progress (user_id, date, weight, chest, waist, hips, biceps, thigh, notes) 
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id`,
		userID, date, weight, chest, waist, hips, biceps, thigh, notes,
	).Scan(&id)
	if err != nil {
		return nil, err
	}

	return &Progress{
		ID:     id,
		UserID: userID,
		Date:   date,
		Weight: weight,
		Chest:  chest,
		Waist:  waist,
		Hips:   hips,
		Biceps: biceps,
		Thigh:  thigh,
		Notes:  notes,
	}, nil
}

func GetUserProgress(userID uint) ([]Progress, error) {
	rows, err := db.DB.Query(
		`SELECT id, user_id, date, weight, chest, waist, hips, biceps, thigh, notes 
		FROM progress 
		WHERE user_id = $1 
		ORDER BY date DESC`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var progress []Progress
	for rows.Next() {
		var p Progress
		err := rows.Scan(&p.ID, &p.UserID, &p.Date, &p.Weight, &p.Chest, &p.Waist, &p.Hips, &p.Biceps, &p.Thigh, &p.Notes)
		if err != nil {
			return nil, err
		}
		progress = append(progress, p)
	}
	return progress, nil
}

func GetUserProgressStats(userID uint, startDate, endDate time.Time) (*ProgressStats, error) {
	var stats ProgressStats

	// Проверяем наличие записей за период
	var count int
	err := db.DB.QueryRow(
		`SELECT COUNT(*) 
		FROM progress 
		WHERE user_id = $1 AND date >= $2 AND date <= $3`,
		userID, startDate, endDate,
	).Scan(&count)
	if err != nil {
		return nil, err
	}

	// Если записей нет, возвращаем нулевые значения
	if count == 0 {
		return &ProgressStats{}, nil
	}

	// Получаем первую запись за период
	err = db.DB.QueryRow(
		`SELECT weight, chest, waist, hips, biceps, thigh 
		FROM progress 
		WHERE user_id = $1 AND date >= $2 AND date <= $3 
		ORDER BY date ASC LIMIT 1`,
		userID, startDate, endDate,
	).Scan(&stats.StartWeight, &stats.StartChest, &stats.StartWaist, &stats.StartHips, &stats.StartBiceps, &stats.StartThigh)
	if err != nil {
		return nil, err
	}

	// Получаем последнюю запись за период
	err = db.DB.QueryRow(
		`SELECT weight, chest, waist, hips, biceps, thigh 
		FROM progress 
		WHERE user_id = $1 AND date >= $2 AND date <= $3 
		ORDER BY date DESC LIMIT 1`,
		userID, startDate, endDate,
	).Scan(&stats.CurrentWeight, &stats.CurrentChest, &stats.CurrentWaist, &stats.CurrentHips, &stats.CurrentBiceps, &stats.CurrentThigh)
	if err != nil {
		return nil, err
	}

	// Вычисляем изменения
	stats.WeightChange = stats.CurrentWeight - stats.StartWeight
	stats.ChestChange = stats.CurrentChest - stats.StartChest
	stats.WaistChange = stats.CurrentWaist - stats.StartWaist
	stats.HipsChange = stats.CurrentHips - stats.StartHips
	stats.BicepsChange = stats.CurrentBiceps - stats.StartBiceps
	stats.ThighChange = stats.CurrentThigh - stats.StartThigh

	return &stats, nil
}

func GetUserProgressData(userID uint, startDate, endDate time.Time) ([]MeasurementStats, error) {
	// Проверяем наличие записей за период
	var count int
	err := db.DB.QueryRow(
		`SELECT COUNT(*) 
		FROM progress 
		WHERE user_id = $1 AND date >= $2 AND date <= $3`,
		userID, startDate, endDate,
	).Scan(&count)
	if err != nil {
		return nil, err
	}

	// Если записей нет, возвращаем пустой массив
	if count == 0 {
		return []MeasurementStats{}, nil
	}

	rows, err := db.DB.Query(
		`SELECT date, weight, chest, waist, hips, biceps, thigh 
		FROM progress 
		WHERE user_id = $1 AND date >= $2 AND date <= $3 
		ORDER BY date ASC`,
		userID, startDate, endDate,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var stats []MeasurementStats
	for rows.Next() {
		var s MeasurementStats
		err := rows.Scan(&s.Date, &s.Weight, &s.Chest, &s.Waist, &s.Hips, &s.Biceps, &s.Thigh)
		if err != nil {
			return nil, err
		}
		stats = append(stats, s)
	}
	return stats, nil
} 