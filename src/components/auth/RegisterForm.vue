<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '@/components/util/supabase'
import { useUserStore } from '@/stores/user'
import {
  requiredValidator,
  emailValidator,
  passwordValidator,
  confirmedValidator,
} from '@/components/util/validators'

// Router and user store
const router = useRouter()
const userStore = useUserStore()

// Form state
const formData = ref({
  email: '',
  password: '',
  password_confirmation: '',
  profile_picture: '',
})

const formAction = ref({
  formProcess: false,
  formErrorMessage: '',
})

// Form reference for validation
const refVForm = ref()
const visible = ref(false)

// Hash password securely
const hashPassword = async (password) => {
  return btoa(password) // Replace with a secure hash function in production
}

// Handle form submission
const onSubmit = async () => {
  formAction.value.formProcess = true
  try {
    // Step 1: Register the user in Supabase Auth
    const { data, error } = await supabase.auth.signUp({
      email: formData.value.email,
      password: formData.value.password,
    })

    if (error) throw error

    // Step 2: Insert user data into the `users` table
    const { data: userData, error: insertError } = await supabase
      .from('users')
      .insert({
        email: formData.value.email,
        password_hash: await hashPassword(formData.value.password),
        profile_picture: formData.value.profile_picture || null,
      })
      .single()

    if (insertError) throw insertError

    // Step 3: Automatically log the user in
    const { data: session } = await supabase.auth.getSession()
    if (session?.session?.user) {
      userStore.setUser({
        id: session.session.user.id,
        email: session.session.user.email,
      })
    }

    // Step 4: Redirect to the dashboard
    router.push('/dashboard')
  } catch (error) {
    console.error('Error during registration:', error.message)
    formAction.value.formErrorMessage = error.message
  } finally {
    formAction.value.formProcess = false
  }
}

// Validate and submit the form
const onFormSubmit = () => {
  refVForm.value.validate().then(({ valid }) => {
    if (valid) onSubmit()
  })
}
</script>

<template>
  <v-form ref="refVForm" @submit.prevent="onFormSubmit">
    <v-row>
      <v-col cols="12">
        <v-text-field
          v-model="formData.email"
          :rules="[requiredValidator, emailValidator]"
          prepend-inner-icon="mdi-email-outline"
          label="Email"
          density="compact"
          variant="outlined"
        />
      </v-col>

      <v-col cols="12">
        <v-text-field
          v-model="formData.password"
          :rules="[requiredValidator, passwordValidator]"
          prepend-inner-icon="mdi-lock-outline"
          :append-inner-icon="visible ? 'mdi-eye-off' : 'mdi-eye'"
          :type="visible ? 'text' : 'password'"
          label="Password"
          density="compact"
          variant="outlined"
          @click:append-inner="visible = !visible"
        />
      </v-col>

      <v-col cols="12">
        <v-text-field
          v-model="formData.password_confirmation"
          :rules="[confirmedValidator(formData.password_confirmation, formData.password)]"
          prepend-inner-icon="mdi-lock-outline"
          :append-inner-icon="visible ? 'mdi-eye-off' : 'mdi-eye'"
          :type="visible ? 'text' : 'password'"
          label="Password Confirmation"
          density="compact"
          variant="outlined"
          @click:append-inner="visible = !visible"
        />
      </v-col>

      <v-col cols="12">
        <v-text-field
          v-model="formData.profile_picture"
          label="Profile Picture (Optional)"
          density="compact"
          variant="outlined"
        />
      </v-col>

      <v-btn
        class="mb-8"
        color="blue"
        size="large"
        variant="tonal"
        block
        type="submit"
        :disabled="formAction.formProcess"
        :loading="formAction.formProcess"
      >
        Register
      </v-btn>
    </v-row>
    <p v-if="formAction.formErrorMessage" class="error-message">
      {{ formAction.formErrorMessage }}
    </p>
  </v-form>
</template>

<style>
.error-message {
  color: red;
}
</style>
