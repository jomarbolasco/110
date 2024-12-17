<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'

// State variables
const schedules = ref([]) // Assigned schedules
const appointments = ref([]) // Appointments for the medical staff
const errorMessage = ref('')
const successMessage = ref('')

// New schedule form
const newSchedule = ref({
  type_name: '',
  description: '',
  schedule_date: '',
  start_time: '',
  end_time: '',
  available_slots: '',
})

// Fetch medical staff ID
const fetchMedicalStaffID = async () => {
  try {
    const {
      data: { user },
      error,
    } = await supabase.auth.getUser()
    if (error || !user) throw new Error('User not authenticated')

    const { data: staff, error: staffError } = await supabase
      .from('medical_staff')
      .select('staff_id')
      .eq('user_id', user.id)
      .single()

    if (staffError || !staff) throw new Error('Medical staff not found')
    return staff.staff_id
  } catch (error) {
    errorMessage.value = error.message
    return null
  }
}

// Fetch schedules
const fetchSchedules = async (staff_id) => {
  try {
    const { data, error } = await supabase
      .from('schedules')
      .select(
        'schedule_id, schedule_date, start_time, end_time, available_slots, appointment_types(type_name)',
      )
      .eq('staff_id', staff_id)

    if (error) throw error

    schedules.value = data.map((schedule) => ({
      ...schedule,
      isEditing: false, // Add editing flag
    }))
  } catch (err) {
    errorMessage.value = `Error fetching schedules: ${err.message}`
  }
}

// Add a new schedule
const addSchedule = async () => {
  try {
    const staff_id = await fetchMedicalStaffID()
    if (!staff_id) throw new Error('Failed to fetch staff ID.')

    // Check if appointment type exists
    const { data: existingType } = await supabase
      .from('appointment_types')
      .select('appointment_type_id')
      .eq('type_name', newSchedule.value.type_name)
      .single()

    let appointment_type_id = existingType?.appointment_type_id

    if (!appointment_type_id) {
      const { data: insertedType, error: insertError } = await supabase
        .from('appointment_types')
        .insert([
          { type_name: newSchedule.value.type_name, description: newSchedule.value.description },
        ])
        .select('appointment_type_id')
        .single()

      if (insertError) throw new Error('Failed to add appointment type.')
      appointment_type_id = insertedType.appointment_type_id
    }

    const { error } = await supabase.from('schedules').insert([
      {
        staff_id: staff_id,
        appointment_type_id: appointment_type_id,
        schedule_date: newSchedule.value.schedule_date,
        start_time: newSchedule.value.start_time,
        end_time: newSchedule.value.end_time,
        available_slots: newSchedule.value.available_slots,
      },
    ])

    if (error) throw error

    successMessage.value = 'Schedule added successfully!'
    fetchSchedules(staff_id) // Refresh schedules
  } catch (err) {
    errorMessage.value = `Error adding schedule: ${err.message}`
  }
}

// Update a schedule
const saveSchedule = async (schedule) => {
  const updatedSchedule = {
    schedule_date: schedule.schedule_date,
    start_time: schedule.start_time,
    end_time: schedule.end_time,
    available_slots: schedule.available_slots,
  }

  try {
    const { error } = await supabase
      .from('schedules')
      .update(updatedSchedule)
      .eq('schedule_id', schedule.schedule_id)

    if (error) throw error
    successMessage.value = 'Schedule updated successfully!'
    schedule.isEditing = false // Exit edit mode
    const staff_id = await fetchMedicalStaffID()
    if (staff_id) fetchSchedules(staff_id)
  } catch (err) {
    errorMessage.value = `Error updating schedule: ${err.message}`
  }
}

// Delete a schedule
const deleteSchedule = async (schedule_id) => {
  try {
    const { error } = await supabase.from('schedules').delete().eq('schedule_id', schedule_id)

    if (error) throw error
    successMessage.value = 'Schedule deleted successfully!'
    const staff_id = await fetchMedicalStaffID()
    if (staff_id) fetchSchedules(staff_id)
  } catch (err) {
    errorMessage.value = `Error deleting schedule: ${err.message}`
  }
}

// Initialize component
onMounted(async () => {
  const staff_id = await fetchMedicalStaffID()
  if (staff_id) fetchSchedules(staff_id)
})
</script>
<template>
  <div class="medicalstaff-container">
    <h1>Medical Staff Dashboard</h1>

    <!-- Messages -->
    <p v-if="errorMessage" class="error">{{ errorMessage }}</p>
    <p v-if="successMessage" class="success">{{ successMessage }}</p>

    <!-- Add Schedule Form -->
    <section>
      <h2>Add New Schedule</h2>
      <form @submit.prevent="addSchedule">
        <label> Type Name: <input v-model="newSchedule.type_name" type="text" required /> </label>
        <label>
          Description: <input v-model="newSchedule.description" type="text" required />
        </label>
        <label> Date: <input v-model="newSchedule.schedule_date" type="date" required /> </label>
        <label> Start Time: <input v-model="newSchedule.start_time" type="time" required /> </label>
        <label> End Time: <input v-model="newSchedule.end_time" type="time" required /> </label>
        <label>
          Available Slots: <input v-model="newSchedule.available_slots" type="number" required />
        </label>
        <button type="submit">Add Schedule</button>
      </form>
    </section>

    <!-- Assigned Schedules -->
    <section>
      <h2>My Schedules</h2>
      <ul v-if="schedules.length > 0">
        <li v-for="schedule in schedules" :key="schedule.schedule_id">
          <div v-if="!schedule.isEditing">
            <strong>{{ schedule.appointment_types.type_name }}</strong
            ><br />
            Date: {{ schedule.schedule_date }}<br />
            Time: {{ schedule.start_time }} - {{ schedule.end_time }}<br />
            Slots: {{ schedule.available_slots }}
          </div>
          <div v-else>
            <input v-model="schedule.schedule_date" type="date" />
            <input v-model="schedule.start_time" type="time" />
            <input v-model="schedule.end_time" type="time" />
            <input v-model="schedule.available_slots" type="number" />
            <button @click="saveSchedule(schedule)">Save</button>
            <button @click="schedule.isEditing = false">Cancel</button>
          </div>

          <div>
            <button @click="schedule.isEditing = true">Modify</button>
            <button @click="deleteSchedule(schedule.schedule_id)">Delete</button>
          </div>
        </li>
      </ul>
      <p v-else>No schedules assigned yet.</p>
    </section>
  </div>
</template>
<style scoped>
.medicalstaff-container {
  padding: 20px;
  font-family: Arial, sans-serif;
}
h1,
h2 {
  color: #333;
}
ul {
  list-style: none;
  padding: 0;
}
li {
  border: 1px solid #ccc;
  margin: 10px 0;
  padding: 10px;
  border-radius: 5px;
}
button {
  margin: 5px;
  padding: 5px 10px;
  color: #fff;
  border: none;
  border-radius: 5px;
}
button:hover {
  opacity: 0.8;
}
button:first-child {
  background-color: #4caf50;
}
button:last-child {
  background-color: #f44336;
}
form label {
  display: block;
  margin: 10px 0;
}
form input {
  width: 100%;
  padding: 5px;
  margin-top: 5px;
}
.error {
  color: red;
}
.success {
  color: green;
}
</style>
