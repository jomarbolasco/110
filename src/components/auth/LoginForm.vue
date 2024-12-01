<script setup>
import { requiredValidator, emailValidator } from '@/components/util/validators'
import { ref } from 'vue'
import { supabase } from '@/components/util/supabase'
import { useRouter } from 'vue-router'

const refVForm = ref()

const router = useRouter()

const formDataDefault = {
  email: '',
  password: '',
}

const formData = ref({
  ...formDataDefault,
})

const loading = ref(false)
const errorMessage = ref('')

const onSubmit = async () => {
  loading.value = true
  errorMessage.value = ''

  try {
    const { error, data } = await supabase.auth.signInWithPassword({
      email: formData.value.email,
      password: formData.value.password,
    })

    if (error) {
      errorMessage.value = error.message
    } else {
      // Redirect to a protected route or dashboard
      alert('Login successful!')
      console.log(data)
      router.replace('/dashboard')
    }
  } catch (error) {
    errorMessage.value = 'An unexpected error occurred. Please try again.'
    console.error(error)
  } finally {
    loading.value = false
  }
}

const onFormSubmit = () => {
  refVForm.value.validate().then(({ valid }) => {
    if (valid) onSubmit()
  })
}
</script>

<script>
export default {
  data: () => ({
    visible: false,
  }),
}
</script>

<template>
  <div class="text-subtitle-1 text-medium-emphasis">Account</div>

  <v-form ref="refVForm" @submit.prevent="onFormSubmit">
    <v-text-field
      v-model="formData.email"
      :rules="[requiredValidator, emailValidator]"
      density="compact"
      placeholder="Email address"
      prepend-inner-icon="mdi-email-outline"
      variant="outlined"
    ></v-text-field>

    <div class="text-subtitle-1 text-medium-emphasis d-flex align-center justify-space-between">
      Password

      <!-- change password button -->
      <!-- <a
                      class="text-caption text-decoration-none text-blue"
                      href="#"
                      rel="noopener noreferrer"
                      target="_blank"
                    >
                      Forgot login password?</a
                    > -->
    </div>

    <v-text-field
      v-model="formData.password"
      :append-inner-icon="visible ? 'mdi-eye-off' : 'mdi-eye'"
      :type="visible ? 'text' : 'password'"
      :rules="[requiredValidator]"
      density="compact"
      placeholder="Enter your password"
      prepend-inner-icon="mdi-lock-outline"
      variant="outlined"
      @click:append-inner="visible = !visible"
    ></v-text-field>

    <!-- <v-card class="mb-12" color="surface-variant" variant="tonal">
                    <v-card-text class="text-medium-emphasis text-caption">
                      Warning: After 3 consecutive failed login attempts, you account will be
                      temporarily locked for three hours. If you must login now, you can also click
                      "Forgot login password?" below to reset the login password.
                    </v-card-text>
                  </v-card> -->

    <v-btn
      :disabled="loading"
      class="mb-8"
      color="blue"
      size="large"
      variant="tonal"
      block
      type="submit"
    >
      <span v-if="loading">Logging in...</span>
      <span v-else>Log In</span>
    </v-btn>

    <p v-if="errorMessage" class="text-red text-caption">{{ errorMessage }}</p>

    <v-card-text class="text-center">
      <p>
        Don't have account?
        <RouterLink to="/register" class="text-blue text-decoration-none" rel="noopener noreferrer">
          Sign up now <v-icon icon="mdi-account-plus-outline"></v-icon>
        </RouterLink>
      </p>
    </v-card-text>
  </v-form>
</template>
