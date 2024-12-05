<script setup>
import { ref } from 'vue'
import { supabase } from '@/components/util/supabase'

const email = ref('')
const message = ref('')
const messageType = (ref < 'error') | ('success' > 'error')

const sendPasswordResetEmail = async () => {
  try {
    const { error } = await supabase.auth.resetPasswordForEmail(email.value, {
      redirectTo: 'http://localhost:5174//reset-password',
    })
    if (error) throw error

    messageType.value = 'success'
    message.value = 'Password reset email sent successfully!'
  } catch (error) {
    console.error('Error sending password reset email:', error)
    messageType.value = 'error'
    message.value = 'Error sending password reset email. Please try again.'
  }
}
</script>

<template>
  <v-form @submit.prevent="sendPasswordResetEmail">
    <v-text-field
      v-model="email"
      label="Email"
      placeholder="Enter your email address"
      required
    ></v-text-field>
    <v-btn type="submit" color="primary">Send Password Reset Email</v-btn>

    <v-alert :type="messageType" v-if="message">{{ message }}</v-alert>
  </v-form>
</template>
