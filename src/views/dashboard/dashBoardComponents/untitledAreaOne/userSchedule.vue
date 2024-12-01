<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase.js'
import { useUserStore } from '@/stores/userStore'

const userStore = useUserStore()
const user_id = ref(null)

// Ensure user_id is set from the userStore
onMounted(() => {
  userStore.initializeUser()
  user_id.value = userStore.user ? userStore.user.id : null
})

const appointments = ref([])

const fetchAppointments = async () => {
  if (!user_id.value) {
    console.error('User ID is not set')
    return
  }

  const { data, error } = await supabase
    .from('appointments')
    .select('appointment_date, status, doctor_id')
    .eq('user_id', user_id.value)

  if (error) {
    console.error('Error fetching appointments:', error)
  } else {
    const doctorIds = data.map((appointment) => appointment.doctor_id)
    const { data: doctors, error: doctorsError } = await supabase
      .from('doctors')
      .select('id, name, specialty')
      .in('id', doctorIds)

    if (doctorsError) {
      console.error('Error fetching doctors:', doctorsError)
    } else {
      appointments.value = data.map((appointment) => {
        const doctor = doctors.find((doc) => doc.id === appointment.doctor_id)
        return {
          ...appointment,
          doctorName: doctor ? doctor.name : 'Unknown',
          specialty: doctor ? doctor.specialty : 'Unknown',
          formattedDate: new Date(appointment.appointment_date).toLocaleDateString(),
        }
      })
    }
  }
}

onMounted(fetchAppointments)
</script>

<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-card class="w-100 h-100">
          <!-- Card Title -->
          <v-card-title class="text-h6 font-weight-bold">Your Appointments</v-card-title>
          <v-card-text>
            <v-data-table
              :headers="[
                { text: 'Date', value: 'formattedDate' },
                { text: 'Doctor', value: 'doctorName' },
                { text: 'Specialty', value: 'specialty' },
                { text: 'Status', value: 'status' },
              ]"
              :items="appointments"
              class="elevation-1"
            ></v-data-table>
          </v-card-text>
        </v-card>
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
