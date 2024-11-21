CREATE TABLE "Users" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(100) NOT NULL,
  "email" VARCHAR(150) UNIQUE NOT NULL,
  "password_hash" TEXT NOT NULL,
  "created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "Patient" (
  "p_id" SERIAL PRIMARY KEY,
  "name" VARCHAR(100) NOT NULL,
  "check_up_type" TEXT NOT NULL
);

CREATE TABLE "Admin" (
  "a_id" SERIAL PRIMARY KEY,
  "name" VARCHAR(100) NOT NULL
);

CREATE TABLE "Hospitals" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(150) NOT NULL,
  "address" TEXT NOT NULL,
  "contact_number" VARCHAR(15)
);

CREATE TABLE "Doctors" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(100) NOT NULL,
  "specialty" VARCHAR(100),
  "hospital_id" INT NOT NULL,
  "contact_number" VARCHAR(15)
);

CREATE TABLE "Availability" (
  "d_id" SERIAL PRIMARY KEY,
  "status" TEXT NOT NULL,
  "slots" INT NOT NULL
);

CREATE TABLE "Schedule" (
  "id" SERIAL PRIMARY KEY,
  "doctor_id" INT NOT NULL,
  "date" DATE NOT NULL,
  "start_time" TIME NOT NULL,
  "end_time" TIME NOT NULL,
  "available_slots" INT NOT NULL
);

CREATE TABLE "Appointments" (
  "id" SERIAL PRIMARY KEY,
  "user_id" INT NOT NULL,
  "doctor_id" INT NOT NULL,
  "appointment_date" DATE NOT NULL,
  "status" VARCHAR(50) DEFAULT 'Pending',
  "created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "Symptoms" (
  "id" SERIAL PRIMARY KEY,
  "appointment_id" INT NOT NULL,
  "symptoms_list" TEXT NOT NULL,
  "others" TEXT,
  "created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

ALTER TABLE "Patient" ADD CONSTRAINT "fk_user" FOREIGN KEY ("p_id") REFERENCES "Users" ("id") ON DELETE CASCADE;

ALTER TABLE "Admin" ADD CONSTRAINT "fk_user" FOREIGN KEY ("a_id") REFERENCES "Users" ("id") ON DELETE CASCADE;

ALTER TABLE "Doctors" ADD CONSTRAINT "fk_hospital_doctor" FOREIGN KEY ("hospital_id") REFERENCES "Hospitals" ("id") ON DELETE CASCADE;

ALTER TABLE "Availability" ADD CONSTRAINT "fk_doctor_availability" FOREIGN KEY ("d_id") REFERENCES "Doctors" ("id") ON DELETE CASCADE;

ALTER TABLE "Schedule" ADD CONSTRAINT "fk_schedule_doctor" FOREIGN KEY ("doctor_id") REFERENCES "Doctors" ("id") ON DELETE CASCADE;

ALTER TABLE "Appointments" ADD CONSTRAINT "fk_user_appointments" FOREIGN KEY ("user_id") REFERENCES "Patient" ("p_id") ON DELETE CASCADE;

ALTER TABLE "Appointments" ADD CONSTRAINT "fk_doctor_appointments" FOREIGN KEY ("doctor_id") REFERENCES "Doctors" ("id") ON DELETE CASCADE;

ALTER TABLE "Symptoms" ADD CONSTRAINT "fk_appointment_symptoms" FOREIGN KEY ("appointment_id") REFERENCES "Appointments" ("id") ON DELETE CASCADE;
