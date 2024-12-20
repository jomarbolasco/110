<script setup>
import { onMounted } from 'vue'
import { useUserStore } from '@/stores/userStore'

const userStore = useUserStore()

onMounted(async () => {
  await userStore.fetchBookedSchedules()
})
</script>

<template>
  <v-card class="w-100 h-100">
    <v-card-title>Your Booked Schedules</v-card-title>
    <v-card-text>
      <v-container>
        <v-row v-if="userStore.bookedSchedules.length > 0" dense>
          <v-col
            v-for="schedule in userStore.bookedSchedules"
            :key="schedule.appointment_id"
            cols="12"
            md="6"
          >
            <v-card class="mb-4">
              <v-card-title>
                <strong>{{ schedule.schedules.appointment_types.type_name }}</strong>
              </v-card-title>
              <v-card-subtitle>
                on {{ new Date(schedule.appointment_date_time).toLocaleString() }}
              </v-card-subtitle>
              <v-card-text>
                <div>
                  Status: <strong>{{ schedule.status }}</strong>
                </div>
                <div>Reason: {{ schedule.reason }}</div>
                <div v-if="schedule.schedules.medical_staff.name">
                  <strong>Assigned Staff:</strong> {{ schedule.schedules.medical_staff.name }}
                </div>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
        <v-row v-else>
          <v-col cols="12">
            <v-alert type="info" border="left" colored-border> No booked schedules found. </v-alert>
          </v-col>
        </v-row>
      </v-container>
    </v-card-text>
  </v-card>
</template>
