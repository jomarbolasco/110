<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase.js'

const doctors = ref([])
const selectedDoctor = ref(null)
const schedule = ref([])
const selectedDate = ref(null)
const selectedTime = ref(null)
const formAction = ref({
  formProcess: false,
  formStatus: 200,
  formErrorMessage: '',
  formSuccessMessage: '',
})

const fetchDoctors = async () => {
  const { data, error } = await supabase.from('doctors').select('*')
  if (error) {
    console.error('Error fetching doctors:', error)
  } else {
    doctors.value = data
  }
}

const fetchSchedule = async (doctorId) => {
  const { data, error } = await supabase.from('schedule').select('*').eq('id', doctorId)
  if (error) {
    console.error('Error fetching schedule:', error)
  } else {
    schedule.value = data
  }
}

const bookAppointment = async () => {
  if (!selectedDoctor.value || !selectedDate.value || !selectedTime.value) {
    formAction.value.formErrorMessage = 'Please fill in all fields.'
    return
  }

  formAction.value.formProcess = true

  const { error } = await supabase.from('appointments').insert({
    user_id: 1, // Replace with the logged-in user's ID
    doctor_id: selectedDoctor.value.id,
    appointment_date: selectedDate.value,
    status: 'Pending',
  })

  if (error) {
    console.error('Error booking appointment:', error)
    formAction.value.formErrorMessage = 'Error booking appointment.'
  } else {
    formAction.value.formSuccessMessage = 'Appointment booked successfully!'
  }

  formAction.value.formProcess = false
}

onMounted(fetchDoctors)
</script>

<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-select
          :items="doctors"
          item-value="id"
          item-title="name"
          label="Select Doctor"
          v-model="selectedDoctor"
          @change="fetchSchedule"
        ></v-select>
      </v-col>

      <v-col cols="12">
        <v-select
          :items="schedule"
          item-value="date"
          item-title="date"
          label="Select Date"
          v-model="selectedDate"
        ></v-select>
      </v-col>

      <v-col cols="12">
        <v-select
          :items="schedule"
          item-value="start_time"
          item-title="start_time"
          label="Select Time"
          v-model="selectedTime"
        ></v-select>
      </v-col>

      <v-col cols="12">
        <v-btn color="primary" :loading="formAction.formProcess" @click="bookAppointment">
          Book Appointment
        </v-btn>

        <div v-if="formAction.formErrorMessage" class="error-message">
          {{ formAction.formErrorMessage }}
        </div>
        <div v-if="formAction.formSuccessMessage" class="success-message">
          {{ formAction.formSuccessMessage }}
        </div>
      </v-col>
    </v-row>
  </v-container>
</template>

<style>
.error-message {
  color: red;
}
.success-message {
  color: green;
}
</style>
