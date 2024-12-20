<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/userStore'

const sidebarMenu = ref([
  {
    title: 'Dashboard',
    icon: 'mdi-view-dashboard-outline',
    to: '/dashboard',
    roles: ['Normal User'], // Accessible by both roles
  },
  {
    title: 'Dashboard',
    icon: 'mdi-view-dashboard-outline',
    to: '/ui-components/StaffDashboard',
    roles: ['Medical Staff'],
  },
  {
    title: 'Appointments',
    icon: 'mdi-form-dropdown',
    to: '/ui-components/Appointments',
    roles: ['Normal User'], // Accessible only by Normal Users
  },

  {
    title: 'Manage Schedules',
    icon: 'mdi-form-dropdown',
    to: '/ui-components/buttons',
    roles: ['Medical Staff'], // Accessible only by Medical Staff
  },
  {
    title: 'Ask me Doc!',
    icon: 'mdi-exclamation-thick',
    to: '/ui-components/Ai-section/AskMe',
    roles: ['Normal User', 'Medical Staff'], // Accessible by both roles
  },

  // {
  //   title: 'ignore this area',
  //   icon: 'mdi-exclamation-thick',
  //   to: '/ui-components/menus',
  // },
  // {
  //   title: 'ignore this area',
  //   icon: 'mdi-exclamation-thick',
  //   to: '/ui-components/tables',
  // },
])

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

// Filter menu items based on the user's role
const filteredSidebarMenu = computed(() => {
  if (!userStore.user) return [] // If no user, show no menu
  const userRole = userStore.user.additionalDetails.role // Assuming `role` is part of `additionalDetails`
  return sidebarMenu.value.filter((item) => item.roles.includes(userRole))
})

const isActive = (item) => route.path === item.to

// Removed unused activeItemTitle computed property

// Method to navigate to the dashboard
const goToDashboard = () => {
  router.push('/dashboard')
}

// Watch for route changes
watch(route, () => {
  // Ensure reactivity on route changes
})
</script>

<template>
  <div>
    <div class="pa-4">
      <div class="logo" @click="goToDashboard" style="cursor: pointer">
        <img src="/src/assets/images/logos/logoname.png" alt="Logo" width="200" height="60" />
      </div>
    </div>
    <div class="scrollnavbar">
      <v-list class="pa-4" color="transparent">
        <template v-for="(item, i) in filteredSidebarMenu" :key="i">
          <v-list-item
            :to="item.to"
            rounded="lg"
            class="mb-1 align-item hover-blue"
            :class="{ 'active-item': isActive(item) }"
          >
            <div class="align-content">
              <v-avatar class="me-3">
                <v-icon class="feather-sm v-icon v-icon--size-default">{{ item.icon }}</v-icon>
              </v-avatar>
              <v-list-item-title class="item-title">{{ item.title }}</v-list-item-title>
            </div>
          </v-list-item>
        </template>
      </v-list>
    </div>
    <div class="pa-4 ma-4 bg-light-primary rounded-lg text-center">
      <img src="./images/logofavicon.png" width="100" height="100" />
      <h4 class="font-weight-regular mb-3">HospiAPP</h4>
      <v-btn class="mb-2" href="" block>Sample button</v-btn>
      <v-btn color="info" href="" block>Button sample</v-btn>
    </div>
  </div>
</template>

<style scoped>
.align-item {
  display: flex;
  align-items: center;
  color: black; /* Default text color */
}

.align-content {
  display: flex;
  align-items: center;
}

.hover-blue:hover {
  background: linear-gradient(90deg, rgba(236, 62, 62, 0.678), purple);
  color: white;
}

.active-item {
  background: linear-gradient(90deg, rgba(236, 62, 62, 0.678), purple);
}

.active-item .item-title {
  color: white; /* Ensure the text color is visible */
}

.active-item .v-icon {
  color: white; /* Ensure the icon color is visible */
}

.active {
  font-weight: bold;
}
</style>
