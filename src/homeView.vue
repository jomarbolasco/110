<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const theme = ref('dark')
const loadingText = ref('Loading...')
const router = useRouter()
const progress = ref(0)

onMounted(() => {
  const interval = setInterval(() => {
    progress.value += 1
    if (progress.value >= 100) {
      clearInterval(interval)
      router.push('/login')
    }
  }, 20) // Adjust the speed of the loading bar
})
</script>

<template>
  <v-responsive>
    <v-app :theme="theme">
      <v-main>
        <v-container>
          <div class="animated-bg">
            <v-row align="center" justify="center" class="fill-height">
              <v-col class="d-flex flex-column align-center">
                <v-progress-circular :size="70" :width="7" color="primary" indeterminate />
                <h2 class="my-4">{{ loadingText }}</h2>
                <v-progress-linear :value="progress" height="10" color="primary" class="my-4" />
              </v-col>
            </v-row>
          </div>
        </v-container>
      </v-main>
    </v-app>
  </v-responsive>
</template>

<style scoped>
.animated-bg {
  /* ... existing CSS ... */
  background: url('path/to/your/video.mp4') no-repeat center center;
  background-size: cover;
  animation: none; /* Remove gradient animation */
}
</style>
