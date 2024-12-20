<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/userStore'
import { supabase } from '@/components/util/supabase'

const userStore = useUserStore()
const selectedSchedule = ref(null)
const showModal = ref(false)

const openModal = (schedule) => {
  selectedSchedule.value = schedule
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  selectedSchedule.value = null
}

const cancelAppointment = async () => {
  if (!selectedSchedule.value) return

  try {
    // Step 1: Cancel the appointment
    const { error: appointmentError } = await supabase
      .from('appointments')
      .update({ status: 'cancelled' })
      .eq('appointment_id', selectedSchedule.value.appointment_id)

    if (appointmentError) {
      console.error('Error cancelling appointment:', appointmentError.message)
      return
    }

    // Step 2: Retrieve the current available slots
    const { data: scheduleData, error: fetchError } = await supabase
      .from('schedules')
      .select('available_slots')
      .eq('schedule_id', selectedSchedule.value.schedules.schedule_id)
      .single()

    if (fetchError) {
      console.error('Error fetching schedule:', fetchError.message)
      return
    }

    const currentAvailableSlots = scheduleData.available_slots

    // Step 3: Increment the available slots
    const { error: slotError } = await supabase
      .from('schedules')
      .update({ available_slots: currentAvailableSlots + 1 })
      .eq('schedule_id', selectedSchedule.value.schedules.schedule_id)

    if (slotError) {
      console.error('Error updating available slots:', slotError.message)
      return
    }

    // Step 4: Refresh the user's booked schedules
    await userStore.fetchBookedSchedules()
    closeModal()
    window.location.reload() // Refresh the browser
  } catch (err) {
    console.error('Unexpected error cancelling appointment:', err.message)
  }
}

const deleteAppointment = async () => {
  if (!selectedSchedule.value) return

  try {
    const { error } = await supabase
      .from('appointments')
      .delete()
      .eq('appointment_id', selectedSchedule.value.appointment_id)

    if (error) {
      console.error('Error deleting appointment:', error.message)
    } else {
      await userStore.fetchBookedSchedules()
      closeModal()
    }
  } catch (err) {
    console.error('Unexpected error deleting appointment:', err.message)
  }
}

onMounted(async () => {
  await userStore.fetchBookedSchedules()
})
</script>

<template>
  <v-container class="py-5">
    <v-card class="w-100 h-100">
      <v-card-title>
        <v-icon class="mr-2" color="primary">mdi-calendar</v-icon>
        Your Booked Schedules
      </v-card-title>
      <v-card-text>
        <v-container>
          <v-row v-if="userStore.bookedSchedules.length > 0" dense>
            <v-col
              v-for="schedule in userStore.bookedSchedules"
              :key="schedule.appointment_id"
              cols="12"
              md="6"
            >
              <v-card class="mb-4 hover-card" outlined @click="openModal(schedule)">
                <v-card-title>
                  <v-icon class="mr-2" color="primary">mdi-calendar-check</v-icon>
                  <strong>{{ schedule.schedules.appointment_types.type_name }}</strong>
                </v-card-title>
                <v-card-subtitle>
                  <v-icon class="mr-2" color="primary">mdi-clock</v-icon>
                  on {{ new Date(schedule.appointment_date_time).toLocaleString() }}
                </v-card-subtitle>
                <v-card-text>
                  <div>
                    <v-icon class="mr-2" color="green darken-2">mdi-check-circle</v-icon>
                    Status: <strong>{{ schedule.status }}</strong>
                  </div>
                  <div>
                    <v-icon class="mr-2" color="blue darken-2">mdi-comment</v-icon>
                    Reason: {{ schedule.reason }}
                  </div>
                  <div v-if="schedule.schedules.medical_staff.name">
                    <v-icon class="mr-2" color="orange darken-2">mdi-account</v-icon>
                    <strong>Assigned Staff:</strong> {{ schedule.schedules.medical_staff.name }}
                  </div>
                </v-card-text>
              </v-card>
            </v-col>
          </v-row>
          <v-row v-else>
            <v-col cols="12">
              <v-alert type="info" border="start" colored-border>
                No booked schedules found.
              </v-alert>
            </v-col>
          </v-row>
        </v-container>
      </v-card-text>
    </v-card>

    <v-dialog v-model="showModal" max-width="600px">
      <v-card>
        <v-card-title>
          <v-icon class="mr-2" color="primary">mdi-pencil</v-icon>
          <span class="text-h5">Modify Appointment</span>
        </v-card-title>
        <v-card-text>
          <div>
            <v-icon class="mr-2" color="primary">mdi-calendar</v-icon>
            <strong>Type:</strong> {{ selectedSchedule?.schedules?.appointment_types?.type_name }}
          </div>
          <div>
            <v-icon class="mr-2" color="primary">mdi-clock</v-icon>
            <strong>Date:</strong>
            {{ new Date(selectedSchedule?.appointment_date_time).toLocaleString() }}
          </div>
          <div>
            <v-icon class="mr-2" color="green darken-2">mdi-check-circle</v-icon>
            <strong>Status:</strong> {{ selectedSchedule?.status }}
          </div>
          <div>
            <v-icon class="mr-2" color="blue darken-2">mdi-comment</v-icon>
            <strong>Reason:</strong> {{ selectedSchedule?.reason }}
          </div>
          <div v-if="selectedSchedule?.schedules?.medical_staff?.name">
            <v-icon class="mr-2" color="orange darken-2">mdi-account</v-icon>
            <strong>Assigned Staff:</strong> {{ selectedSchedule.schedules.medical_staff.name }}
          </div>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            v-if="selectedSchedule?.status !== 'cancelled'"
            color="red"
            text
            @click="cancelAppointment"
            ><v-icon class="mr-2">mdi-cancel</v-icon>Cancel Appointment</v-btn
          >
          <v-btn v-else color="red" text @click="deleteAppointment">
            <v-icon class="mr-2">mdi-delete</v-icon>Delete Appointment
          </v-btn>
          <v-btn color="blue darken-1" text @click="closeModal">
            <v-icon class="mr-2">mdi-close</v-icon>Close
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<style scoped>
.hover-card {
  cursor: pointer;
  transition: transform 0.2s;
}
.hover-card:hover {
  transform: scale(1.02);
}
.v-container {
  background-color: #423e3e;
  padding: 20px;
  border-radius: 8px;
}
.v-card-title {
  font-weight: bold;
  color: #3f51b5;
  display: flex;
  align-items: center;
}
.v-card-subtitle {
  color: #757575;
  display: flex;
  align-items: center;
}
.v-btn {
  margin: 5px;
}
.v-card-text div {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}
</style>
