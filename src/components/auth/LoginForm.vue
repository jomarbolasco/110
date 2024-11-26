<script setup>
import { requiredValidator, emailValidator } from '@/components/util/validators'
import { ref } from 'vue'
import { supabase } from '@/components/util/supabase'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'

const refVForm = ref()
const router = useRouter()
const userStore = useUserStore()

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
    const { data, error } = await supabase.auth.signInWithPassword({
      email: formData.value.email,
      password: formData.value.password,
    })

    if (error) {
      errorMessage.value = 'Invalid email or password. Please try again.'
      console.error(error.message)
      return
    }

    // Store user session
    userStore.setUser({
      name: data.user.user_metadata?.name || '',
      email: data.user.email,
    })

    const { data: session } = await supabase.auth.getSession()
    if (session?.session?.user) {
      userStore.setUser({
        name: session.session.user.user_metadata?.name || '',
        email: session.session.user.email,
      })
    }

    alert('Login successful!')
    router.replace('/dashboard')
  } catch (err) {
    errorMessage.value = 'An unexpected error occurred. Please try again.'
    console.error(err)
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
    <!-- Email Field -->
    <v-text-field
      v-model="formData.email"
      :rules="[requiredValidator, emailValidator]"
      density="compact"
      placeholder="Email address"
      prepend-inner-icon="mdi-email-outline"
      variant="outlined"
    ></v-text-field>

    <!-- Password Field -->
    <div class="text-subtitle-1 text-medium-emphasis d-flex align-center justify-space-between">
      Password
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

    <!-- Submit Button -->
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

    <!-- Error Message -->
    <p v-if="errorMessage" class="text-red text-caption">{{ errorMessage }}</p>

    <!-- Sign Up Link -->
    <v-card-text class="text-center">
      <p>
        Don't have an account?
        <RouterLink to="/register" class="text-blue text-decoration-none" rel="noopener noreferrer">
          Sign up now <v-icon icon="mdi-account-plus-outline"></v-icon>
        </RouterLink>
      </p>
    </v-card-text>
  </v-form>
</template>
