<template>
  <div class="register-form-container">
    <div class="form-header">
      <h2>Register</h2>
      <p>Please fill out the form to create your account</p>
    </div>
    <div class="form-content">
      <!-- User Type Selector -->
      <div class="form-group">
        <label for="userType">I am a</label>
        <select v-model="userType" id="userType">
          <option value="normal">Normal User</option>
          <option value="medicalStaff">Medical Staff</option>
        </select>
      </div>
      <!-- Common Fields -->
      <div class="form-group">
        <label for="email">Email</label>
        <input type="email" v-model="formData.email" id="email" required />
      </div>
      <div class="form-group">
        <label for="name">Full Name</label>
        <input type="text" v-model="formData.name" id="name" required />
      </div>
      <div class="form-group">
        <label for="dateOfBirth">Date of Birth</label>
        <input type="date" v-model="formData.dateOfBirth" id="dateOfBirth" />
      </div>
      <!-- Gender Field (only for normal users) -->
      <div v-if="userType === 'normal'" class="form-group">
        <label for="gender">Gender</label>
        <select v-model="formData.gender" id="gender">
          <option value="male">Male</option>
          <option value="female">Female</option>
          <option value="other">Other</option>
        </select>
      </div>
      <div class="form-group">
        <label for="phoneNumber">Phone Number</label>
        <input type="text" v-model="formData.phoneNumber" id="phoneNumber" />
      </div>
      <!-- Address Field (for normal users only) -->
      <div v-if="userType === 'normal'" class="form-group">
        <label for="address">Address</label>
        <textarea v-model="formData.address" id="address"></textarea>
      </div>
      <div class="form-group">
        <label for="password">Password</label>
        <input type="password" v-model="formData.password" id="password" required />
      </div>
      <!-- Medical Staff Specific Fields -->
      <div v-if="userType === 'medicalStaff'">
        <div class="form-group">
          <label for="role">Role</label>
          <input type="text" v-model="formData.role" id="role" required />
        </div>
        <div class="form-group">
          <label for="specialization">Specialization</label>
          <input type="text" v-model="formData.specialization" id="specialization" />
        </div>
        <!-- Available Hours Field with Default and Modify Option -->
        <div class="form-group">
          <label for="availableHours">Available Hours</label>
          <p v-if="!isModifyingHours" class="available-hours-display">
            Monday to Friday: 8:00 AM - 5:00 PM
          </p>
          <button v-if="!isModifyingHours" @click="isModifyingHours = true" class="modify-button">
            Modify
          </button>
          <textarea
            v-if="isModifyingHours"
            v-model="formData.availableHours"
            id="availableHours"
            placeholder="Example: {'Monday': '08:00-17:00', 'Tuesday': '08:00-17:00'}"
          ></textarea>
          <p v-if="isModifyingHours" class="hint">
            Default: {"Monday": "08:00-17:00", "Tuesday": "08:00-17:00", "Wednesday": "08:00-17:00",
            "Thursday": "08:00-17:00", "Friday": "08:00-17:00"}
          </p>
        </div>
      </div>
      <!-- Submit Button -->
      <div class="form-group">
        <button @click="handleSubmit">Submit</button>
      </div>
      <!-- Status messages -->
      <div v-if="formStatus === 200" class="success">{{ formSuccessMessage }}</div>
      <div v-if="formStatus !== 200" class="error">{{ formErrorMessage }}</div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { supabase, formActionDefault } from '@/components/util/supabase'
import {
  requiredValidator,
  emailValidator,
  passwordValidator,
  confirmedValidator,
  alphaValidator,
  lengthValidator,
} from '@/components/util/validators' // Import validators

// Reactive form data and status
const userType = ref('normal') // 'normal' or 'medicalStaff'
const formData = ref({
  email: '',
  name: '',
  dateOfBirth: '',
  gender: '',
  phoneNumber: '',
  address: '',
  role: '',
  specialization: '',
  availableHours:
    '{"Monday": "08:00-17:00", "Tuesday": "08:00-17:00", "Wednesday": "08:00-17:00", "Thursday": "08:00-17:00", "Friday": "08:00-17:00"}',
  password: '',
  confirmPassword: '', // Added confirm password field
})

// Toggle editing of available hours
const isModifyingHours = ref(false)
const formStatus = ref(formActionDefault.formStatus)
const formErrorMessage = ref(formActionDefault.formErrorMessage)
const formSuccessMessage = ref(formActionDefault.formSuccessMessage)

// Submit form data
const handleSubmit = async () => {
  // Validate the form fields
  const emailValidation = emailValidator(formData.value.email)
  const passwordValidation = passwordValidator(formData.value.password)
  const confirmPasswordValidation = confirmedValidator(
    formData.value.confirmPassword,
    formData.value.password,
  )
  const nameValidation = requiredValidator(formData.value.name)

  if (emailValidation !== true) {
    formStatus.value = 500
    formErrorMessage.value = emailValidation
    return
  }
  if (passwordValidation !== true) {
    formStatus.value = 500
    formErrorMessage.value = passwordValidation
    return
  }
  if (confirmPasswordValidation !== true) {
    formStatus.value = 500
    formErrorMessage.value = confirmPasswordValidation
    return
  }
  if (nameValidation !== true) {
    formStatus.value = 500
    formErrorMessage.value = nameValidation
    return
  }

  // Handle normal user registration
  if (userType.value === 'normal') {
    const { data: authUser, error: authError } = await supabase.auth.signUp({
      email: formData.value.email,
      password: formData.value.password,
    })
    if (authError) throw authError

    // Once the user is signed up, insert additional data into the 'patients' table
    const { data, error } = await supabase.from('patients').insert([
      {
        user_id: authUser.id, // Link to the user in the auth table
        name: formData.value.name,
        date_of_birth: formData.value.dateOfBirth,
        gender: formData.value.gender,
        phone_number: formData.value.phoneNumber,
        address: formData.value.address,
      },
    ])
    if (error) throw error

    formStatus.value = 200
    formSuccessMessage.value = 'Registration successful!'
  }
  // Handle medical staff registration
  else if (userType.value === 'medicalStaff') {
    const { data: authUser, error: authError } = await supabase.auth.signUp({
      email: formData.value.email,
      password: formData.value.password,
    })
    if (authError) throw authError

    // Once the user is signed up, insert additional data into the 'medical_staff' table
    const { data, error } = await supabase.from('medical_staff').insert([
      {
        user_id: authUser.id, // Link to the user in the auth table
        name: formData.value.name,
        phone_number: formData.value.phoneNumber,
        role: formData.value.role,
        specialization: formData.value.specialization,
        available_hours: formData.value.availableHours,
      },
    ])
    if (error) throw error

    formStatus.value = 200
    formSuccessMessage.value = 'Medical Staff registration successful!'
  }
}
</script>

<style scoped>
.register-form-container {
  width: 100%;
  max-width: 600px;
  margin: 0 auto;
  padding: 20px;
  background-color: #f9f9f9;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}
.form-header {
  text-align: center;
  margin-bottom: 20px;
}
.form-header h2 {
  font-size: 24px;
  margin-bottom: 5px;
}
.form-header p {
  font-size: 14px;
  color: #666;
}
.form-content {
  display: flex;
  flex-direction: column;
}
.form-group {
  margin-bottom: 20px;
}
label {
  font-weight: bold;
  font-size: 14px;
  margin-bottom: 5px;
  color: #333;
}
input,
select,
textarea {
  width: 100%;
  padding: 10px;
  font-size: 14px;
  border: 1px solid #ccc;
  border-radius: 4px;
  box-sizing: border-box;
}
textarea {
  resize: vertical;
  height: 100px;
}
button {
  padding: 10px 20px;
  background-color: #4caf50;
  color: white;
  font-size: 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
button:hover {
  background-color: #45a049;
}
.hint {
  font-size: 12px;
  color: #888;
}
.success {
  color: green;
  margin-top: 20px;
}
.error {
  color: red;
  margin-top: 20px;
}
</style>
