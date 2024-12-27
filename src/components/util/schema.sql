-- Creating the Patients table
CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    name VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(10),
    phone_number VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating the Medical_Staff table
CREATE TABLE medical_staff (
    staff_id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    specialization VARCHAR(255),
    phone_number VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating the Appointment_Types table
CREATE TABLE appointment_types (
    appointment_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating the Schedules table
CREATE TABLE schedules (
    schedule_id SERIAL PRIMARY KEY,
    staff_id INT REFERENCES medical_staff(staff_id),
    appointment_type_id INT REFERENCES appointment_types(appointment_type_id),
    schedule_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    available_slots INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating the Appointments table 

CREATE TABLE appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id), -- Correct reference
    staff_id INT REFERENCES medical_staff(staff_id), -- Unchanged
    appointment_date_time TIMESTAMP NOT NULL,
    schedule_id INT REFERENCES schedules(schedule_id),
    reason TEXT,
    status VARCHAR(50) DEFAULT 'scheduled',
    booked_by_user_id UUID REFERENCES auth.users(id), -- Remains UUID
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating the Past_Schedules table
CREATE TABLE past_schedules (
    past_schedule_id SERIAL PRIMARY KEY,
    schedule_id INT,
    staff_id INT,
    appointment_type_id INT,
    schedule_date DATE,
    start_time TIME,
    end_time TIME,
    available_slots INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Creating the Past_Appointments table
CREATE TABLE past_appointments (
    past_appointment_id SERIAL PRIMARY KEY,
    appointment_id INT,
    patient_id INT,
    staff_id INT,
    appointment_date_time TIMESTAMP,
    schedule_id INT,
    reason TEXT,
    status VARCHAR(50),
    booked_by_user_id UUID,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

ALTER TABLE schedules
ADD CONSTRAINT fk_staff_id
FOREIGN KEY (staff_id) REFERENCES staff (staff_id);

Alter table appointments
add column name VARCHAR(255);

-- added AI tables

-- Creating the AI_Responses table
CREATE TABLE ai_responses (
    response_id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    question TEXT NOT NULL,
    response TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Altering the Past_Schedules table to add foreign key constraints
ALTER TABLE past_schedules
ADD CONSTRAINT fk_past_schedules_staff_id
FOREIGN KEY (staff_id) REFERENCES medical_staff(staff_id),
ADD CONSTRAINT fk_past_schedules_appointment_type_id
FOREIGN KEY (appointment_type_id) REFERENCES appointment_types(appointment_type_id);

-- Altering the Past_Appointments table to add foreign key constraints
ALTER TABLE past_appointments
ADD CONSTRAINT fk_past_appointments_patient_id
FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
ADD CONSTRAINT fk_past_appointments_staff_id
FOREIGN KEY (staff_id) REFERENCES medical_staff(staff_id),
ADD CONSTRAINT fk_past_appointments_schedule_id
FOREIGN KEY (schedule_id) REFERENCES schedules(schedule_id);