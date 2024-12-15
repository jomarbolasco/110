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
            <button @click="openModal(schedule)">Make an Appointment</button>
          </div>
        </li>
      </ul>
    </div>

    <div v-if="showModal" class="modal">
      <div class="modal-content">
        <span class="close" @click="closeModal">&times;</span>
        <h2>Make an Appointment</h2>
        <form @submit.prevent="submitForm">
          <div>
            <label for="patientName">Patient Name:</label>
            <input type="text" id="patientName" v-model="appointmentForm.patientName" required />
          </div>
          <div>
            <label for="reason">Reason:</label>
            <textarea id="reason" v-model="appointmentForm.reason" required></textarea>
          </div>
          <button type="submit">Submit</button>
        </form>
      </div>
    </div>
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
      showModal: false,
      selectedSchedule: null,
      appointmentForm: {
        patientName: '',
        reason: '',
      },
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
    openModal(schedule) {
      this.selectedSchedule = schedule
      this.showModal = true
    },
    closeModal() {
      this.showModal = false
      this.appointmentForm = {
        patientName: '',
        reason: '',
      }
    },
    async submitForm() {
      try {
        // Add your logic here to save the appointment using Supabase
        console.log('Appointment submitted:', this.appointmentForm, this.selectedSchedule)
        this.closeModal()
      } catch (error) {
        console.error('Error submitting appointment:', error)
      }
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
  color: black;
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

.schedule-date,
.schedule-time,
.staff-details,
.appointment-type,
.available-slots {
  margin-bottom: 5px;
}

button {
  padding: 10px 15px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  transition: background-color 0.3s;
}

button:hover {
  background-color: #0056b3;
}

.modal {
  color: black;
  display: flex;
  justify-content: center;
  align-items: center;
  position: fixed;
  z-index: 1;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  overflow: auto;
  background-color: rgba(0, 0, 0, 0.4);
}

.modal-content {
  color: black;
  background-color: #f9f9f9;
  padding: 20px;
  border: 1px solid black;
  border-radius: 10px;
  width: 500px;
  max-width: 90%;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
}

.close {
  color: #aaa;
  float: right;
  font-size: 28px;
  font-weight: bold;
}

.close:hover,
.close:focus {
  color: black;
  text-decoration: none;
  cursor: pointer;
}

form div {
  margin-bottom: 15px;
}
</style>
