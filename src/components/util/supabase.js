import { createClient } from '@supabase/supabase-js'

// Initialize Supabase client
export const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY,
)

export const formActionDefault = {
  formProcess: false,
  formStatus: 200,
  formErrorMessage: '',
  formSuccessMessage: '',
}

// Fetch available schedules from Supabase
export async function fetchSchedules() {
  try {
    const { data, error } = await supabase.rpc('get_available_schedules')
    if (error) {
      throw error
    }
    return data
  } catch (error) {
    console.error('Error fetching schedules:', error.message)
    throw error
  }
}

// Create an appointment
export async function createAppointment(appointmentData) {
  const { patient_id, staff_id, appointment_date_time, schedule_id, reason, booked_by_user_id } =
    appointmentData

  try {
    const { data, error } = await supabase.rpc('create_appointment', {
      patient_id,
      staff_id,
      appointment_date_time,
      schedule_id,
      reason,
      booked_by_user_id,
    })

    if (error) {
      throw error
    }

    return data
  } catch (error) {
    console.error('Error creating appointment:', error.message)
    throw error
  }
}

// Fetch medical staff from Supabase
export async function fetchMedicalStaff() {
  try {
    const { data, error } = await supabase.from('medical_staff').select('*')
    if (error) {
      throw error
    }
    return data
  } catch (error) {
    console.error('Error fetching medical staff:', error.message)
    throw error
  }
}
