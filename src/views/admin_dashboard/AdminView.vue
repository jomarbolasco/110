<script setup>
import { ref, onMounted } from 'vue'
import { supabase, formActionDefault } from '@/components/util/supabase'

// State variables
const isMedicalStaff = ref(false) // Replace with actual user role check
const appointmentTypes = ref([])
const newAppointmentType = ref({
  type_name: '',
  description: '',
})
const schedules = ref([])
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

// Methods
const fetchInitialData = async () => {
  try {
    // Fetch the logged-in user
    const { data: authData, error: authError } = await supabase.auth.getUser()
    if (authError) throw authError

    console.log('Logged-in user:', authData)

    // Verify if the user is part of Medical_Staff
    const { data: staffData, error: staffError } = await supabase
      .from('medical_staff')
      .select('*')
      .eq('user_id', authData.user.id)

    if (staffError) throw staffError

    console.log('medical_staff data:', staffData)

    // Update `isMedicalStaff` based on fetched data
    isMedicalStaff.value = staffData.length > 0

    if (isMedicalStaff.value) {
      // Fetch appointment types
      const { data: types, error: typesError } = await supabase
        .from('appointment_types')
        .select('*')
      if (typesError) throw typesError
      appointmentTypes.value = types || []

      // Fetch schedules
      const { data: schedulesData, error: schedulesError } = await supabase
        .from('schedules')
        .select('*')
      if (schedulesError) throw schedulesError
      schedules.value = schedulesData || []

      // Fetch appointments
      const { data: appointmentsData, error: appointmentsError } = await supabase
        .from('appointments')
        .select('*')
      if (appointmentsError) throw appointmentsError
      appointments.value = appointmentsData || []
    } else {
      console.warn('User is not a Medical Staff.')
    }
  } catch (error) {
    console.error('Error fetching initial data:', error)
  }
}

const addAppointmentType = async () => {
  try {
    const { data, error } = await supabase
      .from('appointment_types')
      .insert([newAppointmentType.value])

    if (error) throw error
    appointmentTypes.value.push(data[0])
    newAppointmentType.value = { type_name: '', description: '' }
  } catch (error) {
    console.error('Error adding appointment type:', error)
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

const addSchedule = async () => {
  try {
    const { data, error } = await supabase.from('schedules').insert([newSchedule.value])

    if (error) throw error
    schedules.value.push(data[0])
    newSchedule.value = { appointment_type_id: '', day_of_week: '', start_time: '', end_time: '' }
  } catch (error) {
    console.error('Error adding schedule:', error)
  }
}

const deleteSchedule = async (id) => {
  try {
    const { error } = await supabase.from('schedules').delete().eq('schedule_id', id)
    if (error) throw error
    schedules.value = schedules.value.filter((schedule) => schedule.schedule_id !== id)
  } catch (error) {
    console.error('Error deleting schedule:', error)
  }
}

const getAppointmentTypeName = (id) => {
  const type = appointmentTypes.value.find((type) => type.appointment_type_id === id)
  return type ? type.type_name : 'Unknown'
}

onMounted(fetchInitialData)
</script>

<template>
  <div>
    <h1>Appointment Management</h1>

    <div v-if="isMedicalStaff">
      <!-- Appointment Types Management -->
      <section>
        <h2>Manage Appointment Types</h2>
        <div>
          <h3>Add Appointment Type</h3>
          <form @submit.prevent="addAppointmentType">
            <input v-model="newAppointmentType.type_name" placeholder="Type Name" required />
            <textarea v-model="newAppointmentType.description" placeholder="Description"></textarea>
            <button type="submit">Add</button>
          </form>
        </div>
        <div>
          <h3>Existing Appointment Types</h3>
          <ul>
            <li v-for="type in appointmentTypes" :key="type.appointment_type_id">
              {{ type.type_name }}
              <button @click="() => deleteAppointmentType(type.appointment_type_id)">Delete</button>
            </li>
          </ul>
        </div>
      </section>

      <!-- Schedules Management -->
      <section>
        <h2>Manage Schedules</h2>
        <div>
          <h3>Add Schedule</h3>
          <form @submit.prevent="addSchedule">
            <select v-model="newSchedule.appointment_type_id">
              <option
                v-for="type in appointmentTypes"
                :value="type.appointment_type_id"
                :key="type.appointment_type_id"
              >
                {{ type.type_name }}
              </option>
            </select>
            <select v-model="newSchedule.day_of_week">
              <option v-for="day in daysOfWeek" :value="day" :key="day">{{ day }}</option>
            </select>
            <input v-model="newSchedule.start_time" type="time" required />
            <input v-model="newSchedule.end_time" type="time" required />
            <button type="submit">Add</button>
          </form>
        </div>
        <div>
          <h3>Existing Schedules</h3>
          <ul>
            <li v-for="schedule in schedules" :key="schedule.schedule_id">
              {{ schedule.day_of_week }}: {{ schedule.start_time }} - {{ schedule.end_time }} ({{
                getAppointmentTypeName(schedule.appointment_type_id)
              }})
              <button @click="() => deleteSchedule(schedule.schedule_id)">Delete</button>
            </li>
          </ul>
        </div>
      </section>

      <!-- Appointments View -->
      <section>
        <h2>View Appointments</h2>
        <ul>
          <li v-for="appointment in appointments" :key="appointment.appointment_id">
            {{ appointment.patient_name }} - {{ appointment.appointment_date_time }} -
            {{ getAppointmentTypeName(appointment.appointment_type_id) }} ({{ appointment.status }})
          </li>
        </ul>
      </section>
    </div>

    <div v-else>
      <p>You do not have access to manage appointments.</p>
    </div>
  </div>
</template>

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
  background-color: #f9f9f9;
  border: 1px solid #ddd;
  border-radius: 5px;
  margin-bottom: 5px;
}
</style>
