<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { fetchBookedAppointments } from '@/components/util/supabase'
import { useUserStore } from '@/stores/userStore' // Assuming you have a user store to get the logged-in user's ID

const appointments = ref([])
const loading = ref(true)
const error = ref(null)

const userStore = useUserStore()
const userId = userStore.user.id // Get the logged-in user's ID

const loadAppointments = async () => {
  try {
    const data = await fetchBookedAppointments(userId)
    appointments.value = data
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

onMounted(loadAppointments)
</script>

<template>
  <v-responsive>
    <div>
      <h2>Booked Appointments</h2>
      <div v-if="loading">Loading appointments...</div>
      <div v-else-if="error">{{ error }}</div>
      <div v-else-if="appointments.length === 0">You don't have any appointments.</div>
      <div v-else>
        <v-list>
          <v-list-item v-for="appointment in appointments" :key="appointment.appointment_id">
            <v-list-item-content>
              <v-list-item-title>{{ appointment.patients?.name }}</v-list-item-title>
              <v-list-item-subtitle>
                {{ appointment.schedules.schedule_date }} -
                {{ appointment.schedules.start_time }} to {{ appointment.schedules.end_time }}<br />
                {{ appointment.schedules.medical_staff?.name }} -
                {{ appointment.schedules.appointment_types?.type_name }}<br />
                Status: {{ appointment.status }}
              </v-list-item-subtitle>
            </v-list-item-content>
          </v-list-item>
        </v-list>
      </div>
    </div>
  </v-responsive>
</template>
