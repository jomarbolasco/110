<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { fetchBookedSchedules } from '@/components/util/supabase'

const schedules = ref([])
const loading = ref(true)
const error = ref(null)

const loadSchedules = async () => {
  try {
    const data = await fetchBookedSchedules()
    schedules.value = data
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

onMounted(loadSchedules)
</script>

<template>
  <v-card>
    <v-card-title>Booked Schedules</v-card-title>
    <v-card-text>
      <div v-if="loading">Loading schedules...</div>
      <div v-else-if="error">{{ error }}</div>
      <div v-else>
        <v-data-table :items="schedules" class="elevation-1">
          <template v-slot:top>
            <v-toolbar flat>
              <v-toolbar-title>Schedules</v-toolbar-title>
              <v-divider class="mx-4" inset vertical></v-divider>
            </v-toolbar>
          </template>
          <template v-slot:item.schedule_id="{ item }">
            <span>{{ item.schedule_id }}</span>
          </template>
          <template v-slot:item.medical_staff="{ item }">
            <span>{{ item.medical_staff?.name }}</span>
          </template>
          <template v-slot:item.appointment_types="{ item }">
            <span>{{ item.appointment_types?.type_name }}</span>
          </template>
          <template v-slot:item.schedule_date="{ item }">
            <span>{{ item.schedule_date }}</span>
          </template>
          <template v-slot:item.start_time="{ item }">
            <span>{{ item.start_time }}</span>
          </template>
          <template v-slot:item.end_time="{ item }">
            <span>{{ item.end_time }}</span>
          </template>
          <template v-slot:item.available_slots="{ item }">
            <span>{{ item.available_slots }}</span>
          </template>
          <template v-slot:item.appointments="{ item }">
            <ul>
              <li v-for="appointment in item.appointments" :key="appointment.appointment_id">
                {{ appointment.patients?.name }} - {{ appointment.appointment_date_time }} -
                {{ appointment.status }}
              </li>
            </ul>
          </template>
        </v-data-table>
      </div>
    </v-card-text>
  </v-card>
</template>
