<script setup>
import { ref, onMounted, watch } from 'vue'
import { supabase } from '@/components/util/supabase.js'
import { useUserStore } from '@/stores/userStore'

const userStore = useUserStore()
const user_id = ref(null)

// Ensure user_id is set from the userStore
onMounted(() => {
  userStore.initializeUser()
  user_id.value = userStore.user ? userStore.user.id : null
})

const hospitals = ref([])
const doctors = ref([])
const schedule = ref([])
const selectedHospital = ref(null)
const selectedDoctor = ref(null)
const selectedDate = ref(null)
const selectedTime = ref(null)
const formAction = ref({
  formProcess: false,
  formStatus: 200,
  formErrorMessage: '',
  formSuccessMessage: '',
})

const fetchHospitals = async () => {
  const { data, error } = await supabase.from('hospitals').select('*')
  if (error) {
    console.error('Error fetching hospitals:', error)
  } else {
    console.log('Fetched Hospitals:', data)
    hospitals.value = data
  }
}

const fetchDoctors = async () => {
  if (!selectedHospital.value) {
    console.error('Selected Hospital is undefined or null')
    return
  }

  console.log('Selected Hospital:', selectedHospital.value)

  const { data, error } = await supabase
    .from('doctors')
    .select('*')
    .eq('hospital_id', selectedHospital.value)

  if (error) {
    console.error('Error fetching doctors:', error)
    return
  }

  console.log('Fetched Doctors:', data)
  doctors.value = data
}

const fetchSchedules = async () => {
  if (!selectedDoctor.value) {
    console.error('Selected Doctor is undefined or null')
    return
  }

  console.log('Selected Doctor:', selectedDoctor.value)

  const { data: scheduleData, error: scheduleError } = await supabase
    .from('schedule')
    .select('*')
    .eq('doctor_id', selectedDoctor.value)

  if (scheduleError) {
    console.error('Error fetching schedule:', scheduleError.message)
    return
  }

  console.log('Fetched Schedule:', scheduleData)
  schedule.value = scheduleData.map((item) => ({
    ...item,
    formattedDate: new Date(item.date).toISOString().split('T')[0], // Format as YYYY-MM-DD
    formattedTime: item.start_time, // Use start_time directly for now
  }))
}

// Watch for changes in selectedHospital to fetch doctors
watch(selectedHospital, (newVal) => {
  console.log('Selected Hospital Changed:', newVal)
  fetchDoctors()
})

watch(selectedDoctor, (newVal) => {
  console.log('Selected Doctor Changed:', newVal)
  fetchSchedules()
})

onMounted(fetchHospitals)

const bookAppointment = async () => {
  if (!selectedDoctor.value || !selectedDate.value || !selectedTime.value) {
    formAction.value.formErrorMessage = 'Please fill in all fields.'
    return
  }

  formAction.value.formProcess = true

  const { error } = await supabase.from('appointments').insert({
    user_id: user_id.value, // Use the logged-in user's ID
    doctor_id: selectedDoctor.value,
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
</script>

<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-select
          :items="hospitals"
          item-value="id"
          item-title="name"
          label="Select Hospital"
          v-model="selectedHospital"
        />
      </v-col>

      <v-col cols="12">
        <v-select
          :items="doctors"
          item-value="id"
          item-title="name"
          label="Select Doctor"
          v-model="selectedDoctor"
        ></v-select>
      </v-col>

      <v-col cols="12">
        <v-select
          :items="
            schedule
              .map((item) => item.formattedDate)
              .filter((value, index, self) => self.indexOf(value) === index)
          "
          item-value="formattedDate"
          item-title="formattedDate"
          label="Select Date"
          v-model="selectedDate"
        ></v-select>
      </v-col>

      <v-col cols="12">
        <v-select
          :items="
            schedule
              .filter((item) => item.formattedDate === selectedDate)
              .map((item) => item.formattedTime)
          "
          item-value="formattedTime"
          item-title="formattedTime"
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
