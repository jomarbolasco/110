<script setup>
import '@fortawesome/fontawesome-free/css/all.css'
import '@fortawesome/fontawesome-free/js/all.js'
import '@fortawesome/fontawesome-free/css/all.css'

import { RouterView } from 'vue-router'
// import { useUserStore } from '@/stores/user'
// import { useRouter } from 'vue-router'

// const userStore = useUserStore()
// const router = useRouter()

// router.beforeEach(async (to, from, next) => {
//   if (!userStore.user && userStore.initializeUser) {
//     await userStore.initializeUser()
//   }

//   if (to.meta.requiresAuth && !userStore.user) {
//     next('/login') // Redirect unauthenticated users
//   } else if ((to.path === '/login' || to.path === '/register') && userStore.user) {
//     next('/dashboard') // Redirect logged-in users
//   } else {
//     next()
//   }
// })
</script>

<template>
  <RouterView />
</template>
