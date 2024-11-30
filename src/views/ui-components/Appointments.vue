<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'

const user = ref(null)

// Reactive state for storing the appointments, doctor schedules, and form data
const appointments = ref([])
const doctors = ref([])
const schedules = ref([])
const selectedDoctor = ref(null)
const selectedDate = ref('')
const selectedTime = ref('')
const formStatus = ref('')
const formMessage = ref('')

// Fetch the available doctors and their schedules when the component is mounted
onMounted(async () => {
  const { data: doctorData, error: doctorError } = await supabase.from('Doctors').select('*')

  if (doctorError) {
    console.error(doctorError.message)
    return
  }
  doctors.value = doctorData

  // Fetch the current user's appointments
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser()
  if (userError) {
    console.error('Error fetching user:', userError)
    return
  }

  if (user) {
    const { data: appointmentData, error: appointmentError } = await supabase
      .from('Appointments')
      .select('*')
      .eq('user_id', user.id)

    if (appointmentError) {
      console.error(appointmentError.message)
      return
    }
    appointments.value = appointmentData
  }
})

// Fetch schedules for the selected doctor
const fetchSchedules = async () => {
  if (!selectedDoctor.value) return
  const { data: scheduleData, error: scheduleError } = await supabase
    .from('schedule')
    .select('*')
    .eq('doctor_id', selectedDoctor.value)
    .gt('available_slots', 0) // Ensure there are available slots

  if (scheduleError) {
    console.error(scheduleError.message)
    return
  }
  schedules.value = scheduleData
}

// Book an appointment for the selected doctor, date, and time
const bookAppointment = async () => {
  if (!selectedDate.value || !selectedTime.value || !selectedDoctor.value) {
    formStatus.value = 'error'
    formMessage.value = 'Please fill in all fields.'
    return
  }

  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser()
  if (userError || !user) {
    formStatus.value = 'error'
    formMessage.value = 'Please log in to book an appointment.'
    return
  }

  // Check if the user has an existing appointment at the selected time
  const existingAppointment = appointments.value.find(
    (appointment) =>
      appointment.doctor_id === selectedDoctor.value &&
      appointment.appointment_date === selectedDate.value &&
      appointment.status === 'Confirmed',
  )

  if (existingAppointment) {
    formStatus.value = 'error'
    formMessage.value = 'You already have an appointment with this doctor at this time.'
    return
  }

  // Insert a new appointment
  const { error: appointmentError } = await supabase.from('Appointments').insert([
    {
      user_id: user.id,
      doctor_id: selectedDoctor.value,
      appointment_date: selectedDate.value,
      status: 'Pending', // Default status
    },
  ])

  if (appointmentError) {
    formStatus.value = 'error'
    formMessage.value = appointmentError.message
    return
  }

  formStatus.value = 'success'
  formMessage.value = 'Appointment booked successfully!'
}
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
          {{ schedule.start_time }} - {{ schedule.end_time }}
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

<style scoped>
/* Base styles */
* {
  font-family: 'Roboto', sans-serif;
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  background-color: #f4511e;
  color: #444;
  font-size: 16px;
}

.appointment-container {
  max-width: 750px;
  margin: 2rem auto;
  padding: 2rem;
  background-color: #ffffff;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.appointment-container:hover {
  transform: scale(1.02);
}

h2,
h3 {
  text-align: center;
  color: #333;
}

h2 {
  font-size: 2rem;
  margin-bottom: 1rem;
}

h3 {
  margin-top: 2rem;
  font-size: 1.5rem;
}

.form-group {
  margin-bottom: 1.5em;
}

label {
  display: block;
  font-size: 1.1rem;
  margin-bottom: 0.5em;
  color: #444;
}

select,
input {
  width: 100%;
  padding: 0.75em;
  font-size: 1rem;
  border: 1px solid #ccc;
  border-radius: 8px;
  transition: border 0.3s;
  color: black;
  background-color: #2ecc71;
}

select:focus,
input:focus {
  border-color: #3498db;
  outline: none;
}

button {
  width: 100%;
  padding: 1em;
  font-size: 1.2rem;
  background-color: #2ecc71;
  color: white;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

button:hover {
  background-color: #27ae60;
}

button:disabled {
  background-color: #dfe6e9;
}

.message {
  display: block;
  padding: 1rem;
  margin-bottom: 1.5rem;
  text-align: center;
  font-weight: bold;
  border-radius: 8px;
}

.error-message {
  color: #fff;
  background-color: #e74c3c;
}

.success-message {
  color: #fff;
  background-color: #2ecc71;
}

.appointments-list {
  list-style: none;
  padding: 0;
  color: #fff;
  background-color: #2ecc71;
}

.appointments-list li {
  padding: 1rem;
  border-bottom: 1px solid #eee;
  font-size: 1rem;
  color: #333;
}

.appointments-list li:last-child {
  border-bottom: none;
}
</style>
