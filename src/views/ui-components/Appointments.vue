<script setup>
import { ref, reactive, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase' // Adjust the path as per your file structure

// Reactive state for form inputs
const formData = reactive({
  doctorId: '',
  appointmentDate: '',
  appointmentTime: '',
  symptoms: '',
  others: '',
})

// Reactive state for UI feedback and dropdowns
const doctors = ref([])
const availableTimeSlots = ref([])
const isLoading = ref(false)
const message = ref('')

// Fetch list of doctors on component mount
const fetchDoctors = async () => {
  try {
    const { data, error } = await supabase.from('doctors').select('id, name, specialty')

    if (error) throw error
    doctors.value = data
  } catch (err) {
    console.error('Error fetching doctors:', err.message)
  }
}

// Fetch available slots when a doctor and date are selected
const fetchAvailableSlots = async () => {
  if (!formData.doctorId || !formData.appointmentDate) return

  try {
    const { data, error } = await supabase
      .from('schedule')
      .select('start_time, end_time, available_slots')
      .eq('doctor_id', formData.doctorId)
      .eq('date', formData.appointmentDate)

    if (error) throw error

    if (data.length) {
      const slots = []
      const start = data[0].start_time
      const end = data[0].end_time
      const available = data[0].available_slots

      const startTime = new Date(`1970-01-01T${start}`)
      const endTime = new Date(`1970-01-01T${end}`)
      const interval = (endTime - startTime) / (available * 60000)

      for (let i = 0; i < available; i++) {
        const slot = new Date(startTime.getTime() + i * interval)
        slots.push(slot.toISOString().substr(11, 5)) // Format as HH:mm
      }

      availableTimeSlots.value = slots
    } else {
      availableTimeSlots.value = []
    }
  } catch (err) {
    console.error('Error fetching available slots:', err.message)
  }
}

// Submit form data
const submitAppointment = async () => {
  if (!formData.doctorId || !formData.appointmentDate || !formData.appointmentTime) {
    message.value = 'Please fill in all required fields.'
    return
  }

  isLoading.value = true

  try {
    const userId = (await supabase.auth.getUser()).data?.id

    if (!userId) {
      message.value = 'User is not authenticated. Please log in.'
      return
    }

    const { data, error } = await supabase.from('appointments').insert({
      user_id: userId,
      doctor_id: formData.doctorId,
      appointment_date: formData.appointmentDate,
      appointment_time: formData.appointmentTime,
      status: 'Pending',
    })

    if (error) throw error

    await supabase.from('Symptoms').insert({
      appointment_id: data[0].id,
      symptoms_list: formData.symptoms,
      others: formData.others,
    })

    message.value = 'Appointment created successfully!'
  } catch (err) {
    console.error('Error submitting appointment:', err.message)
    message.value = 'Error creating appointment. Please try again.'
  } finally {
    isLoading.value = false
  }
}

// Fetch data on mount
onMounted(() => {
  fetchDoctors()
})

console.log('Available Time Slots:', availableTimeSlots.value)
</script>

<template>
  <div class="appointment-container">
    <h1>Book an Appointment</h1>

    <form @submit.prevent="submitAppointment" class="appointment-form">
      <!-- Doctor Selection -->
      <div class="form-group">
        <label for="doctor">Select Doctor:</label>
        <select v-model="formData.doctorId" @change="fetchAvailableSlots">
          <option value="" disabled>Select a doctor</option>
          <option v-for="doctor in doctors" :key="doctor.id" :value="doctor.id">
            {{ doctor.name }} - {{ doctor.specialty }}
          </option>
        </select>
      </div>

      <!-- Date Selection -->
      <div class="form-group">
        <label for="date">Appointment Date:</label>
        <input type="date" v-model="formData.appointmentDate" @change="fetchAvailableSlots" />
      </div>

      <!-- Time Slot Selection -->
      <div class="form-group">
        <label for="time">Available Time Slots:</label>
        <select v-model="formData.appointmentTime" :disabled="!availableTimeSlots.length">
          <option value="" disabled>Select a time slot</option>
          <option v-for="time in availableTimeSlots" :key="time" :value="time">
            {{ time }}
          </option>
        </select>
      </div>

      <!-- Symptoms -->
      <div class="form-group">
        <label for="symptoms">Symptoms:</label>
        <textarea
          v-model="formData.symptoms"
          placeholder="Describe your symptoms"
          rows="4"
        ></textarea>
      </div>

      <!-- Other Notes -->
      <div class="form-group">
        <label for="others">Other Notes:</label>
        <textarea
          v-model="formData.others"
          placeholder="Additional notes (optional)"
          rows="3"
        ></textarea>
      </div>

      <!-- Submit Button -->
      <div class="form-group">
        <button type="submit" :disabled="isLoading" class="btn-submit">
          {{ isLoading ? 'Submitting...' : 'Book Appointment' }}
        </button>
      </div>
    </form>

    <!-- Feedback Message -->
    <p v-if="message" class="feedback-message">{{ message }}</p>
  </div>
</template>

<style scoped>
.appointment-container {
  max-width: 600px;
  margin: 0 auto;
  padding: 20px;
  background: #2e2b2b;
  border: 1px solid #ddd;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

h1 {
  text-align: center;
  color: #333;
  margin-bottom: 20px;
}

.appointment-form {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.form-group {
  display: flex;
  flex-direction: column;
}

label {
  font-weight: bold;
  margin-bottom: 5px;
}

select,
input[type='date'],
textarea {
  padding: 8px;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-size: 14px;
}

textarea {
  resize: none;
}

select:disabled {
  background: #f2f2f2;
}

.btn-submit {
  background-color: #007bff;
  color: white;
  padding: 10px 15px;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
}

.btn-submit:disabled {
  background-color: #cccccc;
  cursor: not-allowed;
}

.feedback-message {
  margin-top: 15px;
  text-align: center;
  font-size: 14px;
  color: green;
}
</style>
