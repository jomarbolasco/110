import { createRouter, createWebHistory } from 'vue-router'

import homeView from '@/homeView.vue'
import loginView from '@/views/auth/loginView.vue'
import RegisterView from '@/views/auth/RegisterView.vue'
import AdminView from '@/views/admin_dashboard/AdminView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'admin_dashboard/AdminView',
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
    },
    {
      path: '/register',
      name: 'register',
      component: RegisterView,
    },
    {
      path: '/dashboard',
      component: () => import('@/components/layout/full/fullLayout.vue'),
      meta: { requiresAuth: true }, // Add `requiresAuth` meta to protect the dashboard route
      children: [
        {
          name: '/dashboard',
          path: '',
          component: () => import('@/views/dashboard/DashBoard.vue'),
        },
        {
          name: '/Appointments',
          path: 'ui-components/Appointments',
          component: () => import('@/views/ui-components/AppointmentView.vue'),
        },
        // {
        //   name: '/AdminView',
        //   path: 'admin_dashboard/AdminView',
        //   component: () => import('@/views/admin_dashboard/AdminView.vue'),
        // },
        // {
        //   name: '/askmedoc',
        //   path: 'ui-components/Ai-section/askmedoc',
        //   component: () => import('@/views/ui-components/Ai-section/askmedoc.vue'),
        // },
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

        // {
        //   path: '/:pathMatch(.*)*',
        //   redirect: '/',
        // },
      ],
    },
  ],
})

// // Add a global `beforeEach` navigation guard
// router.beforeEach(async (to, from, next) => {
//   const userStore = useUserStore()

//   // Initialize user if not already done
//   if (!userStore.user && userStore.initializeUser) {
//     await userStore.initializeUser()
//   }

//   // Handle authentication checks
//   if (to.meta.requiresAuth && !userStore.user) {
//     next('/login') // Redirect unauthenticated users to login
//   } else if ((to.path === '/login' || to.path === '/register') && userStore.user) {
//     next('/dashboard') // Redirect authenticated users to the dashboard
//   } else {
//     next() // Allow the navigation
//   }
// })

export default router
