<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'

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
const editAppointmentId = ref(null)
const formStatus = ref('')
const formMessage = ref('')

// Fetch data on mount
onMounted(async () => {
  try {
    // Fetch hospitals
    const { data: hospitalData, error: hospitalError } = await supabase
      .from('Hospitals')
      .select('*')
    if (hospitalError) throw hospitalError
    hospitals.value = hospitalData

    // Fetch user and their appointments
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

// Book or update an appointment
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

    let response
    if (editAppointmentId.value) {
      response = await supabase
        .from('Appointments')
        .update(payload)
        .eq('id', editAppointmentId.value)
    } else {
      response = await supabase.from('Appointments').insert(payload)
    }

    if (response.error) throw response.error

    formStatus.value = 'success'
    formMessage.value = editAppointmentId.value
      ? 'Appointment updated successfully!'
      : 'Appointment booked successfully!'
    editAppointmentId.value = null
    await refreshAppointments()
  } catch (error) {
    formStatus.value = 'error'
    formMessage.value = error.message
    console.error('Error saving appointment:', error.message)
  }
}

// Delete an appointment
const deleteAppointment = async (id) => {
  try {
    const { error } = await supabase.from('Appointments').delete().eq('id', id)
    if (error) throw error
    await refreshAppointments()
  } catch (error) {
    console.error('Error deleting appointment:', error.message)
  }
}

// Refresh appointments list
const refreshAppointments = async () => {
  try {
    const { data: appointmentData, error: appointmentError } = await supabase
      .from('Appointments')
      .select(
        'id, appointment_date, appointment_time, status, Doctors(name, specialty), Hospitals(name)',
      )
      .eq('user_id', user.value.id)

    console.log(appointmentData) // Log to check the data structure

    if (appointmentError) throw appointmentError
    appointments.value = appointmentData
  } catch (error) {
    console.error('Error fetching appointments:', error.message)
  }
}

// Populate form for editing
const editAppointment = (appointment) => {
  editAppointmentId.value = appointment.id
  selectedHospital.value = appointment.Hospitals?.id || null
  selectedDoctor.value = appointment.Doctors?.id || null
  selectedDate.value = appointment.appointment_date
  selectedTime.value = appointment.appointment_time
}
</script>

<template>
  <div class="appointment-container">
    <h2>Book or Edit Appointment</h2>

    <!-- Form Messages -->
    <div v-if="formStatus === 'error'" class="error-message">{{ formMessage }}</div>
    <div v-if="formStatus === 'success'" class="success-message">{{ formMessage }}</div>

    <!-- Appointment Form -->
    <div class="form-group">
      <label for="hospital">Select Hospital:</label>
      <select v-model="selectedHospital" @change="fetchDoctors">
        <option value="" disabled>Select a hospital</option>
        <option v-for="hospital in hospitals" :key="hospital.id" :value="hospital.id">
          {{ hospital.name }}
        </option>
      </select>
    </div>

    <div class="form-group">
      <label for="doctor">Select Doctor:</label>
      <select v-model="selectedDoctor" @change="fetchSchedules" :disabled="!selectedHospital">
        <option value="" disabled>Select a doctor</option>
        <option v-for="doctor in doctors" :key="doctor.id" :value="doctor.id">
          {{ doctor.name }} - {{ doctor.specialty }}
        </option>
      </select>
    </div>

    <div class="form-group">
      <label for="appointment-date">Select Date:</label>
      <input type="date" v-model="selectedDate" :disabled="!selectedDoctor" />
    </div>

    <div class="form-group">
      <label for="appointment-time">Select Time:</label>
      <select v-model="selectedTime" :disabled="!selectedDate">
        <option value="" disabled>Select a time slot</option>
        <option v-for="schedule in schedules" :key="schedule.id" :value="schedule.start_time">
          {{ schedule.start_time }} - {{ schedule.end_time }}
        </option>
      </select>
    </div>

    <button
      @click="saveAppointment"
      :disabled="!selectedDate || !selectedTime || !selectedDoctor || !selectedHospital"
    >
      {{ editAppointmentId ? 'Update Appointment' : 'Book Appointment' }}
    </button>

    <!-- Appointments List -->
    <h3>Your Appointments</h3>
    <ul v-if="appointments.length > 0">
      <li v-for="appointment in appointments" :key="appointment.id">
        {{ appointment.appointment_date }} with
        {{ appointment.Hospitals?.name || 'Unknown Hospital' }}
        (Status: {{ appointment.status }})
        <button @click="editAppointment(appointment)">Edit</button>
        <button @click="deleteAppointment(appointment.id)">Delete</button>
      </li>
    </ul>
    <p v-else>No appointments found</p>
  </div>
</template>

<style scoped>
/* Base styles */
* {
  font-family: 'Roboto', sans-serif;
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  background-color: #f4511e;
  color: #444;
  font-size: 16px;
}

.appointment-container {
  max-width: 750px;
  margin: 2rem auto;
  padding: 2rem;
  background-color: #ffffff;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.appointment-container:hover {
  transform: scale(1.02);
}

h2,
h3 {
  text-align: center;
  color: #333;
}

h2 {
  font-size: 2rem;
  margin-bottom: 1rem;
}

h3 {
  margin-top: 2rem;
  font-size: 1.5rem;
}

.form-group {
  margin-bottom: 1.5em;
}

label {
  display: block;
  font-size: 1.1rem;
  margin-bottom: 0.5em;
  color: #444;
}

select,
input {
  width: 100%;
  padding: 0.75em;
  font-size: 1rem;
  border: 1px solid #ccc;
  border-radius: 8px;
  transition: border 0.3s;
  color: black;
  background-color: #2ecc71;
}

select:focus,
input:focus {
  border-color: #3498db;
  outline: none;
}

button {
  width: 100%;
  padding: 1em;
  font-size: 1.2rem;
  background-color: #2ecc71;
  color: white;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

button:hover {
  background-color: #27ae60;
}

button:disabled {
  background-color: #dfe6e9;
}

.message {
  display: block;
  padding: 1rem;
  margin-bottom: 1.5rem;
  text-align: center;
  font-weight: bold;
  border-radius: 8px;
}

.error-message {
  color: #fff;
  background-color: #e74c3c;
}

.success-message {
  color: #fff;
  background-color: #2ecc71;
}

.appointments-list {
  list-style: none;
  padding: 0;
  color: #fff;
  background-color: #2ecc71;
}

.appointments-list li {
  padding: 1rem;
  border-bottom: 1px solid #eee;
  font-size: 1rem;
  color: #333;
}

.appointments-list li:last-child {
  border-bottom: none;
}
</style>
