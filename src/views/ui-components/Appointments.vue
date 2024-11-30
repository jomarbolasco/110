<script setup>
import { ref, onMounted, computed } from 'vue'
import { supabase } from '@/components/util/supabase'
import { useUserStore } from '@/stores/user'

// State Management
const userStore = useUserStore()
const doctors = ref([])
const schedules = ref([])
const appointmentForm = ref({
  doctor_id: '',
  appointment_date: '',
})
const formAction = ref({
  formProcess: false,
  formErrorMessage: '',
  formSuccessMessage: '',
})

// Fetch all doctors
const fetchDoctors = async () => {
  try {
    const { data, error } = await supabase.from('doctors').select('id, name, specialty')
    if (error) throw error
    doctors.value = data || []
  } catch (error) {
    console.error('Error fetching doctors:', error.message)
  }
}

// Fetch available schedules for a selected doctor
const fetchSchedules = async (doctorId) => {
  try {
    const { data, error } = await supabase
      .from('schedule')
      .select('id, date')
      .eq('doctor_id', doctorId)
      .eq('available', true)
    if (error) throw error
    schedules.value = data || []
  } catch (error) {
    console.error('Error fetching schedules:', error.message)
  }
}

// Book an appointment
const bookAppointment = async () => {
  formAction.value.formProcess = true
  formAction.value.formErrorMessage = ''
  formAction.value.formSuccessMessage = ''

  try {
    const userId = userStore.user?.id
    if (!userId) throw new Error('User not logged in.')

    const appointmentData = {
      user_id: userId,
      doctor_id: appointmentForm.value.doctor_id,
      appointment_date: appointmentForm.value.appointment_date,
    }

    const { error } = await supabase.from('appointments').insert([appointmentData])
    if (error) throw error

    formAction.value.formSuccessMessage = 'Appointment booked successfully!'
    // Clear the form
    appointmentForm.value = { doctor_id: '', appointment_date: '' }
    schedules.value = []
  } catch (error) {
    console.error('Error booking appointment:', error.message)
    formAction.value.formErrorMessage = error.message || 'Failed to book the appointment.'
  } finally {
    formAction.value.formProcess = false
  }
}

// Lifecycle hook: Load data on component mount
onMounted(() => {
  fetchDoctors()
  userStore.initializeUser() // Ensure user data is loaded
})
</script>

<template>
  <div class="appointment-section">
    <h2>Book an Appointment</h2>

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
      <label for="appointment_date">Select an Available Date:</label>
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
