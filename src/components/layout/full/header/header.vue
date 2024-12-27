<!-- eslint-disable vue/multi-word-component-names -->
<script setup lang="ts">
import { ref } from 'vue'
import { useUserStore } from '@/stores/userStore'
import { useRouter } from 'vue-router'
import { supabase } from '@/components/util/supabase'

// Store and router
const userStore = useUserStore()
const router = useRouter()

// Alert state
const alertMessage = ref<String>('')
const alertType = ref<'error' | 'success' | 'info' | 'warning'>('info') // Initialize with a valid type

// Logout function
const logout = async () => {
  try {
    await supabase.auth.signOut()
    console.log('Supabase sign-out successful') // Log for debugging
    userStore.logout()
    console.log('User state after logout:', userStore.user) // Log for debugging

    alertMessage.value = 'Logout successful!'
    alertType.value = 'success'

    // Show alert message for a short duration before redirecting
    setTimeout(async () => {
      await router.push('/')
      console.log('Redirected to home') // Log for debugging
    }, 1000) // 2 seconds delay
  } catch (error) {
    console.error('Error during logout:', error)
    alertMessage.value = 'Error during logout. Please try again.'
    alertType.value = 'error'
  }
}
</script>

<template>
  <div>
    <v-btn class="logout-btn" elevation="1" @click="logout"> Logout </v-btn>
  </div>
</template>

<style scoped>
.logout-btn {
  font-weight: bold;
  margin: 10px;
  padding: 10px 20px;
  color: black;
  background: linear-gradient(90deg, rgba(236, 62, 62, 0.678), purple);
}
</style>
