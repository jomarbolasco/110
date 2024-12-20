<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '@/components/util/supabase'
import { useUserStore } from '@/stores/userStore'

const userStore = useUserStore()
const router = useRouter()
const availableSchedules = ref([])
const selectedSchedule = ref(null)
const showModal = ref(false)
const reason = ref('')
const patientId = ref(null)

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

const fetchPatientId = async () => {
  if (!userStore.user) return

  try {
    const { data, error } = await supabase
      .from('patients')
      .select('patient_id')
      .eq('user_id', userStore.user.id)
      .single()

    if (error) {
      console.error('Error fetching patient ID:', error.message)
    } else {
      patientId.value = data.patient_id
    }
  } catch (err) {
    console.error('Unexpected error fetching patient ID:', err.message)
  }
}

const openModal = (schedule) => {
  selectedSchedule.value = schedule
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  selectedSchedule.value = null
  reason.value = ''
}

const bookAppointment = async () => {
  if (!selectedSchedule.value || !patientId.value) return

  try {
    const { error: insertError } = await supabase.from('appointments').insert({
      patient_id: patientId.value, // Use the fetched patient ID
      schedule_id: selectedSchedule.value.schedule_id,
      appointment_date_time: new Date(
        selectedSchedule.value.schedule_date + ' ' + selectedSchedule.value.start_time,
      ),
      reason: reason.value,
      status: 'scheduled',
      booked_by_user_id: userStore.user.id,
    })

    if (insertError) {
      console.error('Error booking appointment:', insertError.message)
    } else {
      const { error: updateError } = await supabase
        .from('schedules')
        .update({ available_slots: selectedSchedule.value.available_slots - 1 })
        .eq('schedule_id', selectedSchedule.value.schedule_id)

      if (updateError) {
        console.error('Error updating available slots:', updateError.message)
      } else {
        await fetchAvailableSchedules()
        userStore.fetchBookedSchedules()
        closeModal()
        // router.push('/') // Redirect to the dashboard
      }
    }
  } catch (err) {
    console.error('Unexpected error booking appointment:', err.message)
  }
}

onMounted(async () => {
  await fetchAvailableSchedules()
  await fetchPatientId()
})
</script>

<template>
  <v-card class="w-100 h-100">
    <v-card-title class="text-h5">Available Schedules</v-card-title>
    <v-card-text>
      <v-container>
        <v-row v-if="availableSchedules.length > 0" dense>
          <v-col
            v-for="schedule in availableSchedules"
            :key="schedule.schedule_id"
            cols="12"
            md="6"
          >
            <v-card
              class="mb-4 hover-card"
              outlined
              color="grey lighten-5"
              @click="openModal(schedule)"
            >
              <v-card-title class="text-h6">
                <v-icon class="mr-2" color="blue darken-2">mdi-calendar</v-icon>
                {{ schedule.appointment_types.type_name }}
              </v-card-title>
              <v-card-subtitle>
                <v-icon class="mr-2" color="blue darken-2">mdi-clock</v-icon>
                {{ new Date(schedule.schedule_date).toLocaleDateString() }} from
                {{ schedule.start_time }} to {{ schedule.end_time }}
              </v-card-subtitle>
              <v-card-text>
                <v-row>
                  <v-col cols="12">
                    <v-icon class="mr-2" color="green darken-2">mdi-account-multiple</v-icon>
                    Available Slots: <strong>{{ schedule.available_slots }}</strong>
                  </v-col>
                  <v-col cols="12" v-if="schedule.medical_staff.name">
                    <v-icon class="mr-2" color="orange darken-2">mdi-account</v-icon>
                    Assigned Staff: <strong>{{ schedule.medical_staff.name }}</strong>
                  </v-col>
                </v-row>
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

  <v-dialog v-model="showModal" max-width="600px">
    <v-card>
      <v-card-title>
        <span class="text-h5">Book Appointment</span>
      </v-card-title>
      <v-card-text>
        <div><strong>Type:</strong> {{ selectedSchedule?.appointment_types?.type_name }}</div>
        <div>
          <strong>Date:</strong>
          {{ new Date(selectedSchedule?.schedule_date).toLocaleDateString() }} from
          {{ selectedSchedule?.start_time }} to {{ selectedSchedule?.end_time }}
        </div>
        <div><strong>Assigned Staff:</strong> {{ selectedSchedule?.medical_staff?.name }}</div>
        <v-textarea v-model="reason" label="Reason for Appointment" rows="3"></v-textarea>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="green darken-1" text @click="bookAppointment">Book Appointment</v-btn>
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
