<template>
  <div class="staff-container" v-if="isStaff">
    <h1>Medical Staff Dashboard</h1>

    <!-- Set Schedule Form -->
    <div class="schedule-form">
      <h2>Create or Update Schedule</h2>
      <form @submit.prevent="createOrUpdateSchedule">
        <div class="form-group">
          <label for="scheduleDate">Schedule Date</label>
          <input id="scheduleDate" v-model="scheduleForm.schedule_date" type="date" required />
        </div>
        <div class="form-group">
          <label for="startTime">Start Time</label>
          <input id="startTime" v-model="scheduleForm.start_time" type="time" required />
        </div>
        <div class="form-group">
          <label for="endTime">End Time</label>
          <input id="endTime" v-model="scheduleForm.end_time" type="time" required />
        </div>
        <div class="form-group">
          <label for="availableSlots">Available Slots</label>
          <input
            id="availableSlots"
            v-model="scheduleForm.available_slots"
            type="number"
            min="1"
            required
          />
        </div>
        <button type="submit" :disabled="loading">
          {{ loading ? 'Saving...' : 'Save Schedule' }}
        </button>
      </form>
    </div>

    <!-- Staff's Schedules and Booked Appointments -->
    <div v-if="staffSchedules.length" class="schedule-list">
      <h2>Your Schedules</h2>
      <div v-for="schedule in staffSchedules" :key="schedule.schedule_id" class="schedule-card">
        <div>
          <strong>Schedule Date:</strong> {{ formatDate(schedule.schedule_date) }}
          <br />
          <strong>Time:</strong> {{ schedule.start_time }} - {{ schedule.end_time }}
          <br />
          <strong>Available Slots:</strong> {{ schedule.available_slots }}
        </div>
        <div v-if="schedule.bookedAppointments.length > 0">
          <h3>Booked Appointments:</h3>
          <ul>
            <li
              v-for="appointment in schedule.bookedAppointments"
              :key="appointment.appointment_id"
            >
              {{ appointment.patient_name }} - {{ formatDate(appointment.appointment_date_time) }}
            </li>
          </ul>
        </div>
        <div v-else>
          <p>No appointments booked yet for this schedule.</p>
        </div>
      </div>
    </div>

    <!-- No Schedules Message -->
    <p v-else>No schedules available yet.</p>
  </div>

  <!-- Message for Non-Staff Users -->
  <div v-else class="access-denied">
    <h1>Access Denied</h1>
    <p>You do not have permission to view this page.</p>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router' // Use vue-router to navigate
import { supabase } from '@/components/util/supabase'

// State variables
const staffSchedules = ref([]) // To store the staff's schedules
const scheduleForm = ref({
  schedule_date: '',
  start_time: '',
  end_time: '',
  available_slots: 1,
})
const loading = ref(false)
const isStaff = ref(false) // Flag to determine if the user is a medical staff member
const router = useRouter() // Vue router for redirection

// Fetch User Role and Check Access
const checkUserRole = async () => {
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser()
  if (authError || !user) {
    console.error('Authentication error:', authError)
    return
  }

  // Fetch user role from Supabase (assumes you have a 'role' column in your users table)
  const { data: userData, error: roleError } = await supabase
    .from('users')
    .select('role')
    .eq('id', user.id)
    .single()

  if (roleError) {
    console.error('Error fetching user role:', roleError.message)
    return
  }

  if (userData.role === 'medical_staff') {
    isStaff.value = true // Set as staff if role is 'medical_staff'
    fetchStaffSchedules() // Fetch staff schedules if user is staff
  } else {
    isStaff.value = false // Deny access for normal users
    router.push('/') // Redirect non-staff users to the home page (or another page)
  }
}

// Fetch Staff's Schedules
const fetchStaffSchedules = async () => {
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser()
  if (authError || !user) {
    console.error('Authentication error:', authError)
    return
  }

  const { data, error } = await supabase
    .from('schedules')
    .select(
      `
        schedule_id,
        schedule_date,
        start_time,
        end_time,
        available_slots,
        bookedAppointments:appointments(patient_id, patient_name, appointment_date_time)
      `,
    )
    .eq('staff_id', user.id) // Fetch schedules for the logged-in staff member

  if (error) {
    console.error('Error fetching schedules:', error.message)
  } else {
    staffSchedules.value = data
  }
}

// Format Date for Display
const formatDate = (date) => {
  const options = {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: 'numeric',
    minute: 'numeric',
  }
  return new Date(date).toLocaleDateString(undefined, options)
}

// Create or Update Schedule
const createOrUpdateSchedule = async () => {
  loading.value = true
  try {
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()
    if (authError || !user) {
      console.error('Authentication error:', authError)
      return
    }

    const { error: scheduleError } = await supabase.from('schedules').upsert([
      {
        schedule_date: scheduleForm.value.schedule_date,
        start_time: scheduleForm.value.start_time,
        end_time: scheduleForm.value.end_time,
        available_slots: scheduleForm.value.available_slots,
        staff_id: user.id, // Assign to the logged-in staff
      },
    ])

    if (scheduleError) {
      console.error('Error saving schedule:', scheduleError.message)
      return
    }

    // Reset form and refresh schedules
    scheduleForm.value = {
      schedule_date: '',
      start_time: '',
      end_time: '',
      available_slots: 1,
    }
    fetchStaffSchedules() // Refresh the schedule list
  } catch (err) {
    console.error('Error creating/updating schedule:', err.message)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  checkUserRole() // Check user role on page load
})
</script>

<style scoped>
/* Styles for the staff dashboard page */
.staff-container {
  max-width: 800px;
  margin: auto;
  padding: 20px;
}

.schedule-form {
  margin-bottom: 30px;
}

.schedule-form .form-group {
  margin-bottom: 15px;
}

.schedule-form label {
  display: block;
  margin-bottom: 5px;
}

.schedule-form input,
.schedule-form button {
  width: 100%;
  padding: 8px;
  margin: 5px 0;
  border-radius: 4px;
}

.schedule-list {
  margin-top: 30px;
}

.schedule-card {
  padding: 15px;
  border: 1px solid #ddd;
  border-radius: 4px;
  margin-bottom: 20px;
}

.schedule-card h3 {
  margin-top: 10px;
}

.schedule-card ul {
  padding-left: 20px;
}

.schedule-card li {
  margin-bottom: 5px;
}

button:disabled {
  background-color: #aaa;
}

.access-denied {
  text-align: center;
  padding: 50px;
  font-size: 1.5em;
}
</style>
