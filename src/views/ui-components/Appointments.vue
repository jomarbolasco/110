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
    .from('Schedule')
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
  <div class="appointment-container">
    <h2>Book an Appointment</h2>

    <div v-if="formStatus === 'error'" class="error-message">
      {{ formMessage }}
    </div>
    <div v-if="formStatus === 'success'" class="success-message">
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

    <button @click="bookAppointment" :disabled="!selectedDate || !selectedTime || !selectedDoctor">
      Book Appointment
    </button>

    <h3>Your Current Appointments</h3>
    <ul>
      <li v-for="appointment in appointments" :key="appointment.id">
        {{ appointment.appointment_date }} with Dr. {{ appointment.doctor_id }} (Status:
        {{ appointment.status }})
      </li>
    </ul>
  </div>
</template>

<style scoped>
.appointment-container {
  max-width: 600px;
  margin: 0 auto;
}

.form-group {
  margin-bottom: 1em;
}

.error-message {
  color: red;
  font-weight: bold;
}

.success-message {
  color: green;
  font-weight: bold;
}

button:disabled {
  background-color: #ccc;
}
</style>
