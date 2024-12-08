<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'

// Helper functions for formatting
const formatDate = (date) => {
  const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }
  return new Date(date).toLocaleDateString(undefined, options)
}

const formatTime = (time) => {
  const [hours, minutes] = time.split(':').map(Number)
  const period = hours >= 12 ? 'PM' : 'AM'
  const formattedHours = hours % 12 || 12 // Convert to 12-hour format
  return `${formattedHours}:${minutes.toString().padStart(2, '0')} ${period}`
}

const schedules = ref([])
const bookedSchedules = ref([])
const selectedSchedule = ref(null)
const user = ref(null)
const loading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const page = ref(0)
const pageSize = 5 // For pagination

// Fetch data on component mount
onMounted(async () => {
  await fetchUser()
  await fetchSchedules()
  await fetchBookedSchedules()
})

const fetchUser = async () => {
  const { data, error } = await supabase.auth.getUser()
  if (error) {
    console.error('Error fetching user:', error)
  } else {
    user.value = data.user
  }
}

const fetchSchedules = async () => {
  const { data, error } = await supabase
    .from('schedules')
    .select(
      `
      schedule_id,
      date,
      start_time,
      end_time,
      available_slots,
      medicalstaff (
        staff_id,
        name
      )
    `,
    )
    .gt('available_slots', 0) // Only fetch schedules with available slots
    .order('date', { ascending: true })
    .order('start_time', { ascending: true })
    .range(page.value * pageSize, (page.value + 1) * pageSize - 1)

  if (error) {
    console.error('Error fetching schedules:', error)
    errorMessage.value = 'An error occurred while fetching schedules.'
  } else {
    schedules.value = data.map((schedule) => ({
      ...schedule,
      formattedDate: formatDate(schedule.date),
      formattedStartTime: formatTime(schedule.start_time),
      formattedEndTime: formatTime(schedule.end_time),
    }))
  }
}

const fetchBookedSchedules = async () => {
  if (!user.value) return

  const { data, error } = await supabase
    .from('appointments')
    .select(
      `
      appointment_id,
      appointment_date,
      appointment_time,
      status,
      staff_id,
      medicalstaff (name)
    `,
    )
    .eq('user_id', user.value.id)

  if (error) {
    console.error('Error fetching booked schedules:', error)
    errorMessage.value = 'An error occurred while fetching booked schedules.'
  } else {
    bookedSchedules.value = data.map((appointment) => ({
      ...appointment,
      medicalstaff: appointment.medicalstaff.name,
      formattedDate: formatDate(appointment.appointment_date),
      formattedTime: formatTime(appointment.appointment_time),
    }))
  }
}

const selectSchedule = (schedule) => {
  selectedSchedule.value = schedule
}

const bookAppointment = async () => {
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  if (user.value && selectedSchedule.value) {
    if (bookedSchedules.value.length > 0) {
      errorMessage.value =
        'You can only book one appointment at a time. Please cancel your existing appointment first.'
      loading.value = false
      return
    }

    const appointmentData = {
      user_id: user.value.id,
      staff_id: selectedSchedule.value.medicalstaff.staff_id,
      appointment_date: selectedSchedule.value.date,
      appointment_time: selectedSchedule.value.start_time,
      status: 'reserved',
    }

    const { error: insertError } = await supabase.from('appointments').insert([appointmentData])
    if (insertError) {
      errorMessage.value = 'An error occurred while booking the appointment.'
      console.error(insertError)
    } else {
      const { error: updateError } = await supabase
        .from('schedules')
        .update({ available_slots: selectedSchedule.value.available_slots - 1 })
        .eq('schedule_id', selectedSchedule.value.schedule_id)

      if (updateError) {
        errorMessage.value = 'Failed to update schedule slots.'
        console.error(updateError)
      } else {
        successMessage.value = 'Appointment booked successfully!'
        selectedSchedule.value = null
        await fetchBookedSchedules()
        await fetchSchedules() // Refresh schedules
      }
    }
  } else {
    errorMessage.value = 'Invalid user or schedule selection.'
  }

  loading.value = false
}

const cancelAppointment = async (appointment_id) => {
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  const { error } = await supabase
    .from('appointments')
    .delete()
    .eq('appointment_id', appointment_id)
  if (error) {
    errorMessage.value = 'An error occurred while canceling the appointment.'
    console.error(error)
  } else {
    successMessage.value = 'Appointment canceled successfully!'
    await fetchBookedSchedules()
    await fetchSchedules() // Refresh schedules
  }

  loading.value = false
}
</script>

<template>
  <v-container class="my-5">
    <v-row>
      <v-col cols="12" md="8" offset-md="2">
        <v-card class="pa-5">
          <v-card-title class="text-h5">Book an Appointment</v-card-title>
          <v-card-subtitle>Manage your appointments with ease.</v-card-subtitle>

          <v-divider class="my-4"></v-divider>

          <v-alert v-if="errorMessage" type="error" class="mb-4">{{ errorMessage }}</v-alert>
          <v-alert v-if="successMessage" type="success" class="mb-4">{{ successMessage }}</v-alert>

          <v-card class="mb-4">
            <v-card-title class="text-h6">Available Schedules</v-card-title>
            <v-card-text>
              <v-list v-if="schedules.length > 0">
                <v-list-item v-for="schedule in schedules" :key="schedule.schedule_id">
                  <v-list-item-title>
                    {{ schedule.formattedDate }}: {{ schedule.formattedStartTime }} to
                    {{ schedule.formattedEndTime }}
                  </v-list-item-title>
                  <v-list-item-subtitle>
                    with {{ schedule.medicalstaff.name }}
                  </v-list-item-subtitle>

                  <v-list-item-action>
                    <v-btn
                      @click="() => selectSchedule(schedule)"
                      :disabled="schedule.available_slots === 0"
                    >
                      Select
                    </v-btn>
                  </v-list-item-action>
                </v-list-item>
              </v-list>
              <v-alert v-else type="info">No schedules available at the moment.</v-alert>
            </v-card-text>
          </v-card>

          <v-form v-if="selectedSchedule" @submit.prevent="bookAppointment">
            <v-card class="mb-4">
              <v-card-title class="text-h6">Selected Schedule</v-card-title>
              <v-card-text>
                <p>Date: {{ selectedSchedule.formattedDate }}</p>
                <p>
                  Time: {{ selectedSchedule.formattedStartTime }} to
                  {{ selectedSchedule.formattedEndTime }}
                </p>
                <p>With: {{ selectedSchedule.medicalstaff.name }}</p>
              </v-card-text>
              <v-card-actions>
                <v-btn type="submit" :loading="loading">Confirm Appointment</v-btn>
              </v-card-actions>
            </v-card>
          </v-form>

          <v-card v-if="bookedSchedules.length > 0" class="mb-4">
            <v-card-title class="text-h6">Your Booked Schedules</v-card-title>
            <v-card-text>
              <v-list>
                <v-list-item v-for="booked in bookedSchedules" :key="booked.appointment_id">
                  <v-list-item-title>
                    {{ booked.formattedDate }}: {{ booked.formattedTime }}
                  </v-list-item-title>
                  <v-list-item-subtitle>
                    with {{ booked.medicalstaff }} - {{ booked.status }}
                  </v-list-item-subtitle>

                  <v-list-item-action>
                    <v-btn @click="() => cancelAppointment(booked.appointment_id)" color="red">
                      Cancel
                    </v-btn>
                  </v-list-item-action>
                </v-list-item>
              </v-list>
            </v-card-text>
          </v-card>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>
