<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'
import { useVuetify } from 'vuetify'

// Reactive state
const user = ref(null)
const appointments = ref([])
const hospitals = ref([])
const doctors = ref([])
const schedules = ref([])
const selectedHospital = ref(null)
const selectedDoctor = ref(null)
const selectedDate = ref('')
const selectedTime = ref('')
const formStatus = ref('')
const formMessage = ref('')

// Fetch data on mount
onMounted(async () => {
  try {
    const { data: hospitalData, error: hospitalError } = await supabase
      .from('Hospitals')
      .select('*')
    if (hospitalError) throw hospitalError
    hospitals.value = hospitalData

    const { data: userData, error: userError } = await supabase.auth.getUser()
    user.value = userData?.user

    if (user.value) {
      await refreshAppointments()
    }
  } catch (error) {
    console.error('Error initializing data:', error.message)
  }
})

// Fetch doctors for the selected hospital
const fetchDoctors = async () => {
  try {
    if (!selectedHospital.value) return
    const { data: doctorData, error: doctorError } = await supabase
      .from('Doctors')
      .select('*')
      .eq('id', selectedHospital.value)

    if (doctorError) throw doctorError
    doctors.value = doctorData
  } catch (error) {
    console.error('Error fetching doctors:', error.message)
  }
}

// Fetch schedules for the selected doctor
const fetchSchedules = async () => {
  try {
    if (!selectedDoctor.value) return
    const { data: scheduleData, error: scheduleError } = await supabase
      .from('Schedule')
      .select('*')
      .eq('id', selectedDoctor.value)
      .gt('available_slots', 0)

    if (scheduleError) throw scheduleError
    schedules.value = scheduleData
  } catch (error) {
    console.error('Error fetching schedules:', error.message)
  }
}

// Book an appointment
const saveAppointment = async () => {
  try {
    if (
      !selectedDate.value ||
      !selectedTime.value ||
      !selectedDoctor.value ||
      !selectedHospital.value
    ) {
      formStatus.value = 'error'
      formMessage.value = 'Please fill in all fields.'
      return
    }

    const payload = {
      user_id: user.value.id,
      doctor_id: selectedDoctor.value,
      appointment_date: selectedDate.value,
      appointment_time: selectedTime.value,
      status: 'Pending',
    }

    const response = await supabase.from('Appointments').insert(payload)
    if (response.error) throw response.error

    formStatus.value = 'success'
    formMessage.value = 'Appointment booked successfully!'
    await refreshAppointments()
  } catch (error) {
    formStatus.value = 'error'
    formMessage.value = error.message
    console.error('Error saving appointment:', error.message)
  }
}

// Refresh appointments list
const refreshAppointments = async () => {
  try {
    const { data: appointmentData, error: appointmentError } = await supabase
      .from('Appointments')
      .select(
        `id,
        appointment_date,
        appointment_time,
        status,
        Doctors (id, name, specialty),
        Hospitals (id, name)`,
      )
      .eq('user_id', user.value.id)

    if (appointmentError) throw appointmentError
    appointments.value = appointmentData
  } catch (error) {
    console.error('Error fetching appointments:', error.message)
  }
}
</script>

<template>
  <v-container>
    <v-card elevation="2" class="pa-4">
      <v-card-title>Book Appointment</v-card-title>

      <v-alert v-if="formStatus === 'error'" type="error" dismissible>
        {{ formMessage }}
      </v-alert>
      <v-alert v-if="formStatus === 'success'" type="success" dismissible>
        {{ formMessage }}
      </v-alert>

      <v-form>
        <v-select
          label="Select Hospital"
          v-model="selectedHospital"
          :items="hospitals"
          item-value="id"
          item-text="name"
          @change="fetchDoctors"
          outlined
        ></v-select>

        <v-select
          label="Select Doctor"
          v-model="selectedDoctor"
          :items="doctors"
          item-value="id"
          item-text="name"
          :disabled="!selectedHospital"
          @change="fetchSchedules"
          outlined
        ></v-select>

        <v-text-field
          label="Select Date"
          v-model="selectedDate"
          type="date"
          :disabled="!selectedDoctor"
          outlined
        ></v-text-field>

        <v-select
          label="Select Time"
          v-model="selectedTime"
          :items="
            schedules.map((schedule) => ({
              value: schedule.start_time,
              text: `${schedule.start_time} - ${schedule.end_time}`,
            }))
          "
          :disabled="!selectedDate"
          outlined
        ></v-select>

        <v-btn
          :disabled="!selectedDate || !selectedTime || !selectedDoctor || !selectedHospital"
          @click="saveAppointment"
        >
          Book Appointment
        </v-btn>
      </v-form>

      <v-divider class="my-4"></v-divider>

      <v-card-title>Your Appointments</v-card-title>
      <v-list v-if="appointments.length > 0">
        <v-list-item v-for="appointment in appointments" :key="appointment.id">
          <v-list-item-content>
            <v-list-item-title>
              {{ appointment.appointment_date }} at {{ appointment.appointment_time }}
            </v-list-item-title>
            <v-list-item-subtitle>
              {{ appointment.Doctors?.name || 'Unknown Doctor' }} ({{
                appointment.Doctors?.specialty || 'No Specialty'
              }}) in {{ appointment.Hospitals?.name || 'Unknown Hospital' }} (Status:
              {{ appointment.status }})
            </v-list-item-subtitle>
          </v-list-item-content>
        </v-list-item>
      </v-list>
      <v-alert v-else type="info">No appointments found.</v-alert>
    </v-card>
  </v-container>
</template>

<style scoped>
.v-card {
  max-width: 600px;
  margin: auto;
}
</style>
