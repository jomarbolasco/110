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

// Function to move past schedules to past_schedules table
export const movePastSchedules = async () => {
  const currentDate = new Date().toISOString().split('T')[0]

  const { data: pastSchedules, error: fetchError } = await supabase
    .from('schedules')
    .select('*')
    .lt('schedule_date', currentDate)

  if (fetchError) {
    console.error('Error fetching past schedules:', fetchError.message)
    return
  }

  if (pastSchedules.length > 0) {
    const { error: insertError } = await supabase.from('past_schedules').insert(
      pastSchedules.map(
        ({
          schedule_id,
          staff_id,
          appointment_type_id,
          schedule_date,
          start_time,
          end_time,
          available_slots,
          created_at,
          updated_at,
        }) => ({
          schedule_id,
          staff_id,
          appointment_type_id,
          schedule_date,
          start_time,
          end_time,
          available_slots,
          created_at,
          updated_at,
        }),
      ),
    )

    if (insertError) {
      console.error('Error inserting past schedules:', insertError.message)
      return
    }

    const { error: deleteError } = await supabase
      .from('schedules')
      .delete()
      .in(
        'schedule_id',
        pastSchedules.map((schedule) => schedule.schedule_id),
      )

    if (deleteError) {
      console.error('Error deleting past schedules:', deleteError.message)
    }
  }
}

// Function to move past appointments to past_appointments table
export const movePastAppointments = async () => {
  const currentDate = new Date().toISOString()

  const { data: pastAppointments, error: fetchError } = await supabase
    .from('appointments')
    .select('*')
    .lt('appointment_date_time', currentDate)

  if (fetchError) {
    console.error('Error fetching past appointments:', fetchError.message)
    return
  }

  if (pastAppointments.length > 0) {
    const { error: insertError } = await supabase.from('past_appointments').insert(
      pastAppointments.map(
        ({
          appointment_id,
          patient_id,
          staff_id,
          appointment_date_time,
          schedule_id,
          reason,
          status,
          booked_by_user_id,
          created_at,
          updated_at,
        }) => ({
          appointment_id,
          patient_id,
          staff_id,
          appointment_date_time,
          schedule_id,
          reason,
          status,
          booked_by_user_id,
          created_at,
          updated_at,
        }),
      ),
    )

    if (insertError) {
      console.error('Error inserting past appointments:', insertError.message)
      return
    }

    const { error: deleteError } = await supabase
      .from('appointments')
      .delete()
      .in(
        'appointment_id',
        pastAppointments.map((appointment) => appointment.appointment_id),
      )

    if (deleteError) {
      console.error('Error deleting past appointments:', deleteError.message)
    }
  }
}
