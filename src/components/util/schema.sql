-- Create Users Table (UUID as primary key)
CREATE TABLE Users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- UUID for user ID
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  role VARCHAR(50) DEFAULT 'Patient'
);

-- Create Hospitals Table
CREATE TABLE Hospitals (
  id SERIAL PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  address TEXT NOT NULL,
  contact_number VARCHAR(15)
);

-- Create Doctors Table (UUID as primary key, linked to Hospitals)
CREATE TABLE Doctors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  specialty VARCHAR(100),
  hospital_id INT NOT NULL,
  contact_number VARCHAR(15),
  FOREIGN KEY (hospital_id) REFERENCES Hospitals (id) ON DELETE CASCADE
);

-- Create Schedule Table for Doctor Availability
CREATE TABLE Schedule (
  id SERIAL PRIMARY KEY,
  doctor_id UUID NOT NULL,
  date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  available_slots INT NOT NULL,
  FOREIGN KEY (doctor_id) REFERENCES Doctors (id) ON DELETE CASCADE
);

-- Create Appointments Table (user_id linked to Users, doctor_id linked to Doctors)
CREATE TABLE Appointments (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL,
  doctor_id UUID NOT NULL,
  appointment_date DATE NOT NULL,
  appointment_time TIME NOT NULL,
  status VARCHAR(50) DEFAULT 'Pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE CASCADE,
  FOREIGN KEY (doctor_id) REFERENCES Doctors (id) ON DELETE CASCADE
);

-- Create Symptoms Table for Appointment Details
CREATE TABLE Symptoms (
  id SERIAL PRIMARY KEY,
  appointment_id INT NOT NULL,
  symptoms_list TEXT NOT NULL,
  others TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (appointment_id) REFERENCES Appointments (id) ON DELETE CASCADE
);

-- Create Admin Table (linked to Users)
CREATE TABLE Admin (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL,
  FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE CASCADE
);

-- Create Patient Table (linked to Users)
CREATE TABLE Patient (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL,
  check_up_type TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE CASCADE
);


-- Inserting Users (Patients and Admin)
INSERT INTO Users (id, name, email, password_hash, role)
VALUES
  (gen_random_uuid(), 'John Doe', 'john.doe@example.com', 'hashedpassword123', 'Patient'),
  (gen_random_uuid(), 'Jane Smith', 'jane.smith@example.com', 'hashedpassword456', 'Patient'),
  (gen_random_uuid(), 'Alice Brown', 'alice.brown@example.com', 'hashedpassword789', 'Admin');
-- Inserting Hospitals
INSERT INTO Hospitals (name, address, contact_number)
VALUES
  ('Greenwood Hospital', '123 Greenwood St, Cityville', '555-1234'),
  ('Sunrise Medical Center', '456 Sunrise Ave, Townsville', '555-5678');
-- Inserting Doctors
INSERT INTO Doctors (id, name, specialty, hospital_id, contact_number)
VALUES
  (gen_random_uuid(), 'Dr. Emily White', 'Cardiologist', 1, '555-2345'),
  (gen_random_uuid(), 'Dr. Michael Green', 'Pediatrician', 1, '555-6789'),
  (gen_random_uuid(), 'Dr. Sarah Blue', 'Neurologist', 2, '555-9876');
-- Inserting Doctor Schedules
INSERT INTO Schedule (doctor_id, date, start_time, end_time, available_slots)
VALUES
  ((SELECT id FROM Doctors WHERE name = 'Dr. Emily White'), '2024-12-01', '09:00', '12:00', 5),
  ((SELECT id FROM Doctors WHERE name = 'Dr. Michael Green'), '2024-12-02', '10:00', '13:00', 4),
  ((SELECT id FROM Doctors WHERE name = 'Dr. Sarah Blue'), '2024-12-03', '08:00', '11:00', 3);
-- Inserting Appointments
INSERT INTO Appointments (user_id, doctor_id, appointment_date, appointment_time, status)
VALUES
  ((SELECT id FROM Users WHERE name = 'John Doe'), (SELECT id FROM Doctors WHERE name = 'Dr. Emily White'), '2024-12-01', '09:30', 'Pending'),
  ((SELECT id FROM Users WHERE name = 'Jane Smith'), (SELECT id FROM Doctors WHERE name = 'Dr. Michael Green'), '2024-12-02', '11:00', 'Pending');
-- Inserting Symptoms for Appointments
INSERT INTO Symptoms (appointment_id, symptoms_list, others)
VALUES
  ((SELECT id FROM Appointments WHERE user_id = (SELECT id FROM Users WHERE name = 'John Doe') AND doctor_id = (SELECT id FROM Doctors WHERE name = 'Dr. Emily White')), 'Chest pain, Shortness of breath', 'None'),
  ((SELECT id FROM Appointments WHERE user_id = (SELECT id FROM Users WHERE name = 'Jane Smith') AND doctor_id = (SELECT id FROM Doctors WHERE name = 'Dr. Michael Green')), 'Fever, Cough', 'Cold symptoms');
-- Inserting Admin (linked to Users)
INSERT INTO Admin (user_id)
VALUES
  ((SELECT id FROM Users WHERE name = 'Alice Brown'));
-- Inserting Patient (linked to Users)
INSERT INTO Patient (user_id, check_up_type)
VALUES
  ((SELECT id FROM Users WHERE name = 'John Doe'), 'Annual Check-up'),
  ((SELECT id FROM Users WHERE name = 'Jane Smith'), 'General Consultation');
