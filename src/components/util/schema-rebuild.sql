CREATE TABLE specialties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100),
    description TEXT
);
CREATE TABLE medicalstaff (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100),
    specialty_id UUID REFERENCES specialties(id),
    contact_information VARCHAR(100)
);
CREATE TABLE patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id),
    name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    contact_information VARCHAR(100)
);
CREATE TABLE patient_conditions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES patients(id),
    condition_name VARCHAR(100),
    symptoms TEXT,
    diagnosis TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id),
    patient_id UUID REFERENCES patients(id),
    relation_type VARCHAR(50),
    appointment_date DATE,
    appointment_time TIME,
    illness_description TEXT,
    condition_id UUID REFERENCES patient_conditions(id),
    specialty_id UUID REFERENCES specialties(id)
);
CREATE TABLE available_slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    schedule_id UUID,
    staff_id UUID,
    date DATE,
    start_time TIME,
    end_time TIME,
    is_available BOOLEAN
);
CREATE TABLE appointment_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID REFERENCES appointments(id),
    patient_id UUID REFERENCES patients(id),
    status VARCHAR(50),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
