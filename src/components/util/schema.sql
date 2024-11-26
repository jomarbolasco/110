-- Create Users Table
CREATE TABLE "Users" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(100) NOT NULL,
  "email" VARCHAR(150) UNIQUE NOT NULL,
  "password_hash" TEXT NOT NULL,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "role" VARCHAR(50) DEFAULT 'Patient'
);

-- Create Patient Table
CREATE TABLE "Patient" (
  "p_id" SERIAL PRIMARY KEY,
  "name" VARCHAR(100) NOT NULL,
  "check_up_type" TEXT NOT NULL
);

-- Create Admin Table
CREATE TABLE "Admin" (
  "a_id" SERIAL PRIMARY KEY,
  "name" VARCHAR(100) NOT NULL
);

-- Create Hospitals Table
CREATE TABLE "Hospitals" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(150) NOT NULL,
  "address" TEXT NOT NULL,
  "contact_number" VARCHAR(15)
);

-- Create Doctors Table
CREATE TABLE "Doctors" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(100) NOT NULL,
  "specialty" VARCHAR(100),
  "hospital_id" INT NOT NULL,
  "contact_number" VARCHAR(15),
  CONSTRAINT "fk_hospital_doctor" FOREIGN KEY ("hospital_id") REFERENCES "Hospitals" ("id") ON DELETE CASCADE
);

-- Create Availability Table
CREATE TABLE "Availability" (
  "d_id" SERIAL PRIMARY KEY,
  "status" TEXT NOT NULL,
  "slots" INT NOT NULL,
  CONSTRAINT "fk_doctor_availability" FOREIGN KEY ("d_id") REFERENCES "Doctors" ("id") ON DELETE CASCADE
);

-- Create Schedule Table
CREATE TABLE "Schedule" (
  "id" SERIAL PRIMARY KEY,
  "doctor_id" INT NOT NULL,
  "date" DATE NOT NULL,
  "start_time" TIME NOT NULL,
  "end_time" TIME NOT NULL,
  "available_slots" INT NOT NULL,
  CONSTRAINT "fk_schedule_doctor" FOREIGN KEY ("doctor_id") REFERENCES "Doctors" ("id") ON DELETE CASCADE
);

-- Create Appointments Table
CREATE TABLE "Appointments" (
  "id" SERIAL PRIMARY KEY,
  "user_id" INT NOT NULL,
  "doctor_id" INT NOT NULL,
  "appointment_date" DATE NOT NULL,
  "status" VARCHAR(50) DEFAULT 'Pending',
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "fk_user_appointments" FOREIGN KEY ("user_id") REFERENCES "Patient" ("p_id") ON DELETE CASCADE,
  CONSTRAINT "fk_doctor_appointments" FOREIGN KEY ("doctor_id") REFERENCES "Doctors" ("id") ON DELETE CASCADE
);

-- Create Symptoms Table
CREATE TABLE "Symptoms" (
  "id" SERIAL PRIMARY KEY,
  "appointment_id" INT NOT NULL,
  "symptoms_list" TEXT NOT NULL,
  "others" TEXT,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "fk_appointment_symptoms" FOREIGN KEY ("appointment_id") REFERENCES "Appointments" ("id") ON DELETE CASCADE
);
