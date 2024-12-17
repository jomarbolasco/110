<template>
  <div class="appointment-container">
    <h1>Book an Appointment</h1>

    <!-- Appointment Form -->
    <form @submit.prevent="bookAppointment">
      <!-- Patient Name -->
      <div class="form-group">
        <label for="name">Patient Name</label>
        <input id="name" v-model="formData.name" type="text" required placeholder="Your name" />
      </div>

      <!-- Appointment Type -->
      <div class="form-group">
        <label for="appointmentType">Appointment Type</label>
        <select
          id="appointmentType"
          v-model="formData.appointment_type_id"
          @change="fetchSchedules"
          required
        >
          <option disabled value="">Select Appointment Type</option>
          <option
            v-for="type in appointmentTypes"
            :key="type.appointment_type_id"
            :value="type.appointment_type_id"
          >
            {{ type.type_name }}
          </option>
        </select>
      </div>

      <!-- Schedules -->
      <div class="form-group">
        <label for="schedule">Available Schedules</label>
        <select id="schedule" v-model="formData.schedule_id" required>
          <option disabled value="">Select Schedule</option>
          <option
            v-for="schedule in schedules"
            :key="schedule.schedule_id"
            :value="schedule.schedule_id"
          >
            {{ schedule.schedule_date }} ({{ schedule.start_time }} - {{ schedule.end_time }})
          </option>
        </select>
        <div v-if="formData.schedule_id">
          <small>
            {{ selectedScheduleStaff }}
          </small>
        </div>
      </div>

      <!-- Reason -->
      <div class="form-group">
        <label for="reason">Reason for Appointment</label>
        <textarea
          id="reason"
          v-model="formData.reason"
          placeholder="Describe your reason"
          required
        ></textarea>
      </div>

      <!-- Submit Button -->
      <button type="submit" :disabled="loading">
        {{ loading ? 'Booking...' : 'Book Appointment' }}
      </button>
    </form>

    <!-- Success/Error Message -->
    <p v-if="successMessage" class="success">{{ successMessage }}</p>
    <p v-if="errorMessage" class="error">{{ errorMessage }}</p>

    <!-- User's Booked Appointments -->
    <div v-if="userAppointments.length > 0" class="appointments-section">
      <h2>Your Booked Appointments</h2>
      <ul>
        <li v-for="appointment in userAppointments" :key="appointment.appointment_id">
          <div>
            <strong>{{ appointment.appointment_type_name }}</strong>
            on {{ formatDate(appointment.appointment_date_time) }}
          </div>
          <div>
            Status: <strong>{{ appointment.status }}</strong>
          </div>
          <div>Reason: {{ appointment.reason }}</div>
          <div v-if="appointment.schedules?.medical_staff?.name">
            <strong>Assigned Staff:</strong> {{ appointment.schedules.medical_staff.name }}
          </div>
        </li>
      </ul>
    </div>

    <!-- No Appointments Message -->
    <p v-else>No appointments booked yet.</p>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'

// State Variables
const appointmentTypes = ref([])
const schedules = ref([])
const loading = ref(false)
const successMessage = ref('')
const errorMessage = ref('')
const userAppointments = ref([]) // To store the user's appointments

// Form Data
const formData = ref({
  name: '',
  appointment_type_id: '',
  schedule_id: '',
  reason: '',
})

// Format Date for Display
const formatDate = (date) => {
  const options = {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: 'numeric',
    minute: 'numeric',
  }
  return new Date(date).toLocaleDateString(undefined, options)
}

// Fetch Appointment Types on Load
const fetchAppointmentTypes = async () => {
  const { data, error } = await supabase.from('appointment_types').select('*')
  if (error) {
    console.error('Error fetching appointment types:', error.message)
  } else {
    appointmentTypes.value = data
  }
}

// Fetch Schedules Based on Appointment Type
const fetchSchedules = async () => {
  if (!formData.value.appointment_type_id) return

  const { data, error } = await supabase
    .from('schedules')
    .select(
      `
      schedule_id,
      schedule_date,
      start_time,
      end_time,
      available_slots,
      staff:staff_id(name),  
      appointment_types:appointment_type_id(type_name)
    `, // Fetching the assigned staff's name
    )
    .eq('appointment_type_id', formData.value.appointment_type_id)

  if (error) {
    console.error('Error fetching schedules:', error.message)
    schedules.value = []
  } else {
    schedules.value = data
  }
}

// Fetch User's Booked Appointments
const fetchUserAppointments = async () => {
  try {
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()
    if (authError || !user || !user.id) {
      console.error('Authentication error:', authError)
      throw new Error('User not authenticated or invalid user ID')
    }

    const { data, error } = await supabase
      .from('appointments')
      .select(
        `
        appointment_id,
        appointment_date_time,
        status,
        reason,
        schedules (
          appointment_types (type_name),
          medical_staff (name)  
        )
      `, // Corrected to use dot notation
      )
      .eq('booked_by_user_id', user.id)

    if (error) throw error
    userAppointments.value = data
  } catch (err) {
    console.error('Error fetching user appointments:', err.message)
    errorMessage.value = `Error: ${err.message}`
  }
}

// Computed property for displaying assigned staff for selected schedule
const selectedScheduleStaff = computed(() => {
  const selectedSchedule = schedules.value.find(
    (schedule) => schedule.schedule_id === formData.value.schedule_id,
  )
  return selectedSchedule && selectedSchedule.staff
    ? `Assigned Staff: ${selectedSchedule.staff.name}`
    : 'Staff: Not Assigned'
})

// Book an Appointment
const bookAppointment = async () => {
  loading.value = true
  successMessage.value = ''
  errorMessage.value = ''

  try {
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()
    if (authError || !user || !user.id) {
      console.error('Authentication error:', authError)
      throw new Error('User not authenticated or invalid user ID')
    }

    const { data: existingPatient, error: patientError } = await supabase
      .from('patients')
      .select('patient_id')
      .eq('user_id', user.id)
      .maybeSingle()

    if (patientError) throw patientError

    let patient_id = existingPatient?.patient_id

    if (!patient_id) {
      const { data: newPatient, error: newPatientError } = await supabase
        .from('patients')
        .insert([{ user_id: user.id, name: formData.value.name }])
        .select()
        .single()

      if (newPatientError) throw newPatientError
      patient_id = newPatient.patient_id
    }

    const { error: appointmentError } = await supabase.from('appointments').insert([
      {
        patient_id,
        staff_id: null,
        appointment_date_time: new Date(),
        schedule_id: formData.value.schedule_id,
        reason: formData.value.reason,
        status: 'scheduled',
        booked_by_user_id: user.id,
      },
    ])

    if (appointmentError) throw appointmentError

    successMessage.value = 'Appointment booked successfully!'
    fetchUserAppointments() // Refresh appointments list after booking
  } catch (err) {
    console.error('Error booking appointment:', err.message)
    errorMessage.value = `Error: ${err.message}`
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchAppointmentTypes()
  fetchUserAppointments()
})
</script>

<style scoped>
/* Same styles as before */
</style>

<style scoped>
.appointment-container {
  max-width: 600px;
  margin: auto;
  padding: 20px;
  font-family: Arial, sans-serif;
}

h1 {
  text-align: center;
  margin-bottom: 20px;
}

.form-group {
  margin-bottom: 15px;
}

label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
}

input,
select,
textarea {
  width: 100%;
  padding: 8px;
  box-sizing: border-box;
  border: 1px solid #ccc;
  border-radius: 4px;
}

button {
  background-color: #007bff;
  color: white;
  padding: 10px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

button:disabled {
  background-color: #aaa;
}

.success {
  color: green;
}

.error {
  color: red;
}

.appointments-section {
  margin-top: 30px;
}

.appointments-section h2 {
  margin-bottom: 10px;
}

.appointments-section ul {
  list-style-type: none;
  padding-left: 0;
}

.appointments-section li {
  margin-bottom: 20px;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 5px;
}

.appointments-section li strong {
  font-size: 1.2em;
}
</style>
