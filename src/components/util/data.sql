-- Insert sample data into Users table
INSERT INTO "Users" ("name", "email", "password_hash", "role")
VALUES 
  ('John Doe', 'johndoe@example.com', 'hashedpassword1', 'Patient'),
  ('Jane Smith', 'janesmith@example.com', 'hashedpassword2', 'Admin');
-- Insert sample data into Patient table
INSERT INTO "Patient" ("name", "check_up_type")
VALUES 
  ('John Doe', 'General Checkup'),
  ('Mary Johnson', 'Pediatric Checkup');
-- Insert sample data into Admin table
INSERT INTO "Admin" ("name")
VALUES 
  ('Jane Smith');
-- Insert sample data into Hospitals table
INSERT INTO "Hospitals" ("name", "address", "contact_number")
VALUES 
  ('St. Mary’s Hospital', '1234 Health St, Butuan City', '09123456789'),
  ('City Medical Center', '5678 Wellness Rd, Butuan City', '09187654321');
-- Insert sample data into Doctors table
INSERT INTO "Doctors" ("name", "specialty", "hospital_id", "contact_number")
VALUES 
  ('Dr. Alice Brown', 'Cardiologist', 1, '09123459988'),
  ('Dr. Bob White', 'Pediatrician', 2, '09187659987');
-- Insert sample data into Availability table
INSERT INTO "Availability" ("status", "slots")
VALUES 
  ('Available', 10),
  ('Not Available', 0);
-- Insert sample data into Schedule table
INSERT INTO "Schedule" ("doctor_id", "date", "start_time", "end_time", "available_slots")
VALUES 
  (1, '2024-12-01', '08:00:00', '12:00:00', 5),
  (2, '2024-12-02', '09:00:00', '13:00:00', 8);
-- Insert sample data into Appointments table
INSERT INTO "Appointments" ("user_id", "doctor_id", "appointment_date", "status")
VALUES 
  (1, 1, '2024-12-01', 'Pending'),
  (2, 2, '2024-12-02', 'Pending');
-- Insert sample data into Symptoms table
INSERT INTO "Symptoms" ("appointment_id", "symptoms_list", "others")
VALUES 
  (1, 'Headache, Fever', 'N/A'),
  (2, 'Cough, Cold', 'Sore Throat');
