<template>
  <div>
    <h2>Book an Appointment</h2>
    <form @submit.prevent="submitAppointment">
      <div>
        <label for="staff">Select Staff:</label>
        <select v-model="appointmentData.staff_id">
          <option v-for="staff in medicalStaff" :key="staff.staff_id" :value="staff.staff_id">
            {{ staff.name }}
          </option>
        </select>
      </div>
      <div>
        <label for="date">Date and Time:</label>
        <input type="datetime-local" v-model="appointmentData.appointment_date_time" required />
      </div>
      <div>
        <label for="reason">Reason:</label>
        <textarea v-model="appointmentData.reason" required></textarea>
      </div>
      <button type="submit">Book Appointment</button>
    </form>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { createAppointment, fetchMedicalStaff } from '@/components/util/supabase'

export default {
  setup() {
    const appointmentData = ref({
      staff_id: null,
      appointment_date_time: '',
      reason: '',
      patient_id: null, // Assign this based on logged-in user
      schedule_id: null, // Assign based on selected staff availability
      booked_by_user_id: null, // Assign this based on logged-in user
    })

    const medicalStaff = ref([])

    onMounted(async () => {
      try {
        const data = await fetchMedicalStaff()
        medicalStaff.value = data
      } catch (error) {
        console.error('Error fetching medical staff:', error.message)
      }
    })

    async function submitAppointment() {
      try {
        await createAppointment(appointmentData.value)
        alert('Appointment booked successfully!')
      } catch (error) {
        console.error('Error booking appointment:', error.message)
      }
    }

    return {
      appointmentData,
      medicalStaff,
      submitAppointment,
    }
  },
}
</script>

<style scoped></style>
