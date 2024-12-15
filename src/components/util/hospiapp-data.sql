-- Insert sample data into Patients table
INSERT INTO Patients (user_id, name, date_of_birth, gender, phone_number, address)
VALUES
    ('11111111-1111-1111-1111-111111111111', 'John Doe', '1990-05-14', 'Male', '+123456789', '123 Elm Street, Springfield'),
    ('22222222-2222-2222-2222-222222222222', 'Jane Smith', '1985-08-20', 'Female', '+987654321', '456 Oak Avenue, Metropolis'),
    ('33333333-3333-3333-3333-333333333333', 'Michael Brown', '2000-01-10', 'Male', '+1122334455', '789 Pine Road, Gotham');

-- Insert sample data into Medical_Staff table
INSERT INTO Medical_Staff (user_id, role, specialization, phone_number, available_hours, name)
VALUES
    ('44444444-4444-4444-4444-444444444444', 'Doctor', 'Cardiology', '+1111222333', '{"Monday": "09:00-17:00", "Wednesday": "09:00-17:00"}', 'Dr. Alice Green'),
    ('55555555-5555-5555-5555-555555555555', 'Nurse', NULL, '+4444555566', '{"Monday": "08:00-16:00", "Friday": "08:00-16:00"}', 'Nurse Bob White'),
    ('66666666-6666-6666-6666-666666666666', 'Doctor', 'Orthopedics', '+7777888899', '{"Tuesday": "10:00-18:00", "Thursday": "10:00-18:00"}', 'Dr. Clara Blue');

-- Insert sample data into Appointment_Types table
INSERT INTO Appointment_Types (type_name, description)
VALUES
    ('General Checkup', 'Routine general checkup appointment'),
    ('Cardiology Consultation', 'Consultation with a cardiologist'),
    ('Orthopedic Examination', 'Examination for bone and muscle issues');

-- Insert sample data into Schedules table
INSERT INTO Schedules (staff_id, appointment_type_id, day_of_week, start_time, end_time)
VALUES
    (1, 2, 'Monday', '09:00', '12:00'),
    (1, 2, 'Wednesday', '13:00', '16:00'),
    (2, 1, 'Monday', '08:00', '12:00'),
    (3, 3, 'Tuesday', '10:00', '14:00'),
    (3, 3, 'Thursday', '14:00', '18:00');

-- Insert sample data into Appointments table
INSERT INTO Appointments (patient_id, staff_id, appointment_date_time, appointment_type_id, schedule_id, reason, status, booked_by_user_id)
VALUES
    (1, 1, '2024-06-17 09:30:00', 2, 1, 'Chest pain and irregular heartbeat', 'scheduled', '11111111-1111-1111-1111-111111111111'),
    (2, 3, '2024-06-18 10:30:00', 3, 4, 'Knee pain after an injury', 'scheduled', '22222222-2222-2222-2222-222222222222'),
    (3, 2, '2024-06-21 08:15:00', 1, 3, 'Routine checkup for annual physical', 'confirmed', '33333333-3333-3333-3333-333333333333');
