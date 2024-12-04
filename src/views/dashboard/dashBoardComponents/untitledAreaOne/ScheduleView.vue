<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase.js'
import { useUserStore } from '@/stores/userStore'

const userStore = useUserStore()
const user_id = ref(null)
const userType = ref(null)
const appointments = ref([])

const fetchAppointments = async () => {
  if (!user_id.value) {
    console.error('User ID is not set')
    return
  }

  if (!userType.value) {
    console.error('User type is not set')
    return
  }

  if (userType.value === 'patient') {
    const { data, error } = await supabase
      .from('appointments')
      .select('appointment_date, appointment_time, status, staff_id')
      .eq('user_id', user_id.value)

    if (error) {
      console.error('Error fetching appointments:', error)
    } else {
      const staffIds = data.map((appointment) => appointment.staff_id)
      const { data: medicalStaff, error: staffError } = await supabase
        .from('medicalstaff')
        .select('staff_id, name, specialization')
        .in('staff_id', staffIds)

      if (staffError) {
        console.error('Error fetching medical staff:', staffError)
      } else {
        appointments.value = data.map((appointment) => {
          const staff = medicalStaff.find((s) => s.staff_id === appointment.staff_id)
          return {
            ...appointment,
            staffName: staff ? staff.name : 'Unknown',
            specialization: staff ? staff.specialization : 'Unknown',
            formattedDate: new Date(appointment.appointment_date).toLocaleDateString(),
          }
        })
      }
    }
  } else if (userType.value === 'doctor') {
    const { data, error } = await supabase
      .from('appointments')
      .select('appointment_date, appointment_time, status, user_id')
      .eq('staff_id', user_id.value)

    if (error) {
      console.error('Error fetching appointments:', error)
    } else {
      const userIds = data.map((appointment) => appointment.user_id)
      const { data: patients, error: patientsError } = await supabase
        .from('patient')
        .select('p_id, name')
        .in('p_id', userIds)

      if (patientsError) {
        console.error('Error fetching patients:', patientsError)
      } else {
        appointments.value = data.map((appointment) => {
          const patient = patients.find((pat) => pat.p_id === appointment.user_id)
          return {
            ...appointment,
            patientName: patient ? patient.name : 'Unknown',
            formattedDate: new Date(appointment.appointment_date).toLocaleDateString(),
          }
        })
      }
    }
  }
}

onMounted(async () => {
  await userStore.initializeUser()
  if (userStore.user) {
    user_id.value = userStore.user.id
    userType.value = userStore.user.user_metadata?.userType || 'patient'
    await fetchAppointments()
  } else {
    console.error('User not initialized')
  }
})
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
              v-if="appointments.length > 0"
              :headers="[
                { text: 'Date', value: 'formattedDate' },
                { text: 'Time', value: 'appointment_time' },
                userType.value === 'patient'
                  ? { text: 'Doctor', value: 'staffName' }
                  : { text: 'Patient', value: 'patientName' },
                { text: 'Specialty', value: 'specialization' },
                { text: 'Status', value: 'status' },
              ]"
              :items="appointments"
              class="elevation-1"
            ></v-data-table>
            <p v-else>No appointments found.</p>
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
