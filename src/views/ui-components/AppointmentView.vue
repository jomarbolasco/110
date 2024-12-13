<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'

// State variables
const isMedicalStaff = ref(false)
const appointmentTypes = ref([])
const editAppointmentTypeData = ref(null)
const newAppointmentType = ref({
  type_name: '',
  description: '',
})
const schedules = ref([]) // Schedules specifically for the logged-in user
const allSchedules = ref([]) // All schedules
const editScheduleData = ref(null)
const newSchedule = ref({
  appointment_type_id: '',
  day_of_week: '',
  start_time: '',
  end_time: '',
})
const appointments = ref([])
const daysOfWeek = ref([
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
])

// Add, edit, update, delete methods for appointment types
const addAppointmentType = async () => {
  try {
    const { data, error } = await supabase
      .from('appointment_types')
      .insert([newAppointmentType.value])
      .select('*')
    if (error) throw error
    if (data && data.length > 0) {
      appointmentTypes.value.push(data[0])
    }
    newAppointmentType.value = { type_name: '', description: '' }
  } catch (error) {
    console.error('Error adding appointment type:', error)
  }
}

const editAppointmentType = (type) => {
  editAppointmentTypeData.value = { ...type }
}

const updateAppointmentType = async () => {
  try {
    const { data, error } = await supabase
      .from('appointment_types')
      .update(editAppointmentTypeData.value)
      .eq('appointment_type_id', editAppointmentTypeData.value.appointment_type_id)
      .select('*')
    if (error) throw error
    const index = appointmentTypes.value.findIndex(
      (type) => type.appointment_type_id === editAppointmentTypeData.value.appointment_type_id,
    )
    if (index !== -1) {
      appointmentTypes.value[index] = { ...data[0] }
    }
    editAppointmentTypeData.value = null
  } catch (error) {
    console.error('Error updating appointment type:', error)
  }
}

const deleteAppointmentType = async (id) => {
  try {
    const { error } = await supabase
      .from('appointment_types')
      .delete()
      .eq('appointment_type_id', id)
    if (error) throw error
    appointmentTypes.value = appointmentTypes.value.filter(
      (type) => type.appointment_type_id !== id,
    )
  } catch (error) {
    console.error('Error deleting appointment type:', error)
  }
}

// Fetch the user's schedules and check if they are medical staff
const fetchSchedules = async () => {
  try {
    const { data: authData, error: authError } = await supabase.auth.getUser()
    if (authError) throw authError

    const { data: staffData, error: staffError } = await supabase
      .from('medical_staff')
      .select('staff_id')
      .eq('user_id', authData.user.id)

    if (staffError) throw staffError

    const staffId = staffData[0].staff_id

    // Fetch schedules for the logged-in medical staff
    const { data: schedulesData, error: schedulesError } = await supabase
      .from('schedules')
      .select('schedule_id, day_of_week, start_time, end_time, appointment_types(type_name)')
      .eq('staff_id', staffId)

    if (schedulesError) throw schedulesError

    schedules.value = schedulesData || []
    console.log('Schedules fetched:', schedules.value)
  } catch (error) {
    console.error('Error fetching schedules:', error)
  }
}

// Add new schedule
const addSchedule = async () => {
  try {
    const { data: authData, error: authError } = await supabase.auth.getUser()
    if (authError) throw authError

    const { data, error } = await supabase
      .from('schedules')
      .insert([{ ...newSchedule.value, user_id: authData.user.id }])
      .select('*')
    if (error) throw error

    if (data && data.length > 0) {
      schedules.value.push(data[0])
      allSchedules.value.push(data[0]) // Also add to allSchedules
    }
    newSchedule.value = { appointment_type_id: '', day_of_week: '', start_time: '', end_time: '' }
  } catch (error) {
    console.error('Error adding schedule:', error)
  }
}

// Update an existing schedule
const updateSchedule = async () => {
  try {
    const { data: authData, error: authError } = await supabase.auth.getUser()
    if (authError) throw authError

    if (editScheduleData.value.user_id === authData.user.id) {
      const { data, error } = await supabase
        .from('schedules')
        .update(editScheduleData.value)
        .eq('schedule_id', editScheduleData.value.schedule_id)
        .select('*')
      if (error) throw error

      const index = schedules.value.findIndex(
        (schedule) => schedule.schedule_id === editScheduleData.value.schedule_id,
      )
      if (index !== -1) {
        schedules.value[index] = { ...data[0] }
      }

      const allIndex = allSchedules.value.findIndex(
        (schedule) => schedule.schedule_id === editScheduleData.value.schedule_id,
      )
      if (allIndex !== -1) {
        allSchedules.value[allIndex] = { ...data[0] }
      }

      editScheduleData.value = null
    } else {
      console.error('You do not have permission to edit this schedule.')
    }
  } catch (error) {
    console.error('Error updating schedule:', error)
  }
}

// Delete an existing schedule
const deleteSchedule = async (scheduleId) => {
  try {
    const { error } = await supabase.from('schedules').delete().eq('schedule_id', scheduleId)
    if (error) throw error

    schedules.value = schedules.value.filter((schedule) => schedule.schedule_id !== scheduleId)
    allSchedules.value = allSchedules.value.filter(
      (schedule) => schedule.schedule_id !== scheduleId,
    )
  } catch (error) {
    console.error('Error deleting schedule:', error)
  }
}

// Fetch initial data (check user role, fetch appointment types, schedules, etc.)
const fetchInitialData = async () => {
  try {
    const { data: authData, error: authError } = await supabase.auth.getUser()
    if (authError) throw authError

    const { data: staffData, error: staffError } = await supabase
      .from('medical_staff')
      .select('*')
      .eq('user_id', authData.user.id)

    if (staffError) throw staffError

    isMedicalStaff.value = staffData.length > 0

    if (isMedicalStaff.value) {
      const { data: types, error: typesError } = await supabase
        .from('appointment_types')
        .select('*')
      if (typesError) throw typesError
      appointmentTypes.value = types || []

      // Fetch schedules for the logged-in medical staff
      await fetchSchedules()

      const { data: appointmentsData, error: appointmentsError } = await supabase
        .from('appointments')
        .select('*')
      if (appointmentsError) throw appointmentsError
      appointments.value = appointmentsData || []
    }
  } catch (error) {
    console.error('Error fetching initial data:', error)
  }
}

onMounted(fetchInitialData)
</script>

<template>
  <div>
    <h1>Appointment Management</h1>
    <div v-if="isMedicalStaff">
      <!-- Appointment Types Section -->
      <section>
        <h2>Manage Appointment Types</h2>
        <form @submit.prevent="addAppointmentType">
          <input v-model="newAppointmentType.type_name" placeholder="Type Name" required />
          <textarea v-model="newAppointmentType.description" placeholder="Description"></textarea>
          <button type="submit">Add</button>
        </form>
        <ul>
          <li v-for="type in appointmentTypes" :key="type.appointment_type_id">
            <div v-if="editAppointmentTypeData?.appointment_type_id !== type.appointment_type_id">
              {{ type.type_name }}
              <button @click="() => editAppointmentType(type)">Edit</button>
              <button @click="() => deleteAppointmentType(type.appointment_type_id)">Delete</button>
            </div>
            <form v-else @submit.prevent="updateAppointmentType">
              <input v-model="editAppointmentTypeData.type_name" placeholder="Type Name" />
              <textarea
                v-model="editAppointmentTypeData.description"
                placeholder="Description"
              ></textarea>
              <button type="submit">Save</button>
              <button @click="() => (editAppointmentTypeData = null)">Cancel</button>
            </form>
          </li>
        </ul>
      </section>

      <!-- Schedule Management Section -->
      <section>
        <h2>Manage Schedules</h2>
        <form @submit.prevent="addSchedule">
          <select v-model="newSchedule.appointment_type_id">
            <option v-for="type in appointmentTypes" :value="type.appointment_type_id">
              {{ type.type_name }}
            </option>
          </select>
          <select v-model="newSchedule.day_of_week">
            <option v-for="day in daysOfWeek" :value="day">{{ day }}</option>
          </select>
          <input v-model="newSchedule.start_time" type="time" required />
          <input v-model="newSchedule.end_time" type="time" required />
          <button type="submit">Add</button>
        </form>
        <ul>
          <li v-for="schedule in schedules" :key="schedule.schedule_id">
            <div v-if="editScheduleData?.schedule_id !== schedule.schedule_id">
              {{ schedule.day_of_week }}: {{ schedule.start_time }} -
              {{ schedule.end_time }} (Appointment Type:
              {{ schedule.appointment_types?.type_name }})
              <button @click="() => editSchedule(schedule)">Edit</button>
              <button @click="() => deleteSchedule(schedule.schedule_id)">Delete</button>
            </div>
            <form v-else @submit.prevent="updateSchedule">
              <select v-model="editScheduleData.appointment_type_id">
                <option v-for="type in appointmentTypes" :value="type.appointment_type_id">
                  {{ type.type_name }}
                </option>
              </select>
              <select v-model="editScheduleData.day_of_week">
                <option v-for="day in daysOfWeek" :value="day">{{ day }}</option>
              </select>
              <input v-model="editScheduleData.start_time" type="time" />
              <input v-model="editScheduleData.end_time" type="time" />
              <button type="submit">Save</button>
              <button @click="() => (editScheduleData = null)">Cancel</button>
            </form>
          </li>
        </ul>
      </section>

      <!-- All Schedules Section -->
      <section>
        <h2>All Schedules</h2>
        <ul>
          <li v-for="schedule in allSchedules" :key="schedule.schedule_id">
            {{ schedule.day_of_week }}: {{ schedule.start_time }} -
            {{ schedule.end_time }} (Appointment Type: {{ schedule.appointment_types?.type_name }})
          </li>
        </ul>
      </section>
    </div>
  </div>
</template>

<style scoped>
/* Add your custom styles here */
</style>

<style scoped>
h1 {
  text-align: center;
  color: #4a90e2;
}

section {
  margin: 20px 0;
}

form {
  margin-bottom: 20px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

input,
textarea,
select,
button {
  padding: 10px;
  border: 1px solid #ccc;
  border-radius: 5px;
}

button {
  background-color: #4caf50;
  color: white;
  cursor: pointer;
}

button:hover {
  background-color: #45a049;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  background-color: black;
  border: 1px solid #ddd;
  border-radius: 5px;
  margin-bottom: 5px;
}
</style>
