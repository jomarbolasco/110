<script setup>
import { ref } from 'vue'

const theme = ref('dark')
</script>

<template>
  <v-responsive>
    <v-app :theme="theme">
      <v-app-bar class="px-3">
        <v-spacer></v-spacer>
        <v-btn active append-icon="mdi-account-circle" prepend-icon="mdi-check-circle">
          <template v-slot:prepend>
            <!-- <v-icon color="success"></v-icon> -->
          </template>
          Login
          <template v-slot:append>
            <v-icon color="warning"></v-icon>
          </template>
        </v-btn>
      </v-app-bar>

      <v-main>
        <v-container>
          <v-row>
            <v-col cols="12" md="6" class="mx-auto">
              <v-card
                class="mx-auto"
                prepend-icon="mdi-account"
                subtitle="short description here"
                width="400"
              >
                <template v-slot:title>
                  <span class="font-weight-black">App Title here</span>
                </template>

                <v-card-text class="bg-surface-light pt-4">
                  <v-form fast-fail @submit.prevent>
                    <v-text-field label="First name"></v-text-field>

                    <v-text-field label="Last name"></v-text-field>

                    <v-btn class="mt-2" type="submit" block>Submit</v-btn>
                  </v-form>
                </v-card-text>
              </v-card>
            </v-col>
          </v-row>
        </v-container>
      </v-main>
    </v-app>
  </v-responsive>
</template>
