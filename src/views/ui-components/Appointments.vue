<script setup>
// import { ref } from 'vue'
// import BaseCard from '@/components/BaseCard.vue'
// import AlertType from '@/components/vuetifyComponents/alerts/AlertType.vue'
// import AlertBorder from '@/components/vuetifyComponents/alerts/AlertBorder.vue'
// import AlertColorBorder from '@/components/vuetifyComponents/alerts/AlertColorBorder.vue'
// import AlertDensity from '@/components/vuetifyComponents/alerts/AlertDensity.vue'
// import AlertClosable from '@/components/vuetifyComponents/alerts/AlertClosable.vue'

import { ref, reactive } from 'vue'
import axios from 'axios'

const doctors = ref([])
const schedules = ref([])
const selectedDoctor = ref(null)
const appointmentForm = reactive({
  doctor_id: null,
  appointment_date: '',
  user_id: 1, // Replace with logged-in user ID
})

const fetchDoctors = async () => {
  try {
    const response = await axios.get('/api/doctors')
    doctors.value = response.data
  } catch (error) {
    console.error('Error fetching doctors:', error)
  }
}

const fetchSchedules = async (doctorId) => {
  try {
    const response = await axios.get(`/api/doctors/${doctorId}/schedules`)
    schedules.value = response.data
  } catch (error) {
    console.error('Error fetching schedules:', error)
  }
}

const submitAppointment = async () => {
  try {
    const response = await axios.post('/api/appointments', appointmentForm)
    alert('Appointment booked successfully!')
  } catch (error) {
    console.error('Error booking appointment:', error)
  }
}

// Fetch doctors on component mount
fetchDoctors()
</script>

<script>
export default {
  name: 'Alerts',
}
</script>

<template>
  <div>
    <h1>Book a Doctor Appointment</h1>
    <form @submit.prevent="submitAppointment">
      <div>
        <label for="doctor">Select Doctor:</label>
        <select
          v-model="appointmentForm.doctor_id"
          @change="fetchSchedules(appointmentForm.doctor_id)"
        >
          <option v-for="doctor in doctors" :key="doctor.id" :value="doctor.id">
            {{ doctor.name }}
          </option>
        </select>
      </div>

      <div v-if="schedules.length > 0">
        <label for="date">Select Date:</label>
        <select v-model="appointmentForm.appointment_date">
          <option v-for="schedule in schedules" :key="schedule.id" :value="schedule.date">
            {{ schedule.date }} ({{ schedule.start_time }} - {{ schedule.end_time }})
          </option>
        </select>
      </div>

      <button type="submit">Book Appointment</button>
    </form>
  </div>
</template>
