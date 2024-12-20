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

// Create Appointment function
export const createAppointment = async (appointmentData) => {
  const { data, error } = await supabase.from('appointments').insert([appointmentData])

  if (error) {
    throw new Error(`Failed to create appointment: ${error.message}`)
  }

  // Update available slots for the schedule
  const { error: updateError } = await supabase
    .from('schedules')
    .update({
      available_slots: supabase.rpc('available_slots - 1'), // Decrease slot by 1
    })
    .eq('schedule_id', appointmentData.schedule_id)

  if (updateError) {
    throw new Error(`Failed to update available slots: ${updateError.message}`)
  }

  return data
}

// Fetch Appointments for Staff
export const fetchAppointmentsForStaff = async (staff_id) => {
  const { data, error } = await supabase
    .from('appointments')
    .select('appointment_id, patient_id, appointment_date_time, status, patients(name)')
    .eq('staff_id', staff_id)

  if (error) {
    throw new Error(`Failed to fetch appointments: ${error.message}`)
  }
  return data
}

// Fetch Booked Appointments for Logged-in User
export const fetchBookedAppointments = async (user_id) => {
  const { data, error } = await supabase
    .from('appointments')
    .select(
      `
      appointment_id,
      appointment_date_time,
      status,
      patients (
        name
      ),
      schedules (
        schedule_date,
        start_time,
        end_time,
        medical_staff (
          name
        ),
        appointment_types (
          type_name
        )
      )
    `,
    )
    .eq('booked_by_user_id', user_id)

  if (error) {
    throw new Error(`Failed to fetch booked appointments: ${error.message}`)
  }
  return data
}
