import { createRouter, createWebHistory } from 'vue-router'
import homeView from '@/homeView.vue'
import loginView from '@/views/auth/loginView.vue'
import RegisterView from '@/views/auth/RegisterView.vue'
import FullLayout from '@/components/layout/full/fullLayout.vue'

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
    {
      path: '/register',
      name: 'register',
      component: RegisterView,
    },
    {
      path: '/dashboard',
      name: 'dashboard',
      component: FullLayout,
    },
  ],
})

export default router
