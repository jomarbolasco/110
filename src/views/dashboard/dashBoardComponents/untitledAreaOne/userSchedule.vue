<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router' // Import router for navigation
import { supabase } from '@/components/util/supabase' // Correct named import

const appointments = ref([]) // State for appointments
const router = useRouter() // Router instance

// Fetch appointments using Supabase
const fetchAppointments = async () => {
  try {
    const { data, error } = await supabase.from('Appointments').select(`
        appointment_time,
        appointment_date,
        status,
        doctor: Doctors(name)
      `)

    if (error) {
      console.error('Error fetching appointments:', error)
      return
    }

    // Map the fetched data into the required format
    appointments.value = data.map((appointment: any) => ({
      time: appointment.appointment_time,
      date: appointment.appointment_date,
      doctor: appointment.doctor.name,
      status: appointment.status,
    }))
  } catch (error) {
    console.error('Unexpected error fetching appointments:', error)
  }
}

// Handler for "View All" button
const handleViewAll = () => {
  router.push('/dashboard/ui-components/Appointments') // Navigate to an appointments page
}

// Handler for "Schedule New" button
const handleScheduleNew = () => {
  router.push('/schedule-appointment') // Navigate to a scheduling page
}

onMounted(fetchAppointments)
</script>

<template>
  <v-card class="w-100 h-100">
    <!-- Card Title -->
    <v-card-title class="text-h6 font-weight-bold"> Your Appointments </v-card-title>

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
            {{ appointment.date }} at {{ appointment.time }}
          </v-list-item-title>
          <!-- Doctor Name and Appointment Status -->
          <v-list-item-subtitle class="text-body-2">
            <strong>Doctor:</strong> {{ appointment.doctor }}<br />
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
