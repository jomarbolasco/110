<script setup>
import { ref } from 'vue'

const theme = ref(localStorage.getItem('theme') ?? 'dark')
</script>

<template>
  <v-responsive>
    <v-app :theme="theme">
      <v-app-bar class="px-3">
        <slot name="navbar"></slot>
      </v-app-bar>

      <v-main>
        <v-container>
          <slot name="content"></slot>
        </v-container>
      </v-main>

      <v-footer class="font-weight-bold" border app>
        <div class="w-100 text-center">Copyright © 2024 - HospiAPP | All Rights Reserved</div>
      </v-footer>
    </v-app>
  </v-responsive>
</template>
