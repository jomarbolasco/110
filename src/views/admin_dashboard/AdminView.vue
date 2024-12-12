<template>
  <form @submit.prevent="bookAppointment">
    <!-- Patient Information -->
    <div>
      <label> <input type="checkbox" v-model="forSomeoneElse" /> Booking for someone else </label>
    </div>
    <div v-if="forSomeoneElse">
      <label for="otherPatientName">Patient Name:</label>
      <input type="text" id="otherPatientName" v-model="otherPatientName" />
    </div>
    <div v-else>
      <label for="patientName">Patient Name:</label>
      <input type="text" id="patientName" v-model="patientName" readonly />
    </div>

    <!-- Select Medical Staff -->
    <div>
      <label for="staff">Select Medical Staff:</label>
      <select id="staff" v-model="selectedStaff">
        <option v-for="staff in medicalStaff" :key="staff.staff_id" :value="staff.staff_id">
          {{ staff.name }}
        </option>
      </select>
    </div>

    <!-- Appointment Details -->
    <div>
      <label for="appointmentDateTime">Appointment Date & Time:</label>
      <input
        type="datetime-local"
        id="appointmentDateTime"
        v-model="appointmentDateTime"
        required
      />
    </div>
    <div>
      <label for="appointmentType">Appointment Type:</label>
      <select id="appointmentType" v-model="selectedAppointmentType">
        <option
          v-for="type in appointmentTypes"
          :key="type.appointment_type_id"
          :value="type.appointment_type_id"
        >
          {{ type.type_name }}
        </option>
      </select>
    </div>
    <div>
      <label for="reason">Reason for Appointment:</label>
      <textarea id="reason" v-model="reason" rows="4"></textarea>
    </div>

    <!-- Schedule Information -->
    <div>
      <label for="schedule">Available Schedule:</label>
      <select id="schedule" v-model="selectedSchedule">
        <option
          v-for="schedule in schedules"
          :key="schedule.schedule_id"
          :value="schedule.schedule_id"
        >
          {{ schedule.day_of_week }} {{ schedule.start_time }} - {{ schedule.end_time }}
        </option>
      </select>
    </div>

    <!-- Submit Button -->
    <button type="submit">Book Appointment</button>
  </form>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'

// Define refs for form fields
const forSomeoneElse = ref(false)
const patientName = ref('Pre-filled Patient Name') // Assuming patient name is pre-filled
const otherPatientName = ref('')
const selectedStaff = ref(null)
const appointmentDateTime = ref(null)
const selectedAppointmentType = ref(null)
const reason = ref('')
const selectedSchedule = ref(null)

// Data arrays for dropdowns
const medicalStaff = ref([])
const appointmentTypes = ref([])
const schedules = ref([])

// Fetch data on component mount
onMounted(async () => {
  try {
    // Fetch medical staff data
    let { data: staffData, error: staffError } = await supabase
      .from('medical_staff')
      .select('staff_id, name')
    if (staffError) throw staffError
    medicalStaff.value = staffData

    // Fetch appointment types data
    let { data: typeData, error: typeError } = await supabase
      .from('appointment_types')
      .select('appointment_type_id, type_name')
    if (typeError) throw typeError
    appointmentTypes.value = typeData

    // Fetch schedule data
    let { data: scheduleData, error: scheduleError } = await supabase
      .from('schedules')
      .select('schedule_id, day_of_week, start_time, end_time')
    if (scheduleError) throw scheduleError
    schedules.value = scheduleData
  } catch (error) {
    console.error('Error fetching data:', error)
  }
})

// Function to handle form submission
const bookAppointment = async () => {
  try {
    const appointmentData = {
      patient_id: forSomeoneElse.value ? null : 1, // Replace with actual patient_id if booking for self
      patient_name: forSomeoneElse.value ? otherPatientName.value : patientName.value,
      staff_id: selectedStaff.value,
      appointment_date_time: appointmentDateTime.value,
      appointment_type_id: selectedAppointmentType.value,
      reason: reason.value,
      schedule_id: selectedSchedule.value,
      status: 'scheduled',
      booked_by_user_id: 'user-uuid', // Replace with actual user id from auth
    }

    let { error } = await supabase.from('appointments').insert(appointmentData)
    if (error) throw error

    console.log('Appointment booked successfully')
  } catch (error) {
    console.error('Error booking appointment:', error)
  }
}
</script>

<style scoped>
/* General form styling */
form {
  max-width: 600px;
  margin: auto;
  padding: 1.5rem;
  border: 1px solid #ccc;
  border-radius: 8px;
  background-color: #f9f9f9;
}

/* Form field styling */
div {
  margin-bottom: 1rem;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: bold;
}

input,
select,
textarea {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  background-color: #fff;
  box-sizing: border-box;
}

/* Submit button styling */
button {
  width: 100%;
  padding: 0.75rem;
  background-color: #007bff;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: bold;
  text-align: center;
}

button:hover {
  background-color: #0056b3;
}

/* Responsive styling */
@media (max-width: 600px) {
  form {
    padding: 1rem;
  }

  button {
    padding: 0.5rem;
    font-size: 0.875rem;
  }
}
</style>
