<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'
import { useUserStore } from '@/stores/user'

// State Management
const userStore = useUserStore()
const doctors = ref([])
const schedules = ref([])
const appointmentForm = ref({
  doctor_id: null,
  appointment_date: '',
})
const formAction = ref({
  formProcess: false,
  formErrorMessage: '',
  formSuccessMessage: '',
})

onMounted(async () => {
  await userStore.initializeUser() // Ensure this completes before fetching doctors
  if (!userStore.user) {
    formAction.value.formErrorMessage = 'User is not logged in.'
    return
  }
  fetchDoctors()
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
  if (!doctorId) {
    console.warn('No doctor selected.')
    schedules.value = []
    return
  }
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

  const userId = userStore.user?.id

  if (!appointmentForm.value.doctor_id || !appointmentForm.value.appointment_date) {
    formAction.value.formErrorMessage = 'Please select a doctor and an available date.'
    formAction.value.formProcess = false
    return
  }

  if (userId) {
    try {
      // Check if the appointment already exists
      const { data: existingAppointment, error: checkError } = await supabase
        .from('appointments')
        .select('id')
        .eq('user_id', userId)
        .eq('doctor_id', appointmentForm.value.doctor_id)
        .eq('appointment_date', appointmentForm.value.appointment_date)
      // .single()

      if (existingAppointment) {
        formAction.value.formErrorMessage = 'Appointment already exists for this doctor and date.'
        return
      }

      // Insert new appointment
      const { error: appointmentError } = await supabase.from('appointments').insert({
        user_id: userId,
        doctor_id: appointmentForm.value.doctor_id,
        appointment_date: appointmentForm.value.appointment_date,
      })

      if (appointmentError) {
        formAction.value.formErrorMessage =
          'Unable to book the appointment. Please check your details and try again.'
      } else {
        formAction.value.formSuccessMessage = 'Appointment booked successfully!'
      }
    } catch (error) {
      formAction.value.formErrorMessage = 'Unexpected error occurred during booking.'
      console.error(error)
    } finally {
      formAction.value.formProcess = false
    }
  } else {
    formAction.value.formErrorMessage = 'User not logged in.'
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
