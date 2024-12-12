<script setup>
import { ref, onMounted, watch } from 'vue' // Added watch to the imports
import { supabase } from '@/components/util/supabase'

const appointmentTypes = ref([])
const schedules = ref([])
const filteredSchedules = ref([])
const newAppointment = ref({
  appointment_type_id: '',
  schedule_id: '',
})
const successMessage = ref('')
const errorMessage = ref('')

// Fetch appointment types and schedules
const fetchInitialData = async () => {
  try {
    // Fetch appointment types
    const { data: types, error: typesError } = await supabase.from('appointment_types').select('*')
    if (typesError) throw typesError
    appointmentTypes.value = types || []

    // Fetch schedules
    const { data: scheduleData, error: scheduleError } = await supabase
      .from('schedules')
      .select('*')
    if (scheduleError) throw scheduleError
    schedules.value = scheduleData || []
  } catch (error) {
    console.error('Error fetching data:', error)
  }
}

// Filter schedules based on selected appointment type
const filterSchedules = () => {
  filteredSchedules.value = schedules.value.filter(
    (schedule) => schedule.appointment_type_id === newAppointment.value.appointment_type_id,
  )
}

// Watch appointment type selection
watch(() => newAppointment.value.appointment_type_id, filterSchedules)

// Book an appointment
const bookAppointment = async () => {
  try {
    const { data: authData, error: authError } = await supabase.auth.getUser()
    if (authError) throw authError

    const { error } = await supabase.from('appointments').insert({
      patient_id: authData.user.id,
      appointment_type_id: newAppointment.value.appointment_type_id,
      schedule_id: newAppointment.value.schedule_id, // Ensure this is included
    })
    if (error) throw error

    successMessage.value = 'Appointment successfully booked!'
    errorMessage.value = ''
    newAppointment.value = { appointment_type_id: '', schedule_id: '' }
    filteredSchedules.value = []
  } catch (error) {
    console.error('Error booking appointment:', error)
    successMessage.value = ''
    errorMessage.value = 'Failed to book appointment. Please try again later.'
  }
}

onMounted(fetchInitialData)
</script>

<template>
  <div>
    <h1>Book an Appointment</h1>

    <div v-if="appointmentTypes.length">
      <form @submit.prevent="bookAppointment">
        <div>
          <label for="appointment-type">Appointment Type:</label>
          <select id="appointment-type" v-model="newAppointment.appointment_type_id" required>
            <option value="" disabled>Select a type</option>
            <option
              v-for="type in appointmentTypes"
              :key="type.appointment_type_id"
              :value="type.appointment_type_id"
            >
              {{ type.type_name }}
            </option>
          </select>
        </div>

        <div v-if="filteredSchedules.length">
          <label for="schedule">Available Schedules:</label>
          <select id="schedule" v-model="newAppointment.schedule_id" required>
            <option value="" disabled>Select a schedule</option>
            <option
              v-for="schedule in filteredSchedules"
              :key="schedule.schedule_id"
              :value="schedule.schedule_id"
            >
              {{ schedule.day_of_week }}: {{ schedule.start_time }} - {{ schedule.end_time }}
            </option>
          </select>
        </div>
        <div v-else>
          <p>No schedules available for the selected appointment type.</p>
        </div>

        <button type="submit" :disabled="!filteredSchedules.length">Book Appointment</button>
      </form>

      <p v-if="successMessage" style="color: green">{{ successMessage }}</p>
      <p v-if="errorMessage" style="color: red">{{ errorMessage }}</p>
    </div>

    <div v-else>
      <p>Loading available appointment types...</p>
    </div>
  </div>
</template>

<style scoped>
h1 {
  text-align: center;
  color: #4a90e2;
  margin-bottom: 20px;
}

form {
  display: flex;
  flex-direction: column;
  gap: 15px;
  max-width: 400px;
  margin: 0 auto;
  padding: 20px;
  border: 1px solid #ddd;
  border-radius: 10px;
  background-color: #f9f9f9;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

label {
  font-weight: bold;
  color: #333;
}

select,
button {
  padding: 10px;
  border: 1px solid #ccc;
  border-radius: 5px;
}

select {
  background-color: #fff;
  color: #333;
}

button {
  background-color: #4caf50;
  color: white;
  font-weight: bold;
  cursor: pointer;
  transition: background-color 0.3s;
}

button:hover {
  background-color: #45a049;
}

button:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}
</style>
