<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'
import { requiredValidator } from '@/components/util/validators'
const theme = ref('dark')

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

onMounted(async () => {
  await fetchMedicalStaff()
  await fetchSchedules()
})

const fetchMedicalStaff = async () => {
  const { data, error } = await supabase
    .from('medicalstaff')
    .select('staff_id, name, role, available_slots, schedules (date, slots)')
  if (error) {
    console.error('Error fetching medical staff:', error)
  } else {
    medicalStaff.value = data.map((staff) => ({
      ...staff,
      reserved_slots: staff.schedules.reduce((total, schedule) => total + schedule.slots, 0),
    }))
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

const deleteMedicalStaff = async (staff_id) => {
  const { error } = await supabase.from('medicalstaff').delete().eq('staff_id', staff_id)
  if (error) {
    console.error('Error deleting medical staff:', error)
  } else {
    await fetchMedicalStaff()
  }
}

const logout = async () => {
  const { error } = await supabase.auth.signOut()
  if (error) {
    console.error('Error logging out:', error)
  } else {
    window.location.href = '/login'
  }
}

const goToDashboard = () => {
  window.location.href = '/dashboard'
}
</script>

<template>
  <v-responsive>
    <v-app :theme="theme">
      <v-container class="my-5">
        <v-btn @click="logout" color="primary">Logout</v-btn>
        <v-btn @click="goToDashboard" color="primary" outlined>Dashboard</v-btn>
        <v-row>
          <v-col cols="12" md="8" offset-md="2">
            <v-card class="pa-5">
              <v-card-title class="text-h5">Admin Dashboard</v-card-title>
              <v-card-subtitle>Manage medical staff and schedules.</v-card-subtitle>

              <v-divider class="my-4"></v-divider>
              <v-card class="mb-4">
                <v-card-title class="text-h6">Medical Staff List</v-card-title>
                <v-card-text>
                  <v-row>
                    <v-col
                      v-for="staff in medicalStaff"
                      :key="staff.staff_id"
                      cols="12"
                      md="6"
                      lg="4"
                    >
                      <v-card class="mb-4">
                        <v-card-title>{{ staff.name }} </v-card-title>
                        <v-card-subtitle>({{ staff.role }})</v-card-subtitle>
                        <v-card-text>
                          <div><strong>Available Slots:</strong> {{ staff.available_slots }}</div>
                          <div><strong>Reserved Slots:</strong> {{ staff.reserved_slots }}</div>
                          <div>
                            <strong>Schedule Dates:</strong>
                            <ul style="padding-left: 20px">
                              <li v-for="schedule in staff.schedules" :key="schedule.date">
                                {{ schedule.date }} ({{ schedule.slots }} slots)
                              </li>
                            </ul>
                          </div>
                        </v-card-text>
                        <v-card-actions>
                          <v-btn @click="deleteMedicalStaff(staff.staff_id)" color="red"
                            >Remove</v-btn
                          >
                        </v-card-actions>
                      </v-card>
                    </v-col>
                  </v-row>
                </v-card-text>
              </v-card>

              <v-card class="mb-4">
                <v-card-title class="text-h6">Schedules List</v-card-title>
                <v-card-text>
                  <v-list>
                    <v-list-item v-for="schedule in schedules" :key="schedule.schedule_id">
                      <v-list-item-title>{{ schedule.date }}</v-list-item-title>
                      <v-list-item-subtitle
                        >{{ schedule.start_time }} to {{ schedule.end_time }}</v-list-item-subtitle
                      >

                      <v-list-item-action>
                        <v-btn @click="deleteSchedule(schedule.schedule_id)" color="red"
                          >Delete</v-btn
                        >
                      </v-list-item-action>
                    </v-list-item>
                  </v-list>
                </v-card-text>
              </v-card>

              <v-alert v-if="errorMessage" type="error" class="mb-4">{{ errorMessage }}</v-alert>

              <v-expansion-panels>
                <v-expansion-panel>
                  <v-expansion-panel-title>Manage Medical Staff</v-expansion-panel-title>
                  <v-expansion-panel-text>
                    <v-card class="mb-4">
                      <v-card-text>
                        <v-form @submit.prevent="addMedicalStaff">
                          <v-text-field
                            v-model="formData.name"
                            label="Name"
                            :rules="[requiredValidator]"
                          ></v-text-field>
                          <v-select
                            v-model="formData.role"
                            :items="['doctor', 'nurse']"
                            label="Role"
                          ></v-select>
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
                      </v-card-text>
                    </v-card>
                  </v-expansion-panel-text>
                </v-expansion-panel>

                <v-expansion-panel>
                  <v-expansion-panel-title>Manage Schedules</v-expansion-panel-title>
                  <v-expansion-panel-text>
                    <v-card class="mb-4">
                      <v-card-text>
                        <v-form @submit.prevent="addSchedule">
                          <v-select
                            v-model="scheduleData.staff_id"
                            :items="medicalStaff.map((staff) => staff.staff_id)"
                            :item-title="(staff) => staff.name"
                            :item-value="(staff) => staff.staff_id"
                            label="Select Staff"
                          ></v-select>
                          <v-text-field
                            v-model="scheduleData.date"
                            label="Date"
                            type="date"
                          ></v-text-field>
                          <v-text-field
                            v-model="scheduleData.start_time"
                            label="Start Time"
                            type="time"
                          ></v-text-field>
                          <v-text-field
                            v-model="scheduleData.end_time"
                            label="End Time"
                            type="time"
                          ></v-text-field>
                          <v-text-field
                            v-model="scheduleData.slots"
                            label="Slots"
                            type="number"
                          ></v-text-field>
                          <v-btn type="submit" :loading="loading">Add Schedule</v-btn>
                        </v-form>
                      </v-card-text>
                    </v-card>
                  </v-expansion-panel-text>
                </v-expansion-panel>
              </v-expansion-panels>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-app>
  </v-responsive>
</template>
