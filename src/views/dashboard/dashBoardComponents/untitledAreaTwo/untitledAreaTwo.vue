<script setup>
import { ref, onMounted, computed } from 'vue'
import { useUserStore } from '@/stores/userStore'
import { supabase } from '@/components/util/supabase'
import { format } from 'date-fns'

const userStore = useUserStore()
const selectedSchedule = ref(null)
const showModal = ref(false)
const showAlert = ref(false)
const alertMessage = ref('')

const openModal = (schedule) => {
  selectedSchedule.value = schedule
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  selectedSchedule.value = null
}

const isPastSchedule = (schedule) => {
  return new Date(schedule.appointment_date_time) < new Date()
}

const showAlertWithTimeout = (message) => {
  alertMessage.value = message
  showAlert.value = true
  setTimeout(() => {
    showAlert.value = false
  }, 3000)
}

const cancelAppointment = async () => {
  if (!selectedSchedule.value || isPastSchedule(selectedSchedule.value)) {
    showAlertWithTimeout('Cannot cancel an appointment for a past schedule.')
    return
  }

  try {
    const { error: appointmentError } = await supabase
      .from('appointments')
      .update({ status: 'cancelled' })
      .eq('appointment_id', selectedSchedule.value.appointment_id)

    if (appointmentError) {
      console.error('Error cancelling appointment:', appointmentError.message)
      return
    }

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

    const { error: slotError } = await supabase
      .from('schedules')
      .update({ available_slots: currentAvailableSlots + 1 })
      .eq('schedule_id', selectedSchedule.value.schedules.schedule_id)

    if (slotError) {
      console.error('Error updating available slots:', slotError.message)
      return
    }

    await userStore.fetchBookedSchedules()
    closeModal()
  } catch (err) {
    console.error('Unexpected error cancelling appointment:', err.message)
  }
}

const deleteAppointment = async () => {
  if (!selectedSchedule.value) {
    showAlertWithTimeout('Cannot delete an appointment without a selected schedule.')
    return
  }

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

const formatSchedule = (schedule) => {
  return {
    ...schedule,
    formattedDateTime: format(new Date(schedule.appointment_date_time), 'MMMM d, yyyy h:mm a'),
  }
}

const formattedSchedules = computed(() => userStore.bookedSchedules.map(formatSchedule))

onMounted(async () => {
  await userStore.fetchBookedSchedules()
})
</script>

<template>
  <v-card class="w-100 h-100">
    <v-card-title>
      <v-icon class="mr-2" color="white">mdi-calendar</v-icon>
      Your Booked Schedules
    </v-card-title>
    <v-card-text>
      <v-container>
        <v-row v-if="formattedSchedules.length > 0" dense>
          <v-col
            v-for="schedule in formattedSchedules"
            :key="schedule.appointment_id"
            cols="12"
            md="6"
          >
            <v-card
              class="mb-4 hover-card"
              outlined
              @click="openModal(schedule)"
              :color="
                schedule.status === 'scheduled'
                  ? 'success'
                  : schedule.status === 'cancelled'
                    ? 'warning'
                    : ''
              "
              :text-color="
                schedule.status === 'scheduled' || schedule.status === 'cancelled' ? 'white' : ''
              "
            >
              <v-card-title>
                <v-icon class="mr-2" color="blue">mdi-clock-outline</v-icon>
                <strong>{{ schedule.schedules.appointment_types.type_name }}</strong>
              </v-card-title>
              <v-card-subtitle>
                <v-icon class="mr-1" color="grey">mdi-calendar-clock</v-icon>
                {{ schedule.formattedDateTime }}
              </v-card-subtitle>
              <v-card-text>
                <div>
                  <v-icon class="mr-1" color="green">mdi-checkbox-marked-circle</v-icon>
                  Status: <strong>{{ schedule.status }}</strong>
                </div>
                <div>
                  <v-icon class="mr-1" color="grey">mdi-comment</v-icon>
                  Reason: {{ schedule.reason }}
                </div>
                <div v-if="schedule.schedules.medical_staff.name">
                  <v-icon class="mr-1" color="blue">mdi-account</v-icon>
                  Assigned Staff: {{ schedule.schedules.medical_staff.name }}
                </div>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
        <v-row v-else>
          <v-col cols="12">
            <v-alert type="info" border="start" colored-border>
              <v-icon class="mr-2">mdi-information-outline</v-icon>
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
        <v-icon class="mr-2" color="blue">mdi-calendar-edit</v-icon>
        Appointment
      </v-card-title>
      <v-card-text>
        <v-alert v-if="showAlert" type="error" dismissible @click:close="showAlert = false">
          {{ alertMessage }}
        </v-alert>
        <div>
          <strong>Type:</strong> {{ selectedSchedule?.schedules?.appointment_types?.type_name }}
        </div>
        <div>
          <strong>Date:</strong>
          {{
            selectedSchedule
              ? format(new Date(selectedSchedule.appointment_date_time), 'MMMM d, yyyy h:mm a')
              : ''
          }}
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
        >
          <v-icon left>mdi-cancel</v-icon>
          Cancel Appointment
        </v-btn>
        <v-btn v-else color="red" text @click="deleteAppointment">
          <v-icon left>mdi-delete</v-icon>
          Delete Appointment
        </v-btn>
        <v-btn color="blue darken-1" text @click="closeModal">
          <v-icon left>mdi-close</v-icon>
          Close
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<style scoped>
.hover-card {
  cursor: pointer;
  transition:
    transform 0.2s,
    box-shadow 0.2s;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.hover-card:hover {
  transform: scale(1.02);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}

.v-card-subtitle {
  color: black;
  font-size: 14px;
}

.v-alert {
  background-color: #e3f2fd;
  color: #1976d2;
  font-weight: bold;
}

.v-btn {
  margin: 8px;
}

.text-h5 {
  font-size: 1.5rem;
  font-weight: bold;
}
.v-card-title {
  /* background: linear-gradient(90deg, rgba(236, 62, 62, 0.678), purple); */
  color: white;
  padding: 16px;
  font-weight: bold;
}
</style>
