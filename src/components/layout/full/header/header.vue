<script setup lang="ts">
import { ref } from 'vue'
import { useUserStore } from '@/stores/userStore'
import { useRouter } from 'vue-router'
import { supabase } from '@/components/util/supabase'

// Store and router
const userStore = useUserStore()
const router = useRouter()

// Alert state
const alertMessage = ref<string>('')
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
    }, 2000) // 2 seconds delay
  } catch (error) {
    console.error('Error during logout:', error)
    alertMessage.value = 'Error during logout. Please try again.'
    alertType.value = 'error'
  }
}

// Profile menu items
const profile = ref([
  { title: 'My Profile', desc: 'Account Settings', action: () => router.push('/profile') },
  { title: 'My Inbox', desc: 'Messages & Emails', action: () => router.push('/inbox') },
  { title: 'My Tasks', desc: 'To-do and Daily Tasks', action: () => router.push('/tasks') },
])
</script>

<template>
  <div>
    <v-menu anchor="bottom end" origin="auto" min-width="300">
      <template v-slot:activator="{ props }">
        <v-btn
          v-bind="props"
          class="pa-0 px-1"
          elevation="0"
          color="transparent"
          plain
          :ripple="false"
        >
          <v-avatar size="45" class="mx-3">
            <img src="./images/me (2 x 2 in).png" alt="profile-pic" width="50" height="50" />
          </v-avatar>
        </v-btn>
      </template>

      <v-list class="pa-6" elevation="10" rounded="lg">
        <v-list-item class="pa-3 mb-4">
          <div>
            <!-- <h3>Welcome, {{ userStore.user?.name }}</h3> -->
            <p>Email: {{ userStore.user?.email }}</p>
          </div>
        </v-list-item>

        <v-list-item
          class="pa-3 mb-2"
          v-for="(item, i) in profile"
          :key="i"
          :title="item.title"
          :subtitle="item.desc"
          rounded="lg"
          @click="item.action"
        ></v-list-item>

        <v-btn block color="secondary" variant="elevated" class="mt-4 py-4" @click="logout">
          Logout
        </v-btn>
      </v-list>
    </v-menu>

    <!-- Display logout alert message -->
    <v-alert :type="alertType" v-if="alertMessage">
      {{ alertMessage }}
    </v-alert>
  </div>
</template>
