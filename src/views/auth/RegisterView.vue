<script setup>
import RegisterForm from '@/components/auth/RegisterForm.vue'
import { ref } from 'vue' //theme color

const theme = ref('dark') //theme color
</script>

<template>
  <v-responsive>
    <v-app :theme="theme">
      <v-app-bar class="px-3">
        <v-btn append-icon="mdi-home" prepend-icon="mdi-check-circle">
          <template v-slot:prepend>
            <!-- <v-icon color="success"></v-icon> -->
          </template>
          <RouterLink style="text-decoration: none" to="/">HOME</RouterLink>
          <template v-slot:append>
            <v-icon color="warning"></v-icon>
          </template>
        </v-btn>
        <v-spacer></v-spacer>

        <v-btn append-icon="mdi-account" prepend-icon="mdi-check-circle">
          <template v-slot:prepend>
            <!-- <v-icon color="success"></v-icon> -->
          </template>
          <RouterLink style="text-decoration: none" to="/login">Login</RouterLink>
          <template v-slot:append>
            <v-icon color="warning"></v-icon>
          </template>
        </v-btn>

        <v-btn active append-icon="mdi-account-plus" prepend-icon="mdi-check-circle">
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
          <v-row>
            <v-col cols="12" md="5">
              <div>
                <v-img
                  class="mx-auto my-6"
                  max-width="228"
                  src="https://cdn.vuetifyjs.com/docs/images/logos/vuetify-logo-v3-slim-text-light.svg"
                ></v-img>
                <v-card class="mx-auto pa-12 pb-8" elevation="8" max-width="448" rounded="lg">
                  <v-divider class="mb-5" />

                  <RegisterForm />

                  <v-divider class="my-5" />
                  <v-card-text class="text-center">
                    <RouterLink
                      to="/login"
                      class="text-blue text-decoration-none"
                      rel="noopener noreferrer"
                    >
                      Login now <v-icon icon="mdi-login"></v-icon>
                    </RouterLink>
                  </v-card-text>
                </v-card>
              </div>
            </v-col>
          </v-row>
        </v-container>
      </v-main>
    </v-app>
  </v-responsive>
</template>
