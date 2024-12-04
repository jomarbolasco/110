DROP TABLE IF EXISTS Patient CASCADE;
DROP TABLE IF EXISTS Admin CASCADE;
DROP TABLE IF EXISTS Hospitals CASCADE;
DROP TABLE IF EXISTS Doctors CASCADE;
DROP TABLE IF EXISTS Availability CASCADE;
DROP TABLE IF EXISTS Schedule CASCADE;
DROP TABLE IF EXISTS Appointments CASCADE;
DROP TABLE IF EXISTS Symptoms CASCADE;


-- Table: Patient
CREATE TABLE Patient (
    p_id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    check_up_type TEXT NOT NULL,
    CONSTRAINT fk_user FOREIGN KEY (p_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Table: Admin
CREATE TABLE Admin (
    a_id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    CONSTRAINT fk_user FOREIGN KEY (a_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Table: Hospitals
CREATE TABLE Hospitals (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    address TEXT NOT NULL,
    contact_number VARCHAR(15)
);

-- Table: Doctors
CREATE TABLE Doctors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100),
    hospital_id INT NOT NULL,
    contact_number VARCHAR(15),
    CONSTRAINT fk_hospital_doctor FOREIGN KEY (hospital_id) REFERENCES Hospitals(id) ON DELETE CASCADE
);

-- Table: Availability
CREATE TABLE Availability (
    d_id SERIAL PRIMARY KEY,
    status TEXT NOT NULL,
    slots INT NOT NULL,
    CONSTRAINT fk_doctor_availability FOREIGN KEY (d_id) REFERENCES Doctors(id) ON DELETE CASCADE
);

-- Table: Schedule
CREATE TABLE Schedule (
    id SERIAL PRIMARY KEY,
    doctor_id INT NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    available_slots INT NOT NULL,
    CONSTRAINT fk_schedule_doctor FOREIGN KEY (doctor_id) REFERENCES Doctors(id) ON DELETE CASCADE
);

-- Table: Appointments
CREATE TABLE Appointments (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_appointments FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    CONSTRAINT fk_doctor_appointments FOREIGN KEY (doctor_id) REFERENCES Doctors(id) ON DELETE CASCADE
);

-- Table: Symptoms
CREATE TABLE Symptoms (
    id SERIAL PRIMARY KEY,
    appointment_id INT NOT NULL,
    symptoms_list TEXT NOT NULL,
    others TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_appointment_symptoms FOREIGN KEY (appointment_id) REFERENCES Appointments(id) ON DELETE CASCADE
);

-- Additional Query
SELECT * FROM Appointments WHERE user_id IS NOT NULL;
