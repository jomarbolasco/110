<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const sidebarMenu = ref([
  {
    title: 'Dashboard',
    icon: 'mdi-view-dashboard-outline',
    to: '/dashboard',
  },
  {
    title: 'Appointments',
    icon: 'mdi-form-dropdown',
    to: '/ui-components/Appointments',
  },
  {
    title: 'Ask me Doc!',
    icon: 'mdi-exclamation-thick',
    to: '/ui-components/Ai-section/AskMe',
  },
  {
    title: 'ignore this area',
    icon: 'mdi-exclamation-thick',
    to: '/ui-components/buttons',
  },
  {
    title: 'ignore this area',
    icon: 'mdi-exclamation-thick',
    to: '/ui-components/cards',
  },
  {
    title: 'ignore this area',
    icon: 'mdi-exclamation-thick',
    to: '/ui-components/menus',
  },
  {
    title: 'ignore this area',
    icon: 'mdi-exclamation-thick',
    to: '/ui-components/tables',
  },
])

const route = useRoute()
const router = useRouter()

const isActive = (item) => route.path === item.to

const activeItemTitle = computed(() => {
  const activeItem = sidebarMenu.value.find((item) => isActive(item))
  return activeItem ? activeItem.title : ''
})

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
        <template v-for="(item, i) in sidebarMenu" :key="i">
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
              <v-list-item-title v-text="item.title" class="item-title"></v-list-item-title>
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
</style>
