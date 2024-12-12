-- Creating the Patients table
CREATE TABLE Patients (
    patient_id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),  -- Assuming users are managed by Supabase Auth
    name VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(10),
    phone_number VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating the Medical_Staff table
CREATE TABLE Medical_Staff (
    staff_id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),  -- Assuming users are managed by Supabase Auth
    role VARCHAR(50) NOT NULL,  -- e.g., doctor, nurse
    specialization VARCHAR(255),  -- optional
    phone_number VARCHAR(20),
    available_hours JSONB,  -- JSON for flexible scheduling
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    name VARCHAR(255) NOT NULL
);

-- Creating the Appointment_Types table
CREATE TABLE Appointment_Types (
    appointment_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating the Appointments table
CREATE TABLE Appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES Patients(patient_id),
    staff_id INT REFERENCES Medical_Staff(staff_id),
    appointment_date_time TIMESTAMP NOT NULL,
    appointment_type_id INT REFERENCES Appointment_Types(appointment_type_id),
    reason TEXT,
    status VARCHAR(50) DEFAULT 'scheduled',
    booked_by_user_id UUID REFERENCES auth.users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating the Schedules table
CREATE TABLE Schedules (
    schedule_id SERIAL PRIMARY KEY,
    staff_id INT REFERENCES Medical_Staff(staff_id),
    appointment_type_id INT REFERENCES Appointment_Types(appointment_type_id),
    day_of_week VARCHAR(10) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE Appointments
ADD COLUMN schedule_id INT REFERENCES Schedules(schedule_id);
