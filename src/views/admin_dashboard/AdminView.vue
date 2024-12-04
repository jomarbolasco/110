<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'
import { requiredValidator } from '@/components/util/validators'

// Reactive state for managing medical staff and schedules
const medicalStaff = ref([])
const schedules = ref([])
const formData = ref({
  name: '',
  role: 'doctor',
  specialization: '',
  available_slots: 0,
})
const scheduleData = ref({
  staff_id: '',
  date: '',
  start_time: '',
  end_time: '',
  slots: 0,
})

const loading = ref(false)
const errorMessage = ref('')

// Fetch existing medical staff and schedules on component mount
onMounted(async () => {
  await fetchMedicalStaff()
  await fetchSchedules()
})

const fetchMedicalStaff = async () => {
  const { data, error } = await supabase.from('medicalstaff').select('*')
  if (error) {
    console.error('Error fetching medical staff:', error)
  } else {
    medicalStaff.value = data
  }
}

const fetchSchedules = async () => {
  const { data, error } = await supabase.from('schedules').select('*')
  if (error) {
    console.error('Error fetching schedules:', error)
  } else {
    schedules.value = data
  }
}

const addMedicalStaff = async () => {
  loading.value = true
  errorMessage.value = ''

  const { error } = await supabase.from('medicalstaff').insert([formData.value])
  if (error) {
    errorMessage.value = 'An error occurred while adding medical staff.'
    console.error(error)
  } else {
    await fetchMedicalStaff()
    formData.value = {
      name: '',
      role: 'doctor',
      specialization: '',
      available_slots: 0,
    }
  }
  loading.value = false
}

const addSchedule = async () => {
  loading.value = true
  errorMessage.value = ''

  const { error } = await supabase.from('schedules').insert([scheduleData.value])
  if (error) {
    errorMessage.value = 'An error occurred while adding the schedule.'
    console.error(error)
  } else {
    await fetchSchedules()
    scheduleData.value = {
      staff_id: '',
      date: '',
      start_time: '',
      end_time: '',
      slots: 0,
    }
  }
  loading.value = false
}

const deleteSchedule = async (schedule_id) => {
  const { error } = await supabase.from('schedules').delete().eq('schedule_id', schedule_id)
  if (error) {
    console.error('Error deleting schedule:', error)
  } else {
    await fetchSchedules()
  }
}
</script>

<template>
  <div>
    <h1>Admin Dashboard</h1>

    <h2>Manage Medical Staff</h2>
    <v-form @submit.prevent="addMedicalStaff">
      <v-text-field
        v-model="formData.name"
        label="Name"
        :rules="[requiredValidator]"
      ></v-text-field>
      <v-select v-model="formData.role" :items="['doctor', 'nurse']" label="Role"></v-select>
      <v-text-field
        v-model="formData.specialization"
        label="Specialization"
        :rules="[requiredValidator]"
      ></v-text-field>
      <v-text-field
        v-model="formData.available_slots"
        label="Available Slots"
        type="number"
      ></v-text-field>
      <v-btn type="submit" :loading="loading">Add Staff</v-btn>
    </v-form>

    <h2>Medical Staff List</h2>
    <ul>
      <li v-for="staff in medicalStaff" :key="staff.staff_id">
        {{ staff.name }} - {{ staff.role }}
      </li>
    </ul>

    <h2>Manage Schedules</h2>
    <v-form @submit.prevent="addSchedule">
      <v-select
        v-model="scheduleData.staff_id"
        :items="medicalStaff.map((staff) => staff.staff_id)"
        :item-title="(staff) => staff.name"
        :item-value="(staff) => staff.staff_id"
        label="Select Staff"
      ></v-select>
      <v-text-field v-model="scheduleData.date" label="Date" type="date"></v-text-field>
      <v-text-field v-model="scheduleData.start_time" label="Start Time" type="time"></v-text-field>
      <v-text-field v-model="scheduleData.end_time" label="End Time" type="time"></v-text-field>
      <v-text-field v-model="scheduleData.slots" label="Slots" type="number"></v-text-field>
      <v-btn type="submit" :loading="loading">Add Schedule</v-btn>
    </v-form>

    <h2>Schedules List</h2>
    <ul>
      <li v-for="schedule in schedules" :key="schedule.schedule_id">
        {{ schedule.date }} - {{ schedule.start_time }} to {{ schedule.end_time }}
        <v-btn @click="deleteSchedule(schedule.schedule_id)">Delete</v-btn>
      </li>
    </ul>

    <p v-if="errorMessage">{{ errorMessage }}</p>
  </div>
</template>
