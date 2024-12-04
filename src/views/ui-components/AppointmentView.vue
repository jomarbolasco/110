<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'

// Reactive state for managing schedules and user information
const schedules = ref([])
const bookedSchedules = ref([])
const selectedSchedule = ref(null)
const user = ref(null)
const loading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

// Fetch user and schedules on component mount
onMounted(async () => {
  await fetchUser()
  await fetchSchedules()
  await fetchBookedSchedules()
})

const fetchUser = async () => {
  const { data, error } = await supabase.auth.getUser()
  if (error) {
    console.error('Error fetching user:', error)
  } else {
    user.value = data.user
  }
}

const fetchSchedules = async () => {
  const { data, error } = await supabase
    .from('schedules')
    .select('schedule_id, date, start_time, end_time, medicalstaff (name)')
  if (error) {
    console.error('Error fetching schedules:', error)
    errorMessage.value = 'An error occurred while fetching schedules.'
  } else {
    schedules.value = data
  }
}

const fetchBookedSchedules = async () => {
  if (!user.value) return

  const { data, error } = await supabase
    .from('appointments')
    .select('appointment_date, appointment_time, status, staff_id, medicalstaff (name)')
    .eq('user_id', user.value.id)

  if (error) {
    console.error('Error fetching booked schedules:', error)
    errorMessage.value = 'An error occurred while fetching booked schedules.'
  } else {
    bookedSchedules.value = data.map((appointment) => ({
      ...appointment,
      medicalstaff: appointment.medicalstaff.name,
    }))
  }
}

const selectSchedule = (schedule) => {
  selectedSchedule.value = schedule
}

const bookAppointment = async () => {
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  if (user.value) {
    const appointmentData = {
      user_id: user.value.id,
      staff_id: selectedSchedule.value.schedule_id,
      appointment_date: selectedSchedule.value.date,
      appointment_time: selectedSchedule.value.start_time,
      status: 'reserved',
    }

    const { error } = await supabase.from('appointments').insert([appointmentData])
    if (error) {
      errorMessage.value = 'An error occurred while booking the appointment.'
      console.error(error)
    } else {
      successMessage.value = 'Appointment booked successfully!'
      selectedSchedule.value = null
      await fetchBookedSchedules() // Refresh booked schedules after booking
    }
  } else {
    errorMessage.value = 'User not authenticated.'
  }

  loading.value = false
}
</script>

<template>
  <div>
    <h1>Book an Appointment</h1>

    <div v-if="schedules.length > 0">
      <h2>Available Schedules</h2>
      <ul>
        <li v-for="schedule in schedules" :key="schedule.schedule_id">
          {{ schedule.date }}: {{ schedule.start_time }} to {{ schedule.end_time }} with
          {{ schedule.medicalstaff }}
          <v-btn
            @click="() => selectSchedule(schedule)"
            :disabled="bookedSchedules.some((booked) => booked.staff_id === schedule.schedule_id)"
          >
            Select
          </v-btn>
        </li>
      </ul>
    </div>

    <v-form v-if="selectedSchedule" @submit.prevent="bookAppointment">
      <p>Selected Schedule:</p>
      <p>Date: {{ selectedSchedule.date }}</p>
      <p>Time: {{ selectedSchedule.start_time }} to {{ selectedSchedule.end_time }}</p>
      <p>With: {{ selectedSchedule.medicalstaff }}</p>
      <v-btn type="submit" :loading="loading">Confirm Appointment</v-btn>
    </v-form>

    <div v-if="bookedSchedules.length > 0">
      <h2>Your Booked Schedules</h2>
      <ul>
        <li v-for="booked in bookedSchedules" :key="booked.staff_id">
          {{ booked.appointment_date }}: {{ booked.appointment_time }} with
          {{ booked.medicalstaff }} - {{ booked.status }}
        </li>
      </ul>
    </div>

    <p v-if="errorMessage" class="text-red">{{ errorMessage }}</p>
    <p v-if="successMessage" class="text-green">{{ successMessage }}</p>
  </div>
</template>
