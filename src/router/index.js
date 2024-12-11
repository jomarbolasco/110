import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/userStore' // Import your user store

import homeView from '@/homeView.vue'
import loginView from '@/views/auth/loginView.vue'
import RegisterView from '@/views/auth/RegisterView.vue'
import AdminView from '@/views/admin_dashboard/AdminView.vue'
import ForgotPassword from '@/views/auth/ForgotPassword.vue'
import ResetPassword from '@/views/auth/ResetPassword.vue'
// import fullLayout from '@/components/layout/full/fullLayout.vue'
import AppointmentView from '@/views/ui-components/AppointmentView.vue'

const routes = [
  {
    path: '/',
    name: 'home',
    component: homeView,
  },
  {
    path: '/Admin',
    name: 'admin',
    component: AdminView,
  },
  {
    path: '/login',
    name: 'login',
    component: loginView,
    meta: { requiresGuest: true }, // Restrict to guests
  },
  {
    path: '/register',
    name: 'register',
    component: RegisterView,
    meta: { requiresGuest: true }, // Restrict to guests
  },
  {
    path: '/forgot-password',
    name: 'ForgotPassword',
    component: ForgotPassword,
  },
  {
    path: '/reset-password',
    name: 'ResetPassword',
    component: ResetPassword,
  },
  {
    path: '/',
    component: () => import('@/components/layout/full/fullLayout.vue'),
    meta: { requiresAuth: true }, // Restrict to authenticated users
    children: [
      {
        name: 'Dashboard',
        path: 'dashboard',
        component: () => import('@/views/dashboard/DashBoard.vue'),
      },
      {
        name: 'Appointments',
        path: 'ui-components/Appointments',
        // component: () => import('@/views/ui-components/AppointmentView.vue'),
        component: AppointmentView,
      },
      {
        name: 'AskMe',
        path: 'ui-components/Ai-section/AskMe',
        component: () => import('@/views/ui-components/Ai-section/AskMe.vue'),
      },
      {
        name: 'Buttons',
        path: 'ui-components/buttons',
        component: () => import('@/views/ui-components/Buttons.vue'),
      },
      {
        name: 'Cards',
        path: 'ui-components/cards',
        component: () => import('@/views/ui-components/Cards.vue'),
      },
      {
        name: 'Menus',
        path: 'ui-components/menus',
        component: () => import('@/views/ui-components/Menus.vue'),
      },
      {
        name: 'Tables',
        path: 'ui-components/tables',
        component: () => import('@/views/ui-components/Tables.vue'),
      },
    ],
  },
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
})

// Add a global `beforeEach` navigation guard
router.beforeEach(async (to, from, next) => {
  const userStore = useUserStore()

  // Initialize user if not already done
  if (!userStore.user && userStore.initializeUser) {
    await userStore.initializeUser()
  }

  // Log for debugging purposes
  console.log('Navigation Guard - User:', userStore.user)

  // Handle authentication checks
  if (to.meta.requiresAuth && !userStore.user) {
    console.log('Redirecting to login') // Log for debugging
    next('/login') // Redirect unauthenticated users to login
  } else if ((to.path === '/login' || to.path === '/register') && userStore.user) {
    console.log('Redirecting to dashboard') // Log for debugging
    next('/dashboard') // Redirect authenticated users to the dashboard
  } else {
    next() // Allow the navigation
  }
})

export default router
