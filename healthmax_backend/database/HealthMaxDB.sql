CREATE TABLE
    Users (
        id UUID PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
        username VARCHAR(50) UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        gender VARCHAR(10),
        dob DATE,
        height_cm DECIMAL(5, 2),
        weight_kg DECIMAL(5, 2),
        total_points INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

ALTER TABLE Users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage their own profiles" ON Users FOR ALL USING (auth.uid () = = id)
WITH
    CHECK (auth.uid () = id);

CREATE TABLE
    Hospitals (
        hospital_id SERIAL PRIMARY KEY,
        hospital_name VARCHAR(100) NOT NULL,
        location VARCHAR(255),
        contact_info VARCHAR(100)
    );

CREATE TABLE
    HealthLogs (
        log_id SERIAL PRIMARY KEY,
        username VARCHAR(50) REFERENCES Users (username) ON DELETE CASCADE,
        metric_type VARCHAR(20), -- e.g., 'heart_rate', 'glucose', 'steps'
        value DECIMAL(10, 2),
        recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

CREATE TABLE
    FoodLogs (
        log_id SERIAL PRIMARY KEY,
        username VARCHAR(50) REFERENCES Users (username) ON DELETE CASCADE,
        food_name VARCHAR(100),
        calories INT,
        logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

CREATE TABLE
    UserTargets (
        target_id SERIAL PRIMARY KEY,
        username VARCHAR(50) REFERENCES Users (username) ON DELETE CASCADE,
        metric_name VARCHAR(20), -- e.g., 'daily_steps', 'target_weight'
        target_value DECIMAL(10, 2),
        current_progress DECIMAL(10, 2) DEFAULT 0,
        is_completed BOOLEAN DEFAULT FALSE
    );

CREATE TABLE
    ConnectedDevices (
        device_id SERIAL PRIMARY KEY,
        username VARCHAR(50) REFERENCES Users (username) ON DELETE CASCADE,
        device_name VARCHAR(100), -- e.g., 'Ahmad's Smartwatch'
        last_sync TIMESTAMP
    );

CREATE TABLE
    DeviceSettings (
        setting_id SERIAL PRIMARY KEY,
        device_id INT REFERENCES ConnectedDevices (device_id) ON DELETE CASCADE,
        metric_to_sync VARCHAR(20), -- e.g., 'heart_rate'
        is_active BOOLEAN DEFAULT TRUE
    );

CREATE TABLE
    HospitalFeedback (
        feedback_id SERIAL PRIMARY KEY,
        hospital_id INT REFERENCES Hospitals (hospital_id),
        username VARCHAR(50) REFERENCES Users (username) ON DELETE CASCADE,
        feedback_text TEXT,
        medical_advice TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );