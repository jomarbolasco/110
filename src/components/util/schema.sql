-- Create the staff_role type if it doesn't exist
DO $$ BEGIN
    CREATE TYPE staff_role AS ENUM ('doctor', 'nurse');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create the appointment_status type if it doesn't exist
DO $$ BEGIN
    CREATE TYPE appointment_status AS ENUM ('reserved', 'cancelled', 'completed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create medicalstaff table
CREATE TABLE IF NOT EXISTS medicalstaff (
    staff_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    role staff_role,
    specialization VARCHAR(100),
    available_slots INT
);

-- Create schedules table
CREATE TABLE IF NOT EXISTS schedules (
    schedule_id SERIAL PRIMARY KEY,
    staff_id INT,
    date DATE,
    start_time TIME,
    end_time TIME,
    slots INT,
    FOREIGN KEY (staff_id) REFERENCES medicalstaff(staff_id)
);

-- Create appointments table
CREATE TABLE IF NOT EXISTS appointments (
    appointment_id SERIAL PRIMARY KEY,
    user_id UUID,  -- Using UUID for user_id to match with Supabase Auth user IDs
    staff_id INT,
    appointment_date DATE,
    appointment_time TIME,
    status appointment_status,
    FOREIGN KEY (user_id) REFERENCES auth.users(id),  -- Directly referencing auth.users
    FOREIGN KEY (staff_id) REFERENCES medicalstaff(staff_id)
);

-- Second phase (adding AI chat bot) to be removing concept!

-- Create user_queries table
CREATE TABLE IF NOT EXISTS user_queries (
    query_id SERIAL PRIMARY KEY,
    user_id UUID,  -- Using UUID for user_id to match with Supabase Auth user IDs
    query_text TEXT NOT NULL,
    query_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES auth.users(id)
);

-- Create ai_responses table
CREATE TABLE IF NOT EXISTS ai_responses (
    response_id SERIAL PRIMARY KEY,
    query_id INT,
    response_text TEXT NOT NULL,
    response_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (query_id) REFERENCES user_queries(query_id)
);


--  Revised Schema Queries

-- Add available_slots to schedules
ALTER TABLE schedules ADD COLUMN available_slots INT DEFAULT 10;

-- Prevent overbooking
ALTER TABLE appointments
ADD CONSTRAINT unique_user_slot UNIQUE (user_id, appointment_date, appointment_time);

-- Ensure appointment slots are valid
ALTER TABLE schedules
ADD CONSTRAINT slots_positive CHECK (available_slots >= 0);
