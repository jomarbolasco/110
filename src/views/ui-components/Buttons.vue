<template>
  <div class="appointment-page">
    <h1>Available Schedules</h1>
    <div class="schedules-section">
      <ul>
        <li v-for="schedule in schedules" :key="schedule.schedule_id" class="schedule-item">
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
            <button @click="openAppointmentForm(schedule)" class="btn btn-primary">
              Book Appointment
            </button>
          </div>
        </li>
      </ul>
    </div>

    <div v-if="showForm" class="modal">
      <div class="modal-content">
        <span class="close" @click="closeAppointmentForm">&times;</span>
        <h2>Book an Appointment</h2>
        <form @submit.prevent="submitAppointment" class="appointment-form">
          <div class="form-group">
            <label for="date">Date and Time:</label>
            <input
              type="text"
              v-model="selectedSchedule.appointment_date_time"
              readonly
              class="form-control"
            />
          </div>
          <div class="form-group">
            <label for="reason">Reason:</label>
            <textarea v-model="appointmentData.reason" required class="form-control"></textarea>
          </div>
          <button type="submit" class="btn btn-primary">Book Appointment</button>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { createAppointment, fetchSchedules } from '@/components/util/supabase'

export default {
  setup() {
    const appointmentData = ref({
      staff_id: null,
      appointment_date_time: '',
      reason: '',
      patient_id: null,
      schedule_id: null,
      booked_by_user_id: null,
    })

    const schedules = ref([])
    const selectedSchedule = ref(null)
    const showForm = ref(false)

    onMounted(async () => {
      try {
        const data = await fetchSchedules()
        schedules.value = data
      } catch (error) {
        console.error('Error fetching schedules:', error.message)
      }
    })

    function openAppointmentForm(schedule) {
      // Combine schedule_date and start_time into a single TIMESTAMP
      const appointmentDateTime = `${schedule.schedule_date}T${schedule.start_time}`

      selectedSchedule.value = {
        ...schedule,
        appointment_date_time: appointmentDateTime,
      }

      appointmentData.value.schedule_id = schedule.schedule_id
      appointmentData.value.staff_id = schedule.staff_id
      appointmentData.value.appointment_date_time = appointmentDateTime
      showForm.value = true
    }

    function closeAppointmentForm() {
      showForm.value = false
    }

    async function submitAppointment() {
      try {
        await createAppointment(appointmentData.value)
        alert('Appointment booked successfully!')
        showForm.value = false
      } catch (error) {
        console.error('Error booking appointment:', error.message)
      }
    }

    function formatTime(time) {
      const [hours, minutes, seconds] = time.split(':')
      const date = new Date()
      date.setHours(hours, minutes, seconds)

      const options = {
        hour: '2-digit',
        minute: '2-digit',
        hour12: true,
      }
      return date.toLocaleTimeString([], options)
    }

    function formatDate(dateString) {
      const date = new Date(dateString)
      const options = { year: 'numeric', month: 'long', day: 'numeric' }
      return date.toLocaleDateString([], options)
    }

    function getDayOfWeek(dateString) {
      const date = new Date(dateString)
      const options = { weekday: 'long' }
      return date.toLocaleDateString([], options)
    }

    return {
      schedules,
      showForm,
      selectedSchedule,
      appointmentData,
      openAppointmentForm,
      closeAppointmentForm,
      submitAppointment,
      formatTime,
      formatDate,
      getDayOfWeek,
    }
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

.btn {
  display: block;
  width: fit-content;
  padding: 10px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 5px;
  font-size: 16px;
  cursor: pointer;
  text-align: center;
}

.btn:hover {
  background-color: #0056b3;
}

.modal {
  display: flex;
  justify-content: center;
  align-items: center;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
}

.modal-content {
  color: white;
  background-color: black;
  padding: 20px;
  border-radius: 10px;
  position: relative;
  width: 400px;
}

.close {
  position: absolute;
  top: 10px;
  right: 10px;
  font-size: 20px;
  cursor: pointer;
}
</style>
