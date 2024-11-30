<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'

const user = ref(null)
const appointments = ref([])
const doctors = ref([])
const schedules = ref([])
const selectedDoctor = ref(null)
const selectedDate = ref('')
const selectedTime = ref('')
const formStatus = ref('')
const formMessage = ref('')

// Function to fetch user data
const fetchUser = async () => {
  try {
    const { data: session, error: sessionError } = await supabase.auth.getSession()
    if (sessionError) throw sessionError

    if (!session.session) {
      formStatus.value = 'error'
      formMessage.value = 'User is not logged in. Please log in to continue.'
      return
    }

    const { data: userData, error: userError } = await supabase.auth.getUser()
    if (userError) throw userError
    user.value = userData.user
  } catch (error) {
    console.error('Error fetching user:', error.message)
  }
}

// Function to fetch doctors
const fetchDoctors = async () => {
  try {
    const { data: doctorData, error: doctorError } = await supabase.from('doctors').select('*')
    if (doctorError) throw doctorError
    doctors.value = doctorData
  } catch (error) {
    console.error('Error fetching doctors:', error.message)
  }
}

// Function to fetch appointments for the logged-in user
const fetchAppointments = async () => {
  if (!user.value) return
  try {
    const { data: patientData, error: patientError } = await supabase
      .from('patient')
      .select('*')
      .eq('p_id', user.value.id)
    if (patientError) throw patientError

    if (patientData.length > 0) {
      const { data: appointmentData, error: appointmentError } = await supabase
        .from('appointments')
        .select('*')
        .eq('user_id', patientData[0].p_id)
      if (appointmentError) throw appointmentError
      appointments.value = appointmentData
    }
  } catch (error) {
    console.error('Error fetching appointments:', error.message)
  }
}

// Fetch schedules for the selected doctor
const fetchSchedules = async () => {
  if (!selectedDoctor.value) return
  try {
    const { data: scheduleData, error: scheduleError } = await supabase
      .from('schedule')
      .select('*')
      .eq('doctor_id', selectedDoctor.value)
      .gt('available_slots', 0)
    if (scheduleError) throw scheduleError
    schedules.value = scheduleData
  } catch (error) {
    console.error('Error fetching schedules:', error.message)
  }
}

// Book an appointment
const bookAppointment = async () => {
  if (!selectedDate.value || !selectedTime.value || !selectedDoctor.value) {
    formStatus.value = 'error'
    formMessage.value = 'Please fill in all fields.'
    return
  }

  if (!user.value) {
    formStatus.value = 'error'
    formMessage.value = 'Please log in to book an appointment.'
    return
  }

  try {
    // Check for existing confirmed appointments
    const existingAppointment = appointments.value.find(
      (appointment) =>
        appointment.doctor_id === selectedDoctor.value &&
        appointment.appointment_date === selectedDate.value &&
        appointment.status === 'Confirmed',
    )

    if (existingAppointment) {
      formStatus.value = 'error'
      formMessage.value = 'You already have a confirmed appointment with this doctor on this date.'
      return
    }

    // Insert new appointment
    const { error: appointmentError } = await supabase.from('appointments').insert([
      {
        user_id: user.value.id,
        doctor_id: selectedDoctor.value,
        appointment_date: selectedDate.value,
        status: 'Pending',
      },
    ])
    if (appointmentError) throw appointmentError

    formStatus.value = 'success'
    formMessage.value = 'Appointment booked successfully!'

    // Update available slots
    const scheduleToUpdate = schedules.value.find(
      (schedule) => schedule.start_time === selectedTime.value,
    )
    if (scheduleToUpdate) {
      const { error: updateError } = await supabase
        .from('schedule')
        .update({ available_slots: scheduleToUpdate.available_slots - 1 })
        .eq('id', scheduleToUpdate.id)
      if (updateError) throw updateError
    }

    fetchSchedules() // Refresh schedules
    fetchAppointments() // Refresh appointments
  } catch (error) {
    console.error('Error booking appointment:', error.message)
    formStatus.value = 'error'
    formMessage.value = error.message
  }
}

// Initialize data on component mount
onMounted(async () => {
  await fetchUser()
  await fetchDoctors()
  await fetchAppointments()
})
</script>

<template>
  <div class="appointment-container bg-green-darken-2">
    <h2 class="text-black">Book an Appointment</h2>

    <div v-if="formStatus === 'error'" class="message error-message">
      {{ formMessage }}
    </div>
    <div v-if="formStatus === 'success'" class="message success-message">
      {{ formMessage }}
    </div>

    <div class="form-group">
      <label for="doctor">Select Doctor:</label>
      <select v-model="selectedDoctor" @change="fetchSchedules">
        <option value="" disabled>Select a doctor</option>
        <option v-for="doctor in doctors" :key="doctor.id" :value="doctor.id">
          {{ doctor.name }} - {{ doctor.specialty }}
        </option>
      </select>
    </div>

    <div v-if="schedules.length > 0" class="form-group">
      <label for="appointment-date">Select Appointment Date:</label>
      <input type="date" v-model="selectedDate" />
    </div>

    <div v-if="schedules.length > 0 && selectedDate" class="form-group">
      <label for="appointment-time">Select Time:</label>
      <select v-model="selectedTime">
        <option value="" disabled>Select a time slot</option>
        <option v-for="schedule in schedules" :key="schedule.id" :value="schedule.start_time">
          {{ schedule.start_time }} - {{ schedule.end_time }} (Slots:
          {{ schedule.available_slots }})
        </option>
      </select>
    </div>

    <button
      class="text-black bg-blue"
      @click="bookAppointment"
      :disabled="!selectedDate || !selectedTime || !selectedDoctor"
    >
      Book Appointment
    </button>

    <h3>Your Current Appointments</h3>
    <ul class="appointments-list">
      <li v-for="appointment in appointments" :key="appointment.id">
        {{ appointment.appointment_date }} with Dr. {{ appointment.doctor_id }} (Status:
        {{ appointment.status }})
      </li>
    </ul>
  </div>
</template>
