-- No need for a separate Users table
-- Medical Staff table for doctors and nurses
CREATE TABLE MedicalStaff (
    staff_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    role staff_role,
    specialization VARCHAR(100),
    available_slots INT
);

-- Appointments table for managing appointments
CREATE TABLE Appointments (
    appointment_id SERIAL PRIMARY KEY,
    user_id UUID,  -- Using UUID for user_id to match with Supabase Auth user IDs
    staff_id INT,
    appointment_date DATE,
    appointment_time TIME,
    status appointment_status,
    FOREIGN KEY (user_id) REFERENCES auth.users(id),  -- Directly referencing auth.users
    FOREIGN KEY (staff_id) REFERENCES MedicalStaff(staff_id)
);

-- Schedules table for managing schedules
CREATE TABLE Schedules (
    schedule_id SERIAL PRIMARY KEY,
    staff_id INT,
    date DATE,
    start_time TIME,
    end_time TIME,
    slots INT,
    FOREIGN KEY (staff_id) REFERENCES MedicalStaff(staff_id)
);
