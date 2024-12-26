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

// Function to check if the schedule is in the past
const isPastSchedule = (scheduleDate, startTime) => {
  const scheduleDateTime = new Date(`${scheduleDate}T${startTime}`)
  return scheduleDateTime < new Date()
}

// Create Appointment function
export const createAppointment = async (appointmentData) => {
  if (isPastSchedule(appointmentData.schedule_date, appointmentData.start_time)) {
    throw new Error('Cannot book an appointment for a past schedule.')
  }

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
  // Fetch schedule details to check if it's in the past
  const { data: scheduleDetails, error: fetchScheduleError } = await supabase
    .from('schedules')
    .select('schedule_date, start_time')
    .eq('schedule_id', scheduleId)
    .single()

  if (fetchScheduleError) {
    throw new Error(`Failed to fetch schedule: ${fetchScheduleError.message}`)
  }

  if (isPastSchedule(scheduleDetails.schedule_date, scheduleDetails.start_time)) {
    throw new Error('Cannot cancel an appointment for a past schedule.')
  }

  console.log(`Canceling appointment with ID: ${appointmentId} for schedule ID: ${scheduleId}`)

  const { error: cancelError } = await supabase
    .from('appointments')
    .update({ status: 'canceled' })
    .eq('appointment_id', appointmentId)

  if (cancelError) {
    console.error(`Failed to cancel appointment: ${cancelError.message}`)
    throw new Error(`Failed to cancel appointment: ${cancelError.message}`)
  }

  console.log(`Appointment canceled. Updating available slots for schedule ID: ${scheduleId}`)

  // Fetch current available slots
  const { data: currentScheduleData, error: fetchSlotsError } = await supabase
    .from('schedules')
    .select('available_slots')
    .eq('schedule_id', scheduleId)
    .single()

  if (fetchSlotsError) {
    console.error(`Failed to fetch schedule: ${fetchSlotsError.message}`)
    throw new Error(`Failed to fetch schedule: ${fetchSlotsError.message}`)
  }

  const newAvailableSlots = currentScheduleData.available_slots + 1

  // Update available slots for the schedule
  const { error: updateSlotsError } = await supabase
    .from('schedules')
    .update({ available_slots: newAvailableSlots })
    .eq('schedule_id', scheduleId)

  if (updateSlotsError) {
    console.error(`Failed to update available slots: ${updateSlotsError.message}`)
    throw new Error(`Failed to update available slots: ${updateSlotsError.message}`)
  }

  console.log(`Available slots updated for schedule ID: ${scheduleId}`)
}
