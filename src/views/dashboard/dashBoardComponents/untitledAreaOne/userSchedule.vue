<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '@/components/util/supabase'

const appointments = ref<
  Array<{
    date: string
    doctorName: string
    status: string
  }>
>([]) // Define type explicitly
const router = useRouter() // Router instance

// Fetch appointments using Supabase
const fetchAppointments = async () => {
  try {
    const { data, error } = await supabase.from('appointments').select(`
        appointment_date,
        status,
        doctors (name)
      `)

    if (error) {
      console.error('Error fetching appointments:', error)
      return
    }

    console.log('Fetched data:', data) // Debug log for data structure

    // Map the fetched data into the required format
    appointments.value = data.map((appointment: any) => ({
      date: appointment.appointment_date,
      doctorName: appointment.doctors?.name || 'Unknown', // Safely access doctor name
      status: appointment.status,
    }))
  } catch (error) {
    console.error('Unexpected error fetching appointments:', error)
  }
}

// Handler for "View All" button
const handleViewAll = () => {
  router.push('/dashboard/ui-components/Appointments')
}

// Handler for "Schedule New" button
const handleScheduleNew = () => {
  router.push('/schedule-appointment')
}

onMounted(fetchAppointments) // Run fetchAppointments when the component is mounted
</script>

<template>
  <v-card class="w-100 h-100">
    <!-- Card Title -->
    <v-card-title class="text-h6 font-weight-bold">Your Appointments</v-card-title>

    <!-- Appointments List -->
    <v-card-text>
      <v-list>
        <!-- Iterate over the appointments array -->
        <v-list-item v-for="(appointment, index) in appointments" :key="index" class="mb-4">
          <v-avatar>
            <v-icon color="primary" size="32">mdi-calendar</v-icon>
          </v-avatar>

          <!-- Appointment Date and Time -->
          <v-list-item-title class="text-subtitle-1 font-weight-medium">
            {{ appointment.date }}
          </v-list-item-title>

          <!-- Doctor Name and Appointment Status -->
          <v-list-item-subtitle class="text-body-2">
            <strong>Doctor:</strong> {{ appointment.doctorName }}<br />
            <strong>Status:</strong>
            <span
              :class="{
                'text-success': appointment.status === 'Confirmed',
                'text-warning': appointment.status === 'Pending',
                'text-error': appointment.status === 'Cancelled',
              }"
            >
              {{ appointment.status }}
            </span>
          </v-list-item-subtitle>
        </v-list-item>
      </v-list>
    </v-card-text>

    <!-- Action Buttons -->
    <v-card-actions>
      <v-btn variant="outlined" color="primary" @click="handleViewAll">View All</v-btn>
      <v-spacer></v-spacer>
      <v-btn color="primary" @click="handleScheduleNew">Schedule New</v-btn>
    </v-card-actions>
  </v-card>
</template>
