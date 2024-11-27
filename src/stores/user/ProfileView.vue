<script setup>
import { useUserStore } from '@/stores/user'
import { useRouter } from 'vue-router'
import { supabase } from '@/components/util/supabase.js'

const userStore = useUserStore()
const router = useRouter()

const logout = async () => {
  await supabase.auth.signOut()
  userStore.logout()
  router.push('/login')
}
</script>

<template>
  <div v-if="userStore.user">
    <h1>Welcome, {{ userStore.user.name }}</h1>
    <p>Email: {{ userStore.user.email }}</p>
    <v-btn color="error" @click="logout">Logout</v-btn>
  </div>
</template>
