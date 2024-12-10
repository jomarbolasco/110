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



-- regenerate 

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
    available_slots INT DEFAULT 10,
    FOREIGN KEY (staff_id) REFERENCES medicalstaff(staff_id)
);

-- Create appointments table
CREATE TABLE IF NOT EXISTS appointments (
    appointment_id SERIAL PRIMARY KEY,
    user_id UUID,
    staff_id INT,
    appointment_date DATE,
    appointment_time TIME,
    status appointment_status,
    FOREIGN KEY (user_id) REFERENCES auth.users(id),
    FOREIGN KEY (staff_id) REFERENCES medicalstaff(staff_id),
    CONSTRAINT unique_user_slot UNIQUE (user_id, appointment_date, appointment_time)
);

-- Create user_queries table
CREATE TABLE IF NOT EXISTS user_queries (
    query_id SERIAL PRIMARY KEY,
    user_id UUID,
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

-- Ensure available_slots are non-negative
ALTER TABLE schedules
ADD CONSTRAINT slots_positive CHECK (available_slots >= 0);

-- Additional constraints and function definitions
ALTER TABLE appointments
ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES auth.users(id);

-- Ensure Supabase roles can access data as needed
GRANT SELECT ON auth.users TO service_role;

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

-- new schema

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

-- Create medicalstaff table (existing and updated)
CREATE TABLE IF NOT EXISTS medicalstaff (
    staff_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100),
    role staff_role,
    specialization VARCHAR(100),
    available_slots INT,
    specialty_id UUID REFERENCES specialties(id),
    contact_information VARCHAR(100)
);

-- Create schedules table
CREATE TABLE IF NOT EXISTS schedules (
    schedule_id SERIAL PRIMARY KEY,
    staff_id UUID,
    date DATE,
    start_time TIME,
    end_time TIME,
    slots INT,
    available_slots INT DEFAULT 10,
    FOREIGN KEY (staff_id) REFERENCES medicalstaff(staff_id),
    CHECK (available_slots >= 0)
);

-- Create appointments table (existing and updated)
CREATE TABLE IF NOT EXISTS appointments (
    appointment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    staff_id UUID,
    patient_id UUID,
    relation_type VARCHAR(50),
    appointment_date DATE,
    appointment_time TIME,
    illness_description TEXT,
    condition_id UUID REFERENCES patient_conditions(id),
    specialty_id UUID REFERENCES specialties(id),
    status appointment_status,
    FOREIGN KEY (user_id) REFERENCES auth.users(id),
    FOREIGN KEY (staff_id) REFERENCES medicalstaff(staff_id),
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    CONSTRAINT unique_user_slot UNIQUE (user_id, appointment_date, appointment_time)
);

-- Create user_queries table
CREATE TABLE IF NOT EXISTS user_queries (
    query_id SERIAL PRIMARY KEY,
    user_id UUID,
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

-- Create specialties table
CREATE TABLE IF NOT EXISTS specialties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100),
    description TEXT
);

-- Create patients table
CREATE TABLE IF NOT EXISTS patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id),
    name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    contact_information VARCHAR(100)
);

-- Create patient_conditions table
CREATE TABLE IF NOT EXISTS patient_conditions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES patients(id),
    condition_name VARCHAR(100),
    symptoms TEXT,
    diagnosis TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create available_slots table
CREATE TABLE IF NOT EXISTS available_slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    schedule_id UUID,
    staff_id UUID,
    date DATE,
    start_time TIME,
    end_time TIME,
    is_available BOOLEAN
);

-- Create appointment_history table
CREATE TABLE IF NOT EXISTS appointment_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID REFERENCES appointments(id),
    patient_id UUID REFERENCES patients(id),
    status VARCHAR(50),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Additional constraints and function definitions
ALTER TABLE appointments
ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES auth.users(id);

-- Ensure Supabase roles can access data as needed
GRANT SELECT ON auth.users TO service_role;

-- Function to get appointments with user details
CREATE OR REPLACE FUNCTION get_appointments_with_user_details()
RETURNS TABLE (
    appointment_id UUID,
    user_id UUID,
    staff_id UUID,
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

-- Create a view for appointments with user details
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

-- Grant select on the view to service_role
GRANT SELECT ON appointments_with_user_details TO service_role;

