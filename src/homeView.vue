<script setup>
import { ref } from 'vue'

const theme = ref('dark')
</script>

<template>
  <v-responsive>
    <v-app :theme="theme">
      <v-app-bar class="px-3">
        <v-spacer></v-spacer>

        <v-btn append-icon="mdi-account-circle" prepend-icon="mdi-check-circle">
          <template v-slot:prepend>
            <!-- <v-icon color="success"></v-icon> -->
          </template>
          <RouterLink style="text-decoration: none" to="/login">Login</RouterLink>
          <template v-slot:append>
            <v-icon color="warning"></v-icon>
          </template>
        </v-btn>

        <v-btn append-icon="mdi-account-plus" prepend-icon="mdi-check-circle">
          <template v-slot:prepend>
            <!-- <v-icon color="success"></v-icon> -->
          </template>
          <RouterLink style="text-decoration: none" to="/register">Sign-up</RouterLink>
          <template v-slot:append>
            <v-icon color="warning"></v-icon>
          </template>
        </v-btn>
      </v-app-bar>

      <v-main>
        <v-container>
          <h1>Application picture here</h1>
        </v-container>
      </v-main>
    </v-app>
  </v-responsive>
</template>
