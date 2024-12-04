-- Users
INSERT INTO Users (name, email, password_hash)
VALUES 
('Alice Johnson', 'alice@example.com', 'hashed_password_1'),
('Bob Smith', 'bob@example.com', 'hashed_password_2'),
('Charlie Davis', 'charlie@example.com', 'hashed_password_3');

-- Patient
INSERT INTO Patient (name, check_up_type)
VALUES
('Alice Johnson', 'General Check-up'),
('Emily Brown', 'Dental Check-up'),
('John Doe', 'Eye Check-up');

-- Admin
INSERT INTO Admin (name)
VALUES
('Super Admin'),
('Clinic Manager');

-- Hospitals
INSERT INTO Hospitals (name, address, contact_number)
VALUES
('City General Hospital', '123 Main Street, Metro City', '123-456-7890'),
('Metro Dental Clinic', '45 Elm Street, Metro City', '123-456-7891'),
('Vision Care Center', '78 Oak Avenue, Metro City', '123-456-7892');

-- Doctors
INSERT INTO Doctors (name, specialty, hospital_id, contact_number)
VALUES
('Dr. Sarah Adams', 'Cardiologist', 1, '321-654-0987'),
('Dr. Michael Lee', 'Dentist', 2, '321-654-0988'),
('Dr. Jessica Tan', 'Ophthalmologist', 3, '321-654-0989');

-- Availability
INSERT INTO Availability (d_id, status, slots)
VALUES
(1, 'Available', 5),
(2, 'Available', 3),
(3, 'Unavailable', 0);

-- Schedule
INSERT INTO Schedule (doctor_id, date, start_time, end_time, available_slots)
VALUES
(1, '2024-12-01', '09:00:00', '12:00:00', 5),
(2, '2024-12-01', '10:00:00', '14:00:00', 3),
(3, '2024-12-02', '08:00:00', '11:00:00', 2);

-- Appointments
INSERT INTO Appointments (user_id, doctor_id, appointment_date, status)
VALUES
(1, 1, '2024-12-01', 'Pending'),
(2, 2, '2024-12-01', 'Confirmed'),
(3, 3, '2024-12-02', 'Pending');
