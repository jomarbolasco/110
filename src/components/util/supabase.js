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
      available_slots: supabase.raw('available_slots - 1'), // Decrease slot by 1
    })
    .eq('schedule_id', appointmentData.schedule_id)

  if (updateError) {
    throw new Error(`Failed to update available slots: ${updateError.message}`)
  }

  return data
}

// Cancel Appointment function
export const cancelAppointment = async (appointmentId, scheduleId) => {
  console.log(`Canceling appointment with ID: ${appointmentId} for schedule ID: ${scheduleId}`)

  const { error } = await supabase
    .from('appointments')
    .update({ status: 'canceled' })
    .eq('appointment_id', appointmentId)

  if (error) {
    console.error(`Failed to cancel appointment: ${error.message}`)
    throw new Error(`Failed to cancel appointment: ${error.message}`)
  }

  console.log(`Appointment canceled. Updating available slots for schedule ID: ${scheduleId}`)

  // Fetch current available slots
  const { data: scheduleData, error: fetchError } = await supabase
    .from('schedules')
    .select('available_slots')
    .eq('schedule_id', scheduleId)
    .single()

  if (fetchError) {
    console.error(`Failed to fetch schedule: ${fetchError.message}`)
    throw new Error(`Failed to fetch schedule: ${fetchError.message}`)
  }

  const newAvailableSlots = scheduleData.available_slots + 1

  // Update available slots for the schedule
  const { error: updateError } = await supabase
    .from('schedules')
    .update({ available_slots: newAvailableSlots })
    .eq('schedule_id', scheduleId)

  if (updateError) {
    console.error(`Failed to update available slots: ${updateError.message}`)
    throw new Error(`Failed to update available slots: ${updateError.message}`)
  }

  console.log(`Available slots updated for schedule ID: ${scheduleId}`)
}
