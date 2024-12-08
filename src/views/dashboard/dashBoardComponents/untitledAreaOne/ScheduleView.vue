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
const loading = ref(false)
const errorMessage = ref('')
const page = ref(0)
const pageSize = 5 // For pagination

onMounted(async () => {
  await fetchSchedules()
})

const fetchSchedules = async () => {
  loading.value = true
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
  loading.value = false
}
</script>

<template>
  <v-row>
    <v-col cols="12" md="8" offset-md="2">
      <v-card class="pa-5">
        <v-card-title class="text-h5">Available Schedules</v-card-title>
        <v-card-subtitle>View all available schedules</v-card-subtitle>

        <v-divider class="my-4"></v-divider>

        <v-alert v-if="errorMessage" type="error" class="mb-4">{{ errorMessage }}</v-alert>

        <v-card class="mb-4">
          <v-card-text>
            <v-list v-if="schedules.length > 0">
              <v-list-item v-for="schedule in schedules" :key="schedule.schedule_id">
                <v-list-item-title>
                  {{ schedule.formattedDate }}: {{ schedule.formattedStartTime }} to
                  {{ schedule.formattedEndTime }}
                </v-list-item-title>
                <v-list-item-subtitle> with {{ schedule.medicalstaff.name }} </v-list-item-subtitle>
                <v-list-item-subtitle>
                  Slots left: {{ schedule.available_slots }}
                </v-list-item-subtitle>
              </v-list-item>
            </v-list>
            <v-alert v-else type="info">No schedules available at the moment.</v-alert>
          </v-card-text>
        </v-card>

        <v-btn @click="() => page.value++" :disabled="schedules.length < pageSize">Load More</v-btn>
      </v-card>
    </v-col>
  </v-row>
</template>
