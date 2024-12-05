<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '@/components/util/supabase'

const router = useRouter()

const password = ref('')
const confirmPassword = ref('')
const message = ref('')
const messageType = (ref < 'error') | ('success' > 'error')

const resetPassword = async () => {
  if (password.value !== confirmPassword.value) {
    messageType.value = 'error'
    message.value = 'Passwords do not match'
    return
  }
  try {
    const { error } = await supabase.auth.updateUser({ password: password.value })
    if (error) throw error

    messageType.value = 'success'
    message.value = 'Password reset successfully!'
    setTimeout(() => {
      router.push('/login')
    }, 2000)
  } catch (error) {
    console.error('Error resetting password:', error)
    messageType.value = 'error'
    message.value = 'Error resetting password. Please try again.'
  }
}

onMounted(async () => {
  const { error } = await supabase.auth.getSessionFromUrl({ storeSession: true })
  if (error) {
    messageType.value = 'error'
    message.value = 'Error handling password reset link. Please try again.'
  }
})
</script>

<template>
  <v-form @submit.prevent="resetPassword">
    <v-text-field v-model="password" label="New Password" type="password" required></v-text-field>
    <v-text-field
      v-model="confirmPassword"
      label="Confirm Password"
      type="password"
      required
    ></v-text-field>
    <v-btn type="submit" color="primary">Reset Password</v-btn>

    <v-alert :type="messageType" v-if="message">{{ message }}</v-alert>
  </v-form>
</template>
