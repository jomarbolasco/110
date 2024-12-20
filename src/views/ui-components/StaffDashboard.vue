<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'

const availableSchedules = ref([])
const newSchedule = ref({
  schedule_date: '',
  start_time: '',
  end_time: '',
  available_slots: 0,
  appointment_type_id: null,
  staff_id: null,
})
const newAppointmentType = ref({
  type_name: '',
  description: '',
})
const activeTab = ref('schedules')

const fetchAvailableSchedules = async () => {
  try {
    const { data, error } = await supabase
      .from('schedules')
      .select(
        `
        schedule_id,
        schedule_date,
        start_time,
        end_time,
        available_slots,
        medical_staff (
          name
        ),
        appointment_types (
          type_name
        )
      `,
      )
      .gt('available_slots', 0) // Only fetch schedules with available slots

    if (error) {
      console.error('Error fetching available schedules:', error.message)
      availableSchedules.value = []
    } else {
      availableSchedules.value = data
    }
  } catch (err) {
    console.error('Unexpected error fetching available schedules:', err.message)
    availableSchedules.value = []
  }
}

const setSchedule = async () => {
  try {
    const { error } = await supabase.from('schedules').insert([newSchedule.value])
    if (error) {
      console.error('Error setting schedule:', error.message)
    } else {
      await fetchAvailableSchedules()
      // Reset the form
      newSchedule.value = {
        schedule_date: '',
        start_time: '',
        end_time: '',
        available_slots: 0,
        appointment_type_id: null,
        staff_id: null,
      }
    }
  } catch (err) {
    console.error('Unexpected error setting schedule:', err.message)
  }
}

const setAppointmentType = async () => {
  try {
    const { error } = await supabase.from('appointment_types').insert([newAppointmentType.value])
    if (error) {
      console.error('Error setting appointment type:', error.message)
    } else {
      // Reset the form
      newAppointmentType.value = {
        type_name: '',
        description: '',
      }
    }
  } catch (err) {
    console.error('Unexpected error setting appointment type:', err.message)
  }
}

onMounted(async () => {
  await fetchAvailableSchedules()
})
</script>

<template>
  <v-row>
    <v-col cols="12" sm="12">
      <h1>Staff Dashboard</h1>
    </v-col>
    <v-col cols="12" sm="12">
      <v-btn @click="activeTab = 'schedules'" :color="activeTab === 'schedules' ? 'primary' : ''">
        View Schedules
      </v-btn>
      <v-btn
        @click="activeTab = 'setAppointmentType'"
        :color="activeTab === 'setAppointmentType' ? 'primary' : ''"
      >
        Set Appointment Type
      </v-btn>
      <v-btn
        @click="activeTab = 'setSchedule'"
        :color="activeTab === 'setSchedule' ? 'primary' : ''"
      >
        Set Schedule
      </v-btn>
    </v-col>

    <v-col cols="12" lg="6" class="d-flex align-items-stretch" v-if="activeTab === 'schedules'">
      <v-card class="w-100">
        <v-card-title>Available Schedules</v-card-title>
        <v-card-text>
          <v-container>
            <v-row v-if="availableSchedules.length > 0" dense>
              <v-col
                v-for="schedule in availableSchedules"
                :key="schedule.schedule_id"
                cols="12"
                md="6"
              >
                <v-card class="mb-4 hover-card" outlined>
                  <v-card-title>
                    <strong>{{ schedule.appointment_types.type_name }}</strong>
                  </v-card-title>
                  <v-card-subtitle>
                    {{ new Date(schedule.schedule_date).toLocaleDateString() }} from
                    {{ schedule.start_time }} to {{ schedule.end_time }}
                  </v-card-subtitle>
                  <v-card-text>
                    <div>
                      <v-icon class="mr-2" color="green darken-2">mdi-account-multiple</v-icon>
                      Available Slots: <strong>{{ schedule.available_slots }}</strong>
                    </div>
                    <div v-if="schedule.medical_staff.name">
                      <v-icon class="mr-2" color="orange darken-2">mdi-account</v-icon>
                      Assigned Staff: <strong>{{ schedule.medical_staff.name }}</strong>
                    </div>
                  </v-card-text>
                </v-card>
              </v-col>
            </v-row>
            <v-row v-else>
              <v-col cols="12">
                <v-alert type="info" border="start" colored-border>
                  No available schedules found.
                </v-alert>
              </v-col>
            </v-row>
          </v-container>
        </v-card-text>
      </v-card>
    </v-col>

    <v-col
      cols="12"
      lg="6"
      class="d-flex align-items-stretch"
      v-if="activeTab === 'setAppointmentType'"
    >
      <v-card class="w-100">
        <v-card-title>Set Appointment Type</v-card-title>
        <v-card-text>
          <v-form @submit.prevent="setAppointmentType">
            <v-text-field
              v-model="newAppointmentType.type_name"
              label="Type Name"
              required
            ></v-text-field>
            <v-textarea
              v-model="newAppointmentType.description"
              label="Description"
              rows="3"
            ></v-textarea>
            <v-btn type="submit" color="primary">Set Appointment Type</v-btn>
          </v-form>
        </v-card-text>
      </v-card>
    </v-col>

    <v-col cols="12" lg="6" class="d-flex align-items-stretch" v-if="activeTab === 'setSchedule'">
      <v-card class="w-100">
        <v-card-title>Set a Schedule</v-card-title>
        <v-card-text>
          <v-form @submit.prevent="setSchedule">
            <v-text-field
              v-model="newSchedule.schedule_date"
              label="Schedule Date"
              type="date"
              required
            ></v-text-field>
            <v-text-field
              v-model="newSchedule.start_time"
              label="Start Time"
              type="time"
              required
            ></v-text-field>
            <v-text-field
              v-model="newSchedule.end_time"
              label="End Time"
              type="time"
              required
            ></v-text-field>
            <v-text-field
              v-model="newSchedule.available_slots"
              label="Available Slots"
              type="number"
              required
            ></v-text-field>
            <v-text-field
              v-model="newSchedule.appointment_type_id"
              label="Appointment Type ID"
              type="number"
              required
            ></v-text-field>
            <v-text-field
              v-model="newSchedule.staff_id"
              label="Staff ID"
              type="number"
              required
            ></v-text-field>
            <v-btn type="submit" color="primary">Set Schedule</v-btn>
          </v-form>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
</template>

<style scoped>
.hover-card {
  cursor: pointer;
  transition: transform 0.2s;
}
.hover-card:hover {
  transform: scale(1.02);
}
</style>
