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




-- 



ALTER TABLE appointments
ADD CONSTRAINT fk_user
FOREIGN KEY (user_id)
REFERENCES auth.users (id);

SET search_path TO public, auth;




CREATE OR REPLACE FUNCTION get_appointments_with_user_details()
RETURNS TABLE (
    appointment_id INT,
    user_id UUID,
    staff_id INT,
    appointment_date DATE,
    appointment_time TIME,
    status appointment_status,
    user_email VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.appointment_id,
        a.user_id,
        a.staff_id,
        a.appointment_date,
        a.appointment_time,
        a.status,
        u.email AS user_email
    FROM 
        appointments a
    JOIN 
        auth.users u ON a.user_id = u.id;
END;
$$ LANGUAGE plpgsql;



GRANT SELECT ON auth.users TO service_role;



CREATE OR REPLACE VIEW appointments_with_user_details AS
SELECT 
    a.appointment_id,
    a.user_id,
    a.staff_id,
    a.appointment_date,
    a.appointment_time,
    a.status,
    u.email AS user_email
FROM 
    appointments a
JOIN 
    auth.users u ON a.user_id = u.id;


GRANT SELECT ON appointments_with_user_details TO service_role;
