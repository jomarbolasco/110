<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'

// Reactive variables to hold schedules, staff, and appointment types data
const schedules = ref([])
const staffData = ref([])
const appointmentTypes = ref([])
const loading = ref(true)
const error = ref('')

// Function to fetch all schedules, staff, and appointment types
const fetchSchedules = async () => {
  loading.value = true
  error.value = ''

  try {
    // Fetch all schedules
    const { data: schedulesData, error: schedulesError } = await supabase
      .from('schedules')
      .select(
        'schedule_id, staff_id, appointment_type_id, schedule_date, start_time, end_time, available_slots',
      )

    if (schedulesError) throw schedulesError

    // Fetch staff data
    const { data: staffDataResult, error: staffError } = await supabase
      .from('medical_staff')
      .select('staff_id, name')

    if (staffError) throw staffError

    // Fetch appointment types
    const { data: appointmentTypesResult, error: appointmentTypesError } = await supabase
      .from('appointment_types')
      .select('appointment_type_id, type_name')

    if (appointmentTypesError) throw appointmentTypesError

    // Map the data to add staff name and appointment type to schedules
    schedules.value = schedulesData.map((schedule) => {
      const staff = staffDataResult.find((staff) => staff.staff_id === schedule.staff_id)
      const appointmentType = appointmentTypesResult.find(
        (type) => type.appointment_type_id === schedule.appointment_type_id,
      )

      return {
        ...schedule,
        staff_name: staff ? staff.name : 'Unknown',
        appointment_type: appointmentType ? appointmentType.type_name : 'Unknown',
      }
    })
  } catch (err) {
    error.value = err.message || 'An error occurred while fetching data.'
  } finally {
    loading.value = false
  }
}

// Fetch schedules, staff, and appointment types on component mount
onMounted(fetchSchedules)
</script>

<template>
  <div class="schedule-page overflow-auto">
    <h1>Schedules</h1>

    <div v-if="loading" class="loading">Loading schedules...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <div v-else>
      <table class="schedules-table">
        <thead>
          <tr>
            <th>Schedule ID</th>
            <th>Staff Name</th>
            <th>Appointment Type</th>
            <th>Date</th>
            <th>Start Time</th>
            <th>End Time</th>
            <th>Available Slots</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="schedule in schedules" :key="schedule.schedule_id">
            <td>{{ schedule.schedule_id }}</td>
            <td>{{ schedule.staff_name }}</td>
            <td>{{ schedule.appointment_type }}</td>
            <td>{{ schedule.schedule_date }}</td>
            <td>{{ schedule.start_time }}</td>
            <td>{{ schedule.end_time }}</td>
            <td>{{ schedule.available_slots }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<style scoped>
.schedule-page {
  padding: 20px;
}

.schedules-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 20px;
}

.schedules-table th,
.schedules-table td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: left;
}

.schedules-table th {
  background-color: #f2f2f2;
  color: #333;
}

.schedules-table tr:nth-child(even) {
  background-color: #f9f9f9;
}

.schedules-table tr:hover {
  background-color: #f1f1f1;
}

.schedules-table th {
  padding-top: 12px;
  padding-bottom: 12px;
  text-align: left;
  background-color: #4caf50;
  color: white;
}

.loading,
.error {
  margin-top: 20px;
  font-size: 18px;
  color: #333;
}
</style>
