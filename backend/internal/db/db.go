package db

import (
	"database/sql"
	"fmt"
	_ "github.com/lib/pq"
	"os"
)

var DB *sql.DB

func InitDB(host, port, user, password, dbname string) error {
	connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		host, port, user, password, dbname)

	var err error
	DB, err = sql.Open("postgres", connStr)
	if err != nil {
		return err
	}

	if err = DB.Ping(); err != nil {
		return err
	}

	sqlFile, err := os.ReadFile("/app/internal/db/init.sql")
	if err != nil {
		return err
	}

	_, err = DB.Exec(string(sqlFile))
	return err
}

func createTables() error {
	query := `
    CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        name VARCHAR(255) NOT NULL
    )`

	_, err := DB.Exec(query)
	return err
} 