<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'

const availableSchedules = ref([])

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

onMounted(async () => {
  await fetchAvailableSchedules()
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
            <v-card class="mb-4" outlined color="grey lighten-5">
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
            <v-alert type="info" border="left" colored-border>
              No available schedules found.
            </v-alert>
          </v-col>
        </v-row>
      </v-container>
    </v-card-text>
  </v-card>
</template>
