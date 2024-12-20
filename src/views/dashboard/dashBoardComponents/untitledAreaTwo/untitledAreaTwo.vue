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
    const { error } = await supabase
      .from('appointments')
      .update({ status: 'cancelled' })
      .eq('appointment_id', selectedSchedule.value.appointment_id)

    if (error) {
      console.error('Error cancelling appointment:', error.message)
    } else {
      await userStore.fetchBookedSchedules()
      closeModal()
    }
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
  <v-card class="w-100 h-100">
    <v-card-title>Your Booked Schedules</v-card-title>
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
                <strong>{{ schedule.schedules.appointment_types.type_name }}</strong>
              </v-card-title>
              <v-card-subtitle>
                on {{ new Date(schedule.appointment_date_time).toLocaleString() }}
              </v-card-subtitle>
              <v-card-text>
                <div>
                  Status: <strong>{{ schedule.status }}</strong>
                </div>
                <div>Reason: {{ schedule.reason }}</div>
                <div v-if="schedule.schedules.medical_staff.name">
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
        <span class="text-h5">Modify Appointment</span>
      </v-card-title>
      <v-card-text>
        <div>
          <strong>Type:</strong> {{ selectedSchedule?.schedules?.appointment_types?.type_name }}
        </div>
        <div>
          <strong>Date:</strong>
          {{ new Date(selectedSchedule?.appointment_date_time).toLocaleString() }}
        </div>
        <div><strong>Status:</strong> {{ selectedSchedule?.status }}</div>
        <div><strong>Reason:</strong> {{ selectedSchedule?.reason }}</div>
        <div v-if="selectedSchedule?.schedules?.medical_staff?.name">
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
          >Cancel Appointment</v-btn
        >
        <v-btn v-else color="red" text @click="deleteAppointment">Delete Appointment</v-btn>
        <v-btn color="blue darken-1" text @click="closeModal">Close</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
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
