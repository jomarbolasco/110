import { createRouter, createWebHistory } from 'vue-router'
import homeView from '@/homeView.vue'
import loginView from '@/views/auth/loginView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: homeView,
    },
    {
      path: '/login',
      name: 'login',
      component: loginView,
    },
  ],
})

export default router
