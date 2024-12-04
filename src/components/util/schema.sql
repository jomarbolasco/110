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
