<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

// Form data
const selectedDoctor = ref(null)
const availableSchedules = ref([])
const selectedSchedule = ref(null)
const symptoms = ref('')
const successMessage = ref('')
const errorMessage = ref('')

// Fetch doctors
const doctors = ref([])
const fetchDoctors = async () => {
  const { data, error } = await supabase.from('Doctors').select('id, name, specialty')

  if (error) {
    console.error('Error fetching doctors:', error.message)
  } else {
    doctors.value = data
  }
}

// Fetch available schedules based on doctor
const fetchSchedules = async () => {
  if (!selectedDoctor.value) return // Ensure we have a selected doctor

  const doctorId = selectedDoctor.value.id
  console.log('Fetching schedules for doctor:', doctorId) // Debug log
  const { data, error } = await supabase
    .from('Schedule')
    .select('id, date, start_time, end_time, available_slots')
    .eq('doctor_id', doctorId)
    .gt('available_slots', 0)

  if (error) {
    console.error('Error fetching schedules:', error.message)
  } else {
    console.log('Fetched schedules:', data) // Debug log
    availableSchedules.value = data
  }
}

// Create appointment
const submitForm = async () => {
  if (!selectedDoctor.value || !selectedSchedule.value || !symptoms.value) {
    errorMessage.value = 'All fields are required!'
    return
  }

  try {
    const { data, error } = await supabase.from('Appointments').insert([
      {
        user_id: userStore.user.id, // Ensure logged-in user ID
        doctor_id: selectedDoctor.value.id, // Pass the doctor ID, not the whole object
        appointment_date: selectedSchedule.value.date,
      },
    ])

    if (error) {
      throw error
    }

    const appointmentId = data[0].id
    const { error: symptomsError } = await supabase
      .from('Symptoms')
      .insert([{ appointment_id: appointmentId, symptoms_list: symptoms.value }])

    if (symptomsError) {
      throw symptomsError
    }

    successMessage.value = 'Appointment successfully created!'
    errorMessage.value = ''
  } catch (err) {
    console.error('Error creating appointment:', err.message)
    errorMessage.value = 'Failed to create appointment. Try again later.'
  }
}

const formattedSchedules = computed(() =>
  availableSchedules.value.map((schedule) => ({
    ...schedule,
    display: `${schedule.date} (${schedule.start_time} - ${schedule.end_time})`,
  })),
)

onMounted(() => {
  fetchDoctors()
})
</script>

<template>
  <v-container>
    <v-row>
      <v-col cols="12" md="6">
        <v-select
          label="Select Doctor"
          :items="doctors"
          item-value="id"
          item-title="name"
          v-model="selectedDoctor"
          @change="fetchSchedules"
          return-object
        ></v-select>
      </v-col>

      <v-col cols="12" md="6">
        <v-select
          label="Select Schedule"
          :items="formattedSchedules"
          v-model="selectedSchedule"
          item-title="display"
          item-value="id"
          return-object
        ></v-select>
      </v-col>
    </v-row>

    <v-row>
      <v-col cols="12">
        <v-textarea label="Symptoms" v-model="symptoms" rows="5"></v-textarea>
      </v-col>
    </v-row>

    <v-row>
      <v-col cols="12">
        <v-btn color="primary" @click="submitForm">Submit</v-btn>
      </v-col>
    </v-row>

    <v-alert v-if="successMessage" type="success" class="mt-4">
      {{ successMessage }}
    </v-alert>

    <v-alert v-if="errorMessage" type="error" class="mt-4">
      {{ errorMessage }}
    </v-alert>
  </v-container>
</template>
