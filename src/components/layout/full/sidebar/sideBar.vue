<script setup lang="ts">
import { ref } from 'vue'

const sidebarMenu = ref([
  {
    title: 'Dashboard',
    icon: 'mdi-view-dashboard-outline',
    to: '/dashboard',
  },
  {
    title: 'Appointments',
    icon: 'mdi-check-underline-circle-outline',
    to: '/dashboard/ui-components/Appointments',
  },
  {
    title: 'Ask me Doc!',
    icon: 'mdi-check-underline-circle-outline',
    to: '/dashboard/ui-components/Ai-section/askmedoc',
  },

  {
    title: 'ignore this area',
    icon: 'mdi-radiobox-blank',
    to: '/dashboard/ui-components/buttons',
  },
  {
    title: 'ignore this area',
    icon: 'mdi-card-outline',
    to: '/dashboard/ui-components/cards',
  },
  {
    title: 'ignore this area',
    icon: 'mdi-form-dropdown',
    to: '/dashboard/ui-components/menus',
  },
  {
    title: 'ignore this area',
    icon: 'mdi-table',
    to: '/dashboard/ui-components/tables',
  },
])
</script>

<template>
  <div>
    <!-- ---------------------------------------------- -->
    <!---Logo part -->
    <!-- ---------------------------------------------- -->
    <div class="pa-4">
      <!-- <logoDark /> -->
      <div class="logo">
        <img src="/src/assets/images/logos/logoname.png" alt="Logo" width="200" height="60" />
      </div>
    </div>
    <!-- ---------------------------------------------- -->
    <!---Navigation -->
    <!-- ---------------------------------------------- -->
    <div class="scrollnavbar">
      <v-list class="pa-4" color="transparent">
        <!-- ---------------------------------------------- -->
        <!---Menu Loop -->
        <!-- ---------------------------------------------- -->
        <template v-for="(item, i) in sidebarMenu" :key="i">
          <!-- ---------------------------------------------- -->
          <!---Single Item-->
          <!-- ---------------------------------------------- -->
          <v-list-item :to="item.to" rounded="lg" class="mb-1">
            <v-avatar class="me-3">
              <v-icon class="feather-sm v-icon v-icon--size-default">{{ item.icon }}</v-icon>
            </v-avatar>
            <v-list-item-title v-text="item.title"></v-list-item-title>
          </v-list-item>
        </template>
      </v-list>
    </div>
    <div class="pa-4 ma-4 bg-light-primary rounded-lg text-center">
      <img src="./images/logofavicon.png " width="100" height="100" />
      <h4 class="font-weight-regular mb-3">HospiAPP</h4>
      <v-btn class="mb-2" href="" block>sample button</v-btn>
      <v-btn color="info" href="" block>button sample</v-btn>
    </div>
  </div>
</template>
