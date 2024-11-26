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
const fetchSchedules = async (doctorId) => {
  const { data, error } = await supabase
    .from('Schedule')
    .select('id, date, start_time, end_time, available_slots')
    .eq('doctor_id', doctorId)
    .gt('available_slots', 0)

  if (error) {
    console.error('Error fetching schedules:', error.message)
  } else {
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
        user_id: userStore.user.id, // Assuming the user is logged in
        doctor_id: selectedDoctor.value,
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
          @change="fetchSchedules(selectedDoctor)"
          return-object
        ></v-select>
      </v-col>

      <v-col cols="12" md="6">
        <v-select
          label="Select Schedule"
          :items="availableSchedules"
          v-model="selectedSchedule"
          :item-title="
            (schedule) => `${schedule.date} (${schedule.start_time} - ${schedule.end_time})`
          "
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
