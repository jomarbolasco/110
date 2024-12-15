<script>
import { fetchSchedules } from '@/components/util/supabase' // Adjust the path as needed

export default {
  name: 'AppointmentPage',
  data() {
    return {
      schedules: [],
      error: null,
    }
  },
  methods: {
    async fetchSchedules() {
      try {
        const data = await fetchSchedules()
        this.schedules = data
      } catch (error) {
        this.error = error.message
      }
    },
    formatTime(time) {
      const [hours, minutes, seconds] = time.split(':')
      const date = new Date()
      date.setHours(hours, minutes, seconds)

      const options = {
        hour: '2-digit',
        minute: '2-digit',
        hour12: true,
      }
      return date.toLocaleTimeString([], options)
    },
  },
  created() {
    this.fetchSchedules()
  },
}
</script>

<template>
  <v-row>
    <v-col cols="12" md="12" offset-md="12" class="appointment-page">
      <v-card class="pa-5">
        <v-card-title class="text-h5">Available Schedules</v-card-title>
        <v-card-subtitle>View all available schedules</v-card-subtitle>

        <v-divider class="my-4"></v-divider>

        <div class="schedules-section">
          <ul>
            <li v-for="schedule in schedules" :key="schedule.schedule_id">
              <div class="schedule-details">
                <div class="schedule-time">
                  <strong>{{ schedule.day_of_week }}</strong
                  >: {{ formatTime(schedule.start_time) }} - {{ formatTime(schedule.end_time) }}
                </div>
                <div class="staff-details">
                  <em>Staff: {{ schedule.staff_name }} ({{ schedule.staff_role }})</em>
                </div>
                <div class="appointment-type">
                  Appointment Type: {{ schedule.appointment_type }}
                </div>
                <div class="available-slots">Slots available: {{ schedule.available_slots }}</div>
              </div>
            </li>
          </ul>
        </div>
      </v-card>
    </v-col>
  </v-row>
</template>

<style scoped>
.appointment-page {
  padding: 20px;
  font-family: Arial, sans-serif;
}

.schedules-section ul {
  list-style-type: none;
  padding: 0;
}

.schedules-section li {
  margin: 10px 0;
  border: 1px solid #ccc;
  border-radius: 5px;
  padding: 10px;
  background-color: #f9f9f9;
  transition: transform 0.2s;
}

.schedules-section li:hover {
  transform: scale(1.02);
}

.schedule-details {
  display: flex;
  flex-direction: column;
}

.schedule-time {
  font-weight: bold;
  color: #333;
}

.staff-details {
  font-style: italic;
  color: #555;
}

.appointment-type {
  font-size: 1em;
  color: #555;
}

.available-slots {
  font-size: 0.9em;
  color: #777;
}
</style>
