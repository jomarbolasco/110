<script setup>
import { ref, onMounted } from 'vue'
const elementVisible = ref(false)

onMounted(() => {
  setTimeout(() => (elementVisible.value = true), 10)
})
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
  <!-- ------------------------------------ -->
  <!-- html -->
  <!-- ------------------------------------ -->
  <v-card>
    <v-card-text class="pa-7">
      <div class="d-sm-flex align-center mb-5">
        <div>
          <h3 class="text-h6 title font-weight-medium">New's and Update's</h3>
        </div>
        <v-spacer></v-spacer>
        <div class="ml-auto">
          <div class="d-flex align-center">
            <div class="d-flex align-center px-2">
              <span class="text-primary">
                <span class="text-overline">
                  <i class="mdi mdi-brightness-1 mx-1"></i>
                </span>
                <span class="font-weight-regular">something</span>
              </span>
            </div>
            <div class="d-flex align-center px-2">
              <span class="text-secondary">
                <span class="text-overline">
                  <i class="mdi mdi-brightness-1 mx-1"></i>
                </span>
                <span class="font-weight-regular">anotherthing</span>
              </span>
            </div>
          </div>
        </div>
      </div>
      <div v-show="elementVisible">
        <v-carousel height="200" :show-arrows="false" cycle hide-delimiter-background>
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
      </div>
    </v-card-text>
  </v-card>
</template>
