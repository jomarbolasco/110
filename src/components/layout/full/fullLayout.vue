<script setup lang="ts">
import { RouterView } from 'vue-router'
import { ref, onMounted } from 'vue'
import SideBar from './sidebar/sideBar.vue'
import { useUserStore } from '@/stores/userStore'
import HeaderVue from './header/header.vue'

const userStore = useUserStore()
const theme = ref(localStorage.getItem('theme') ?? 'dark')
const drawer = ref(true)
const innerW = window.innerWidth

onMounted(() => {
  if (innerW < 950) {
    drawer.value = !drawer.value
  }
})
</script>

<template>
  <v-app :theme="theme">
    <!-- Sidebar -->
    <v-navigation-drawer
      left
      :permanent="$vuetify.display.mdAndUp"
      elevation="10"
      app
      :temporary="$vuetify.display.mdAndDown"
      v-model="drawer"
      expand-on-hover
    >
      <SideBar />
    </v-navigation-drawer>

    <!-- Header -->
    <v-app-bar elevation="0" class="v-topbar">
      <v-app-bar-nav-icon class="hidden-md-and-up" @click="drawer = !drawer" />
      <div>
        <h2 class="mx-5">Welcome, {{ userStore.user?.name }}</h2>
      </div>
      <v-spacer />
      <HeaderVue />
    </v-app-bar>

    <!-- Page Wrapper -->
    <v-main>
      <v-container fluid class="page-wrapper">
        <RouterView />
      </v-container>
    </v-main>
  </v-app>
</template>
