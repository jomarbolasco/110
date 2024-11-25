import { createRouter, createWebHistory } from 'vue-router'
import homeView from '@/homeView.vue'
import loginView from '@/views/auth/loginView.vue'
import RegisterView from '@/views/auth/RegisterView.vue'

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
    // {
    //   path: '/dashboard',
    //   name: 'dashboard',
    //   component: FullLayout,
    // },
    {
      path: '/dashboard',
      component: () => import('@/components/layout/full/fullLayout.vue'),
      children: [
        {
          name: 'Dashboard',
          path: '',
          component: () => import('@/views/dashboard/DashBoard.vue'),
        },
        {
          name: 'Alerts',
          path: 'ui-components/alert',
          component: () => import('@/views/ui-components/Alerts.vue'),
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
        {
          path: '/:pathMatch(.*)*',
          redirect: '/',
        },
      ],
    },
  ],
})

export default router
