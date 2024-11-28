

Table "Users" {
  "id" SERIAL [pk, increment]
  "name" VARCHAR(100) [not null]
  "email" VARCHAR(150) [unique, not null]
  "password_hash" TEXT [not null]
  "created_at" TIMESTAMP [default: `CURRENT_TIMESTAMP`]
  "role" VARCHAR(50) [default: 'Patient']
}

Table "Patient" {
  "p_id" SERIAL [pk, increment]
  "name" VARCHAR(100) [not null]
  "check_up_type" TEXT [not null]
}

Table "Admin" {
  "a_id" SERIAL [pk, increment]
  "name" VARCHAR(100) [not null]
}

Table "Hospitals" {
  "id" SERIAL [pk, increment]
  "name" VARCHAR(150) [not null]
  "address" TEXT [not null]
  "contact_number" VARCHAR(15)
}

Table "Doctors" {
  "id" UUID [pk, default: `gen_random_uuid()`]
  "name" VARCHAR(100) [not null]
  "specialty" VARCHAR(100)
  "hospital_id" INT [not null]
  "contact_number" VARCHAR(15)
}

Table "Availability" {
  "id" SERIAL [pk, increment]
  "status" TEXT [not null]
  "slots" INT [not null]
  "doctor_id" UUID [not null]
}

Table "Schedule" {
  "id" SERIAL [pk, increment]
  "doctor_id" UUID [not null]
  "date" DATE [not null]
  "start_time" TIME [not null]
  "end_time" TIME [not null]
  "available_slots" INT [not null]
}

Table "Appointments" {
  "id" SERIAL [pk, increment]
  "user_id" INT [not null]
  "doctor_id" UUID [not null]
  "appointment_date" DATE [not null]
  "status" VARCHAR(50) [default: 'Pending']
  "created_at" TIMESTAMP [default: `CURRENT_TIMESTAMP`]
}

Table "Symptoms" {
  "id" SERIAL [pk, increment]
  "appointment_id" INT [not null]
  "symptoms_list" TEXT [not null]
  "others" TEXT
  "created_at" TIMESTAMP [default: `CURRENT_TIMESTAMP`]
}

Ref:"Hospitals"."id" < "Doctors"."hospital_id" [delete: cascade]

Ref:"Doctors"."id" < "Availability"."doctor_id" [delete: cascade]

Ref:"Doctors"."id" < "Schedule"."doctor_id" [delete: cascade]

Ref:"Patient"."p_id" < "Appointments"."user_id" [delete: cascade]

Ref:"Doctors"."id" < "Appointments"."doctor_id" [delete: cascade]

Ref:"Appointments"."id" < "Symptoms"."appointment_id" [delete: cascade]

ALTER TABLE Appointments
ADD COLUMN appointment_time TIME NOT NULL;

