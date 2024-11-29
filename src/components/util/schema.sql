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
