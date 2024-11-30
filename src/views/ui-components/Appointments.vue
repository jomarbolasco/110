<script setup>
import { ref, onMounted } from 'vue'
import { supabase, formActionDefault } from '@/components/util/supabase'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

const doctors = ref([])
const schedules = ref([])
const appointmentForm = ref({
  doctor_id: '',
  appointment_date: '',
})
const formAction = { ...formActionDefault }

// Fetch doctors and their availability
const fetchDoctors = async () => {
  const { data, error } = await supabase.from('doctors').select('*')
  if (error) console.error('Error fetching doctors:', error.message)
  doctors.value = data || []
}

// Fetch schedules for a selected doctor
const fetchSchedules = async (doctorId) => {
  const { data, error } = await supabase.from('schedule').select('*').eq('doctor_id', doctorId)
  if (error) console.error('Error fetching schedules:', error.message)
  schedules.value = data || []
}

// Handle appointment submission
const bookAppointment = async () => {
  formAction.formProcess = true
  try {
    // Debug log to confirm the values being sent
    console.log('Appointment Data:', {
      user_id: userStore.user?.id,
      doctor_id: appointmentForm.value.doctor_id,
      appointment_date: appointmentForm.value.appointment_date,
    })

    // Fetch the corresponding p_id from the Patient table
    const { data: patientData, error: patientError } = await supabase
      .from('patient')
      .select('p_id')
      .eq('user_id', userStore.user?.id) // Ensure the patient has a user_id
      .single()

    if (patientError || !patientData) {
      throw new Error('Patient entry not found for the user.')
    }

    // Insert appointment using p_id as user_id
    const { error } = await supabase.from('appointments').insert([
      {
        user_id: patientData.p_id, // Insert the correct p_id
        doctor_id: appointmentForm.value.doctor_id,
        appointment_date: appointmentForm.value.appointment_date,
      },
    ])

    if (error) throw error

    formAction.formSuccessMessage = 'Appointment booked successfully!'
    formAction.formStatus = 200
  } catch (error) {
    console.error('Error booking appointment:', error.message)
    formAction.formErrorMessage = error.message || 'Error booking appointment.'
    formAction.formStatus = 400
  } finally {
    formAction.formProcess = false
  }
}

// Lifecycle hook: Fetch data on component load
onMounted(() => {
  fetchDoctors()
  userStore.initializeUser() // Ensure user info is loaded
})

console.log('Appointment Data:', {
  user_id: userStore.user?.id,
  doctor_id: appointmentForm.value.doctor_id,
  appointment_date: appointmentForm.value.appointment_date,
})
</script>

<template>
  <div class="appointment-section">
    <h2>Book an Appointment</h2>

    <!-- Appointment Form -->
    <form @submit.prevent="bookAppointment">
      <!-- Doctor Selection -->
      <label for="doctor">Select a Doctor:</label>
      <select
        id="doctor"
        v-model="appointmentForm.doctor_id"
        @change="fetchSchedules(appointmentForm.doctor_id)"
        required
      >
        <option value="" disabled>Select a doctor</option>
        <option v-for="doctor in doctors" :key="doctor.id" :value="doctor.id">
          {{ doctor.name }} ({{ doctor.specialty }})
        </option>
      </select>

      <!-- Appointment Date -->
      <label for="appointment_date">Select a Date:</label>
      <select id="appointment_date" v-model="appointmentForm.appointment_date" required>
        <option value="" disabled>Select a date</option>
        <option v-for="schedule in schedules" :key="schedule.id" :value="schedule.date">
          {{ schedule.date }}
        </option>
      </select>

      <!-- Submit Button -->
      <button type="submit" :disabled="formAction.formProcess">
        {{ formAction.formProcess ? 'Booking...' : 'Book Appointment' }}
      </button>
    </form>

    <!-- Feedback Messages -->
    <p v-if="formAction.formSuccessMessage" class="success-message">
      {{ formAction.formSuccessMessage }}
    </p>
    <p v-if="formAction.formErrorMessage" class="error-message">
      {{ formAction.formErrorMessage }}
    </p>
  </div>
</template>

<style scoped>
.appointment-section {
  max-width: 600px;
  margin: auto;
  padding: 20px;
  border: 1px solid #ccc;
  border-radius: 8px;
}
label {
  display: block;
  margin-bottom: 8px;
  font-weight: bold;
}
select,
button {
  width: 100%;
  padding: 10px;
  margin-bottom: 16px;
  border: 1px solid #ccc;
  border-radius: 4px;
}
button {
  background-color: #007bff;
  color: white;
  cursor: pointer;
}
button:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}
.success-message {
  color: green;
}
.error-message {
  color: red;
}
</style>
