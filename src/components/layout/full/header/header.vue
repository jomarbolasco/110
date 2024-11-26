<script setup lang="ts">
import { ref } from 'vue'
import { useUserStore } from '@/stores/user'
import { useRouter } from 'vue-router'
import { supabase } from '@/components/util/supabase'

// User store and router setup
const userStore = useUserStore()
const router = useRouter()

// Fetch user profile from Supabase
const fetchUserProfile = async () => {
  if (!userStore.user) {
    await userStore.initializeUser() // Initialize user if not already loaded
  }
}

import { onMounted } from 'vue'

onMounted(() => {
  fetchUserProfile()
})

// Logout function
const logout = async () => {
  await supabase.auth.signOut()
  userStore.logout()
  router.push('/login')
}

// Dynamic profile items (example)
const profile = ref([
  {
    title: 'My Profile',
    desc: 'Account Settings',
    action: () => router.push('/profile'),
  },
  {
    title: 'My Inbox',
    desc: 'Messages & Emails',
    action: () => router.push('/inbox'),
  },
  {
    title: 'My Tasks',
    desc: 'To-do and Daily Tasks',
    action: () => router.push('/tasks'),
  },
])

// import { profile } from './data'

// const userprofile = ref(profile)
</script>

<template>
  <div>
    <!-- ---------------------------------------------- -->
    <!-- User Profile Dropdown -->
    <!-- ---------------------------------------------- -->
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
          <v-avatar size="50">
            <img src="./images/me (2 x 2 in).png" alt="profile-pic" width="60" height="60" />
          </v-avatar>
        </v-btn>
      </template>

      <v-list class="pa-6" elevation="10" rounded="lg">
        <!-- Dynamic user info -->
        <v-list-item class="pa-3 mb-4">
          <div>
            <h3>Welcome, {{ userStore.user?.name }}</h3>
            <p>Email: {{ userStore.user?.email }}</p>
          </div>
        </v-list-item>

        <!-- Profile menu items -->
        <v-list-item
          class="pa-3 mb-2"
          v-for="(item, i) in profile"
          :key="i"
          :title="item.title"
          :subtitle="item.desc"
          rounded="lg"
          @click="item.action"
        ></v-list-item>

        <!-- Logout button -->
        <v-btn block color="secondary" variant="elevated" class="mt-4 py-4" @click="logout">
          Logout
        </v-btn>
      </v-list>
    </v-menu>
  </div>
</template>
