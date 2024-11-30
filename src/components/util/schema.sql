-- Enable the `pgcrypto` extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Table: Users
CREATE TABLE Users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: Patient
CREATE TABLE Patient (
    p_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    check_up_type TEXT NOT NULL
);

-- Table: Admin
CREATE TABLE Admin (
    a_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL
);

-- Table: Hospitals
CREATE TABLE Hospitals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(150) NOT NULL,
    address TEXT NOT NULL,
    contact_number VARCHAR(15)
);

-- Table: Doctors
CREATE TABLE Doctors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100),
    hospital_id UUID NOT NULL,
    contact_number VARCHAR(15),
    CONSTRAINT fk_hospital_doctor FOREIGN KEY (hospital_id)
        REFERENCES Hospitals (id) ON DELETE CASCADE
);

-- Table: Availability
CREATE TABLE Availability (
    d_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status TEXT NOT NULL,
    slots INT NOT NULL,
    CONSTRAINT fk_doctor_availability FOREIGN KEY (d_id)
        REFERENCES Doctors (id) ON DELETE CASCADE
);

-- Table: Schedule
CREATE TABLE Schedule (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    doctor_id UUID NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    available_slots INT NOT NULL,
    CONSTRAINT fk_schedule_doctor FOREIGN KEY (doctor_id)
        REFERENCES Doctors (id) ON DELETE CASCADE
);

-- Table: Appointments
CREATE TABLE Appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    doctor_id UUID NOT NULL,
    appointment_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_appointments FOREIGN KEY (user_id)
        REFERENCES Patient (p_id) ON DELETE CASCADE,
    CONSTRAINT fk_doctor_appointments FOREIGN KEY (doctor_id)
        REFERENCES Doctors (id) ON DELETE CASCADE
);

-- Table: Symptoms
CREATE TABLE Symptoms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID NOT NULL,
    symptoms_list TEXT NOT NULL,
    others TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_appointment_symptoms FOREIGN KEY (appointment_id)
        REFERENCES Appointments (id) ON DELETE CASCADE
);

-- Relationships
ALTER TABLE Patient
ADD CONSTRAINT fk_user FOREIGN KEY (p_id)
REFERENCES Users (id) ON DELETE CASCADE;

ALTER TABLE Admin
ADD CONSTRAINT fk_user FOREIGN KEY (a_id)
REFERENCES Users (id) ON DELETE CASCADE;


added
ALTER TABLE "Users"
ADD COLUMN role VARCHAR(255);
