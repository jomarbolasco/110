<script setup>
import { ref, watch } from 'vue'
import { supabase, formActionDefault } from '@/components/util/supabase'
import {
  requiredValidator,
  emailValidator,
  passwordValidator,
  confirmedValidator,
} from '@/components/util/validators'

// Form state
const form = ref({
  userType: 'normal', // default user type
  email: '',
  password: '',
  confirmPassword: '',
  name: '',
  age: '', // for normal user
  gender: 'male', // for normal user
  contact_information: '',
  role: 'doctor', // for medical staff, can be 'doctor' or 'nurse'
  specialization: '', // for medical staff
})

// Form action state
const formAction = ref({ ...formActionDefault })

// Watcher for form reset on userType change
watch(
  () => form.value.userType,
  () => {
    form.value.name = ''
    form.value.contact_information = ''
    if (form.value.userType === 'normal') {
      form.value.age = ''
      form.value.gender = 'male'
    } else {
      form.value.role = 'doctor'
      form.value.specialization = ''
    }
  },
)

// Form submit handler
const handleSubmit = async () => {
  formAction.value.formProcess = true

  // Form validation
  const emailError = emailValidator(form.value.email)
  const passwordError = passwordValidator(form.value.password)
  const confirmPasswordError = confirmedValidator(form.value.confirmPassword, form.value.password)

  if (emailError !== true || passwordError !== true || confirmPasswordError !== true) {
    formAction.value.formStatus = 400
    formAction.value.formErrorMessage =
      `${emailError || ''} ${passwordError || ''} ${confirmPasswordError || ''}`.trim()
    formAction.value.formProcess = false
    return
  }

  // Supabase registration
  const { user, error } = await supabase.auth.signUp({
    email: form.value.email,
    password: form.value.password,
  })

  if (error) {
    formAction.value.formStatus = error.status
    formAction.value.formErrorMessage = error.message
  } else {
    if (form.value.userType === 'normal') {
      // Insert additional user information into patients table
      const { data, error: dbError } = await supabase.from('patients').insert([
        {
          user_id: user.id,
          name: form.value.name,
          age: form.value.age,
          gender: form.value.gender,
          contact_information: form.value.contact_information,
        },
      ])

      if (dbError) {
        formAction.value.formStatus = dbError.status
        formAction.value.formErrorMessage = dbError.message
      } else {
        formAction.value.formStatus = 200
        formAction.value.formSuccessMessage =
          'Registration successful! Please check your email for verification.'
      }
    } else if (form.value.userType === 'medical') {
      // Insert additional user information into medicalstaff table
      const { data, error: dbError } = await supabase.from('medicalstaff').insert([
        {
          name: form.value.name,
          role: form.value.role,
          specialization: form.value.specialization,
          contact_information: form.value.contact_information,
          user_id: user.id, // Assuming you have a user_id column in medicalstaff
        },
      ])

      if (dbError) {
        formAction.value.formStatus = dbError.status
        formAction.value.formErrorMessage = dbError.message
      } else {
        formAction.value.formStatus = 200
        formAction.value.formSuccessMessage =
          'Registration successful! Please check your email for verification.'
      }
    }
  }
  formAction.value.formProcess = false
}
</script>

<template>
  <form @submit.prevent="handleSubmit">
    <div>
      <label for="userType">I am a:</label>
      <select id="userType" v-model="form.userType">
        <option value="normal">Normal User</option>
        <option value="medical">Medical Staff</option>
      </select>
    </div>

    <div>
      <label for="email">Email</label>
      <input type="email" id="email" v-model="form.email" required />
    </div>

    <div>
      <label for="password">Password</label>
      <input type="password" id="password" v-model="form.password" required />
    </div>

    <div>
      <label for="confirmPassword">Confirm Password</label>
      <input type="password" id="confirmPassword" v-model="form.confirmPassword" required />
    </div>

    <div v-if="form.userType === 'normal'">
      <label for="name">Name</label>
      <input type="text" id="name" v-model="form.name" required />

      <label for="age">Age</label>
      <input type="number" id="age" v-model="form.age" required />

      <label for="gender">Gender</label>
      <select id="gender" v-model="form.gender" required>
        <option value="male">Male</option>
        <option value="female">Female</option>
        <option value="other">Other</option>
      </select>

      <label for="contact_information">Contact Information</label>
      <input type="text" id="contact_information" v-model="form.contact_information" required />
    </div>

    <div v-if="form.userType === 'medical'">
      <label for="name">Name</label>
      <input type="text" id="name" v-model="form.name" required />

      <label for="role">Role</label>
      <select id="role" v-model="form.role" required>
        <option value="doctor">Doctor</option>
        <option value="nurse">Nurse</option>
      </select>

      <label for="specialization">Specialization</label>
      <input type="text" id="specialization" v-model="form.specialization" required />

      <label for="contact_information">Contact Information</label>
      <input type="text" id="contact_information" v-model="form.contact_information" required />
    </div>

    <div v-if="formAction.formErrorMessage">
      <p style="color: red">{{ formAction.formErrorMessage }}</p>
    </div>

    <div v-if="formAction.formSuccessMessage">
      <p style="color: green">{{ formAction.formSuccessMessage }}</p>
    </div>

    <div>
      <button type="submit" :disabled="formAction.formProcess">Register</button>
    </div>
  </form>
</template>

<style scoped>
/* Add some basic styling */
div {
  margin-bottom: 1em;
}

label {
  display: block;
  margin-bottom: 0.5em;
}

input,
select {
  width: 100%;
  padding: 0.5em;
  margin-bottom: 0.5em;
}

button {
  padding: 0.5em 1em;
}
</style>
