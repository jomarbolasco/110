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
              v-model="newSchedule.appointment_type.type_name"
              label="Appointment Type Name"
              required
            ></v-text-field>
            <v-textarea
              v-model="newSchedule.appointment_type.description"
              label="Appointment Type Description"
              rows="3"
            ></v-textarea>
            <v-btn type="submit" color="primary">Set Schedule</v-btn>
          </v-form>
        </v-card-text>
      </v-card>
    </v-col>

    <v-col cols="12" sm="12">
      <h2>My Schedules</h2>
      <v-container>
        <v-row v-if="mySchedules.length > 0" dense>
          <v-col v-for="schedule in mySchedules" :key="schedule.schedule_id" cols="12" md="6">
            <v-card class="mb-4 hover-card" outlined @click="handleScheduleClick(schedule)">
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
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
        <v-row v-else>
          <v-col cols="12">
            <v-alert type="info" border="start" colored-border> No schedules found. </v-alert>
          </v-col>
        </v-row>
      </v-container>
    </v-col>
  </v-row>

  <!-- Modal for displaying appointments -->
  <v-dialog v-model="showModal" max-width="600px">
    <v-card>
      <v-card-title>
        <span class="headline"
          >Appointments for {{ selectedSchedule?.appointment_types?.type_name }}</span
        >
      </v-card-title>
      <v-card-text>
        <v-container>
          <v-row v-if="appointments.length > 0" dense>
            <v-col v-for="appointment in appointments" :key="appointment.appointment_id" cols="12">
              <v-card class="mb-4" outlined>
                <v-card-title>
                  <strong>{{ appointment.patients?.name || 'No Name' }}</strong>
                </v-card-title>
                <v-card-subtitle>
                  Appointment Date:
                  {{ new Date(appointment.appointment_date_time).toLocaleString() }}
                </v-card-subtitle>
                <v-card-text>
                  <div>
                    <v-icon class="mr-2" color="blue darken-2">mdi-calendar</v-icon>
                    Status: <strong>{{ appointment.status }}</strong>
                  </div>
                  <v-btn color="primary" text="tonal" @click="showReason(appointment.reason)"
                    >View Reason</v-btn
                  >
                </v-card-text>
              </v-card>
            </v-col>
          </v-row>
          <v-row v-else>
            <v-col cols="12">
              <v-alert type="info" border="start" colored-border> No appointments found. </v-alert>
            </v-col>
          </v-row>
        </v-container>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="green darken-1" text="tonal" @click="editSchedule">Modify</v-btn>
        <v-btn
          v-if="appointments.length === 0"
          color="red darken-1"
          text="tonal"
          @click="deleteSchedule"
          >Delete</v-btn
        >
        <v-btn color="blue darken-1" text="tonal" @click="showModal = false">Close</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>

  <!-- Modal for editing schedule -->
  <v-dialog v-model="showEditModal" max-width="600px">
    <v-card>
      <v-card-title>
        <span class="headline">Edit Schedule</span>
      </v-card-title>
      <v-card-text>
        <v-form @submit.prevent="updateSchedule">
          <v-text-field
            v-model="editScheduleData.schedule_date"
            label="Schedule Date"
            type="date"
            required
          ></v-text-field>
          <v-text-field
            v-model="editScheduleData.start_time"
            label="Start Time"
            type="time"
            required
          ></v-text-field>
          <v-text-field
            v-model="editScheduleData.end_time"
            label="End Time"
            type="time"
            required
          ></v-text-field>
          <v-text-field
            v-model="editScheduleData.available_slots"
            label="Available Slots"
            type="number"
            required
          ></v-text-field>
          <v-text-field
            v-model="editScheduleData.appointment_type.type_name"
            label="Appointment Type Name"
            required
          ></v-text-field>
          <v-textarea
            v-model="editScheduleData.appointment_type.description"
            label="Appointment Type Description"
            rows="3"
          ></v-textarea>
          <v-btn type="submit" color="primary">Save Changes</v-btn>
        </v-form>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="blue darken-1" text="tonal" @click="showEditModal = false">Close</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>

  <!-- Modal for viewing reason -->
  <v-dialog v-model="showReasonModal" max-width="600px">
    <v-card>
      <v-card-title>
        <span class="headline">Appointment Reason</span>
      </v-card-title>
      <v-card-text>
        <p>{{ appointmentReason }}</p>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="blue darken-1" text="tonal" @click="showReasonModal = false">Close</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'
import { useUserStore } from '@/stores/userStore'

const userStore = useUserStore()
const availableSchedules = ref([])
const mySchedules = ref([])
const selectedSchedule = ref(null)
const appointments = ref([])
const showModal = ref(false)
const showEditModal = ref(false)
const showReasonModal = ref(false)
const appointmentReason = ref('')
const newSchedule = ref({
  schedule_date: '',
  start_time: '',
  end_time: '',
  available_slots: 0,
  appointment_type: {
    type_name: '',
    description: '',
  },
  appointment_type_id: null,
  staff_id: null,
})
const editScheduleData = ref({
  schedule_date: '',
  start_time: '',
  end_time: '',
  available_slots: 0,
  appointment_type: {
    type_name: '',
    description: '',
  },
  appointment_type_id: null,
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
          type_name,
          description,
          appointment_type_id
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

const fetchMySchedules = async (staffId) => {
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
        appointment_types (
          type_name,
          description,
          appointment_type_id
        )
      `,
      )
      .eq('staff_id', staffId)

    if (error) {
      console.error('Error fetching my schedules:', error.message)
      mySchedules.value = []
    } else {
      mySchedules.value = data
    }
  } catch (err) {
    console.error('Unexpected error fetching my schedules:', err.message)
    mySchedules.value = []
  }
}

const fetchStaffId = async () => {
  try {
    const { data, error } = await supabase
      .from('medical_staff')
      .select('staff_id')
      .eq('user_id', userStore.user.id)
      .single()

    if (error) {
      console.error('Error fetching staff ID:', error.message)
      return null
    } else {
      return data.staff_id
    }
  } catch (err) {
    console.error('Unexpected error fetching staff ID:', err.message)
    return null
  }
}

const fetchAppointments = async (scheduleId) => {
  try {
    const { data, error } = await supabase
      .from('appointments')
      .select('appointment_id, patient_id, appointment_date_time, status, reason, patients(name)')
      .eq('schedule_id', scheduleId)

    if (error) {
      console.error('Error fetching appointments:', error.message)
      appointments.value = []
    } else {
      appointments.value = data
    }
  } catch (err) {
    console.error('Unexpected error fetching appointments:', err.message)
    appointments.value = []
  }
}

const setSchedule = async () => {
  try {
    // Fetch the staff ID
    const staffId = await fetchStaffId()
    if (!staffId) {
      console.error('Staff ID not found')
      return
    }

    // Insert the new appointment type first
    const { data: appointmentTypeData, error: appointmentTypeError } = await supabase
      .from('appointment_types')
      .insert([newSchedule.value.appointment_type])
      .select('appointment_type_id')
      .single()

    if (appointmentTypeError) {
      console.error('Error setting appointment type:', appointmentTypeError.message)
      return
    }

    console.log('Appointment Type Data:', appointmentTypeData)

    // Set the appointment_type_id in the new schedule
    newSchedule.value.appointment_type_id = appointmentTypeData.appointment_type_id

    // Set the staff_id from the fetched staff ID
    newSchedule.value.staff_id = staffId

    // Insert the new schedule
    const { error: scheduleError } = await supabase.from('schedules').insert([
      {
        schedule_date: newSchedule.value.schedule_date,
        start_time: newSchedule.value.start_time,
        end_time: newSchedule.value.end_time,
        available_slots: newSchedule.value.available_slots,
        appointment_type_id: newSchedule.value.appointment_type_id,
        staff_id: newSchedule.value.staff_id,
      },
    ])

    if (scheduleError) {
      console.error('Error setting schedule:', scheduleError.message)
    } else {
      await fetchAvailableSchedules()
      await fetchMySchedules(staffId)
      // Reset the form
      newSchedule.value = {
        schedule_date: '',
        start_time: '',
        end_time: '',
        available_slots: 0,
        appointment_type: {
          type_name: '',
          description: '',
        },
        appointment_type_id: null,
        staff_id: null,
      }
    }
  } catch (err) {
    console.error('Unexpected error setting schedule:', err.message)
  }
}

const handleScheduleClick = async (schedule) => {
  selectedSchedule.value = schedule
  await fetchAppointments(schedule.schedule_id)
  showModal.value = true
}

const editSchedule = () => {
  // Populate the edit form with the selected schedule data
  editScheduleData.value = {
    schedule_date: selectedSchedule.value.schedule_date,
    start_time: selectedSchedule.value.start_time,
    end_time: selectedSchedule.value.end_time,
    available_slots: selectedSchedule.value.available_slots,
    appointment_type: {
      type_name: selectedSchedule.value.appointment_types.type_name,
      description: selectedSchedule.value.appointment_types.description,
    },
    appointment_type_id: selectedSchedule.value.appointment_types.appointment_type_id,
  }
  showEditModal.value = true
}

const updateSchedule = async () => {
  try {
    const { error } = await supabase
      .from('schedules')
      .update({
        schedule_date: editScheduleData.value.schedule_date,
        start_time: editScheduleData.value.start_time,
        end_time: editScheduleData.value.end_time,
        available_slots: editScheduleData.value.available_slots,
        appointment_type_id: editScheduleData.value.appointment_type_id,
      })
      .eq('schedule_id', selectedSchedule.value.schedule_id)

    if (error) {
      console.error('Error updating schedule:', error.message)
    } else {
      const { error: appointmentTypeError } = await supabase
        .from('appointment_types')
        .update({
          type_name: editScheduleData.value.appointment_type.type_name,
          description: editScheduleData.value.appointment_type.description,
        })
        .eq('appointment_type_id', editScheduleData.value.appointment_type_id)

      if (appointmentTypeError) {
        console.error('Error updating appointment type:', appointmentTypeError.message)
      } else {
        showEditModal.value = false
        showModal.value = false
        const staffId = await fetchStaffId()
        if (staffId) {
          await fetchMySchedules(staffId)
        }
      }
    }
  } catch (err) {
    console.error('Unexpected error updating schedule:', err.message)
  }
}

const deleteSchedule = async () => {
  try {
    const { error } = await supabase
      .from('schedules')
      .delete()
      .eq('schedule_id', selectedSchedule.value.schedule_id)

    if (error) {
      console.error('Error deleting schedule:', error.message)
    } else {
      showModal.value = false
      const staffId = await fetchStaffId()
      if (staffId) {
        await fetchMySchedules(staffId)
      }
    }
  } catch (err) {
    console.error('Unexpected error deleting schedule:', err.message)
  }
}

const showReason = (reason) => {
  appointmentReason.value = reason
  showReasonModal.value = true
}

onMounted(async () => {
  await fetchAvailableSchedules()
  const staffId = await fetchStaffId()
  if (staffId) {
    await fetchMySchedules(staffId)
  }
})
</script>

<style scoped>
.hover-card {
  cursor: pointer;
  transition: transform 0.2s;
}
.hover-card:hover {
  transform: scale(1.02);
}
</style>
