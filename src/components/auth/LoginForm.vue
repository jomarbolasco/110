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
const message = ref('')
const messageType = ref('error') // Type for v-alert

const onSubmit = async () => {
  loading.value = true
  message.value = ''
  messageType.value = 'error'

  try {
    const { error, data } = await supabase.auth.signInWithPassword({
      email: formData.value.email,
      password: formData.value.password,
    })

    if (error) {
      message.value = error.message
    } else {
      // Fetch the user details
      const user = data.user

      // Check the user's role and redirect accordingly
      if (user.user_metadata.role === 'admin') {
        router.replace('/admin')
      } else {
        router.replace('/dashboard')
      }

      messageType.value = 'success'
      message.value = 'Login successful!'
      console.log(data)
    }
  } catch (error) {
    message.value = 'An unexpected error occurred. Please try again.'
    messageType.value = 'error'
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

    <!-- Display message with dynamic color -->
    <v-alert :type="messageType" v-if="message" class="text-caption">
      {{ message }}
    </v-alert>

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
