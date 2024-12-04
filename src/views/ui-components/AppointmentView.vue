<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'
import { requiredValidator } from '@/components/util/validators'

// Reactive state for managing schedules
const schedules = ref([])
const formData = ref({
  schedule_id: '',
  appointment_date: '',
  appointment_time: '',
})

const loading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

// Fetch available schedules on component mount
onMounted(async () => {
  await fetchSchedules()
})

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

const bookAppointment = async () => {
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  const user = supabase.auth.user()
  const appointmentData = {
    user_id: user.id,
    staff_id: formData.value.schedule_id,
    appointment_date: formData.value.appointment_date,
    appointment_time: formData.value.appointment_time,
    status: 'reserved',
  }

  const { error } = await supabase.from('appointments').insert([appointmentData])
  if (error) {
    errorMessage.value = 'An error occurred while booking the appointment.'
    console.error(error)
  } else {
    successMessage.value = 'Appointment booked successfully!'
    formData.value = {
      schedule_id: '',
      appointment_date: '',
      appointment_time: '',
    }
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
          {{ schedule.medicalstaff.name }}
          <v-btn @click="() => (formData.schedule_id = schedule.schedule_id)">Select</v-btn>
        </li>
      </ul>
    </div>

    <v-form v-if="formData.schedule_id" @submit.prevent="bookAppointment">
      <v-text-field
        v-model="formData.appointment_date"
        label="Appointment Date"
        type="date"
        :rules="[requiredValidator]"
      ></v-text-field>
      <v-text-field
        v-model="formData.appointment_time"
        label="Appointment Time"
        type="time"
        :rules="[requiredValidator]"
      ></v-text-field>
      <v-btn type="submit" :loading="loading">Book Appointment</v-btn>
    </v-form>

    <p v-if="errorMessage" class="text-red">{{ errorMessage }}</p>
    <p v-if="successMessage" class="text-green">{{ successMessage }}</p>
  </div>
</template>
