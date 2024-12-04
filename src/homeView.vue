<script setup>
import { ref } from 'vue'

const theme = ref('dark')
</script>

<script>
export default {
  data() {
    return {
      slides: [
        {
          image:
            'https://onhlawoqasmyceacldah.supabase.co/storage/v1/object/public/images/samplehospital1.png',
        },
        {
          image:
            'https://onhlawoqasmyceacldah.supabase.co/storage/v1/object/public/images/samplehospital2.jpg',
        },
        {
          image:
            'https://onhlawoqasmyceacldah.supabase.co/storage/v1/object/public/images/samplehospital3.jpg',
        },
        {
          image:
            'https://onhlawoqasmyceacldah.supabase.co/storage/v1/object/public/images/samplehospital4.jpg',
        },
        {
          image:
            'https://onhlawoqasmyceacldah.supabase.co/storage/v1/object/public/images/samplehospital5.jpg',
        },
      ],
    }
  },
}
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
          <v-carousel height="400" :show-arrows="false" cycle hide-delimiter-background>
            <v-carousel-item v-for="(slide, i) in slides" :key="i">
              <!-- Add the image here -->
              <v-img
                :src="slide.image"
                height="100%"
                class="d-flex justify-center align-center"
                cover
              >
                <!-- Overlay text -->
                <div class="text-h2 white--text">
                  {{ slide.text }}
                </div>
              </v-img>
            </v-carousel-item>
          </v-carousel>
          <h1>testing for github</h1>
        </v-container>
      </v-main>
    </v-app>
  </v-responsive>
</template>
