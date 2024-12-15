<template>
  <div class="appointment-page">
    <h1>Available Schedules</h1>
    <div class="schedules-section">
      <ul>
        <li v-for="schedule in schedules" :key="schedule.schedule_id">
          <div class="schedule-details">
            <div class="schedule-date">
              <strong>Date:</strong> {{ formatDate(schedule.schedule_date) }} ({{
                getDayOfWeek(schedule.schedule_date)
              }})
            </div>
            <div class="schedule-time">
              {{ formatTime(schedule.start_time) }} - {{ formatTime(schedule.end_time) }}
            </div>
            <div class="staff-details">
              <em>Staff: {{ schedule.staff_name }} ({{ schedule.staff_role }})</em>
            </div>
            <div class="appointment-type">Appointment Type: {{ schedule.appointment_type }}</div>
            <div class="available-slots">Slots available: {{ schedule.available_slots }}</div>
          </div>
        </li>
      </ul>
    </div>
    <!-- Another section can be added here later -->
  </div>
</template>

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
    formatDate(dateString) {
      const date = new Date(dateString)
      const options = { year: 'numeric', month: 'long', day: 'numeric' }
      return date.toLocaleDateString([], options)
    },
    getDayOfWeek(dateString) {
      const date = new Date(dateString)
      const options = { weekday: 'long' }
      return date.toLocaleDateString([], options)
    },
  },
  created() {
    this.fetchSchedules()
  },
}
</script>

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

.schedule-date {
  font-weight: bold;
  color: #333;
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
