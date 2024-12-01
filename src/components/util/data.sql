    INSERT INTO users (email, password_hash, profile_picture)
VALUES
('john.doe@example.com', 'hashedpassword123', 'https://example.com/johndoe.jpg'),
('jane.smith@example.com', 'hashedpassword456', NULL);
INSERT INTO hospitals (name, address)
VALUES
('City Hospital', '123 Main St, Cityville'),
('Regional Medical Center', '456 Elm St, Townsville');
INSERT INTO doctors (name, specialty, hospital_id)
VALUES
('Dr. Alice Johnson', 'Cardiology', 1),
('Dr. Bob Brown', 'Dermatology', 1),
('Dr. Carol White', 'Pediatrics', 2);
INSERT INTO schedule (doctor_id, date, available)
VALUES
(1, '2024-12-02', TRUE),
(1, '2024-12-03', TRUE),
(2, '2024-12-02', FALSE),
(3, '2024-12-04', TRUE);
INSERT INTO appointments (user_id, doctor_id, appointment_date)
VALUES
((SELECT id FROM users WHERE email = 'john.doe@example.com'), 1, '2024-12-02'),
((SELECT id FROM users WHERE email = 'jane.smith@example.com'), 3, '2024-12-04');
INSERT INTO symptom_queries (user_id, query, response)
VALUES
((SELECT id FROM users WHERE email = 'john.doe@example.com'), 'I have a fever and headache', 'It might be flu. Drink fluids and rest.'),
((SELECT id FROM users WHERE email = 'jane.smith@example.com'), 'Skin rash and itching', 'Consider consulting a dermatologist for further analysis.');
