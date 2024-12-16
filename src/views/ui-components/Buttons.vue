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
        <h2>Book Appointment</h2>
        <div>
          <label for="reason">Reason:</label>
          <input v-model="appointmentData.reason" id="reason" />
        </div>
        <button @click="submitAppointment" class="btn btn-primary">Submit</button>
      </div>
    </div>

    <h1>Your Booked Appointments</h1>
    <div class="appointments-section">
      <ul>
        <li
          v-for="appointment in appointments"
          :key="appointment.appointment_id"
          class="appointment-item"
        >
          <div class="appointment-details">
            <div class="appointment-date">
              <strong>Date:</strong> {{ formatDate(appointment.appointment_date_time) }}
            </div>
            <div class="appointment-time">{{ formatTime(appointment.appointment_date_time) }}</div>
            <div class="staff-details">
              <em>Staff: {{ appointment.staff_name }} ({{ appointment.staff_role }})</em>
            </div>
            <div class="reason">Reason: {{ appointment.reason }}</div>
            <div class="status">Status: {{ appointment.status }}</div>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/userStore'
import {
  createAppointment,
  fetchSchedules,
  fetchUserAppointments,
} from '@/components/util/supabase'

export default {
  setup() {
    const router = useRouter()
    const userStore = useUserStore()
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
    const appointments = ref([])

    onMounted(async () => {
      resetData()
      try {
        const scheduleData = await fetchSchedules()
        schedules.value = scheduleData

        if (userStore.user) {
          const userAppointments = await fetchUserAppointments(userStore.user.id)
          appointments.value = userAppointments
        }
      } catch (error) {
        console.error('Error fetching data:', error.message)
      }
    })

    watch(
      () => userStore.user,
      async (newUser, oldUser) => {
        if (newUser) {
          const userAppointments = await fetchUserAppointments(newUser.id)
          appointments.value = userAppointments
        } else {
          resetData()
        }
      },
    )

    function resetData() {
      schedules.value = []
      selectedSchedule.value = null
      showForm.value = false
      appointments.value = []
    }

    function openAppointmentForm(schedule) {
      const appointmentDateTime = `${schedule.schedule_date}T${schedule.start_time}`
      selectedSchedule.value = { ...schedule, appointment_date_time: appointmentDateTime }

      // Set staff_id from the schedule (this should be UUID)
      appointmentData.value.schedule_id = schedule.schedule_id
      appointmentData.value.staff_id = schedule.staff_id // UUID here
      appointmentData.value.appointment_date_time = appointmentDateTime

      // Set patient_id (from Supabase Auth user)
      appointmentData.value.patient_id = userStore.user ? userStore.user.id : null // UUID here

      // Set booked_by_user_id (also UUID)
      appointmentData.value.booked_by_user_id = userStore.user ? userStore.user.id : null

      showForm.value = true
    }

    function closeAppointmentForm() {
      showForm.value = false
    }

    async function submitAppointment() {
      try {
        if (!appointmentData.value.booked_by_user_id) {
          console.error('Booked by user ID is missing!')
          alert('Error: User ID is missing. Please try logging in again.')
          return
        }

        await createAppointment(appointmentData.value)
        alert('Appointment booked successfully!')
        showForm.value = false
      } catch (error) {
        console.error('Error booking appointment:', error.message)
      }
    }

    function formatTime(dateTimeString) {
      const date = new Date(dateTimeString)
      const options = { hour: '2-digit', minute: '2-digit', hour12: true }
      return date.toLocaleTimeString([], options)
    }

    function formatDate(dateTimeString) {
      const date = new Date(dateTimeString)
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
      appointments,
      openAppointmentForm,
      closeAppointmentForm,
      submitAppointment,
      formatTime,
      formatDate,
      getDayOfWeek,
      resetData,
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
