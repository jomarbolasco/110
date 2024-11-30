-- Insert sample data into Users
INSERT INTO Users (name, email, password_hash) VALUES
('John Doe', 'john.doe@example.com', 'hashed_password1'),
('Jane Smith', 'jane.smith@example.com', 'hashed_password2'),
('Admin User', 'admin@example.com', 'hashed_password3');

-- Insert sample data into Admin (links to Users)
INSERT INTO Admin (a_id, name) VALUES
((SELECT id FROM Users WHERE email = 'admin@example.com'), 'Admin User');

-- Insert sample data into Patient (links to Users)
INSERT INTO Patient (p_id, name, check_up_type) VALUES
((SELECT id FROM Users WHERE email = 'john.doe@example.com'), 'John Doe', 'General Checkup'),
((SELECT id FROM Users WHERE email = 'jane.smith@example.com'), 'Jane Smith', 'Dental Checkup');

-- Insert sample data into Hospitals
INSERT INTO Hospitals (name, address, contact_number) VALUES
('City Hospital', '123 Main St, Cityville', '1234567890'),
('Metro Clinic', '456 Elm St, Metro City', '0987654321');

-- Insert sample data into Doctors (links to Hospitals)
INSERT INTO Doctors (name, specialty, hospital_id, contact_number) VALUES
('Dr. Alice Green', 'Cardiology', (SELECT id FROM Hospitals WHERE name = 'City Hospital'), '1112223333'),
('Dr. Bob Brown', 'Dentistry', (SELECT id FROM Hospitals WHERE name = 'Metro Clinic'), '4445556666');

-- Insert sample data into Availability (links to Doctors)
INSERT INTO Availability (d_id, status, slots) VALUES
((SELECT id FROM Doctors WHERE name = 'Dr. Alice Green'), 'Available', 5),
((SELECT id FROM Doctors WHERE name = 'Dr. Bob Brown'), 'Available', 3);

-- Insert sample data into Schedule (links to Doctors)
INSERT INTO Schedule (doctor_id, date, start_time, end_time, available_slots) VALUES
((SELECT id FROM Doctors WHERE name = 'Dr. Alice Green'), '2024-12-01', '09:00:00', '12:00:00', 5),
((SELECT id FROM Doctors WHERE name = 'Dr. Bob Brown'), '2024-12-02', '10:00:00', '13:00:00', 3);

-- Insert sample data into Appointments (links to Patient and Doctors)
INSERT INTO Appointments (user_id, doctor_id, appointment_date) VALUES
((SELECT p_id FROM Patient WHERE name = 'John Doe'), (SELECT id FROM Doctors WHERE name = 'Dr. Alice Green'), '2024-12-01'),
((SELECT p_id FROM Patient WHERE name = 'Jane Smith'), (SELECT id FROM Doctors WHERE name = 'Dr. Bob Brown'), '2024-12-02');

-- Insert sample data into Symptoms (links to Appointments)
INSERT INTO Symptoms (appointment_id, symptoms_list, others) VALUES
((SELECT id FROM Appointments WHERE user_id = (SELECT p_id FROM Patient WHERE name = 'John Doe')), 'Cough, Fever', NULL),
((SELECT id FROM Appointments WHERE user_id = (SELECT p_id FROM Patient WHERE name = 'Jane Smith')), 'Toothache', 'Gum swelling');
