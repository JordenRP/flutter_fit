CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS workouts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    date TIMESTAMP NOT NULL,
    type VARCHAR(255) NOT NULL,
    duration INTEGER NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS nutrition (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    date TIMESTAMP NOT NULL,
    meal_type VARCHAR(255) NOT NULL,
    food_name VARCHAR(255) NOT NULL,
    calories INTEGER NOT NULL,
    proteins DECIMAL(5,2) NOT NULL,
    fats DECIMAL(5,2) NOT NULL,
    carbs DECIMAL(5,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS progress (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    date TIMESTAMP NOT NULL,
    weight DECIMAL(5,2),       -- вес в кг
    chest DECIMAL(5,2),        -- обхват груди в см
    waist DECIMAL(5,2),        -- обхват талии в см
    hips DECIMAL(5,2),         -- обхват бедер в см
    biceps DECIMAL(5,2),       -- обхват бицепса в см
    thigh DECIMAL(5,2),        -- обхват бедра в см
    notes TEXT
);

CREATE TABLE IF NOT EXISTS training_plans (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    days JSONB NOT NULL        -- массив дней с упражнениями
);

CREATE TABLE IF NOT EXISTS meal_plans (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    days JSONB NOT NULL        -- массив дней с приемами пищи
);

CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
); 