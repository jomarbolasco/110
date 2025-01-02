<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const theme = ref('dark')
const loadingText = ref('Loading...')
const router = useRouter()
const progress = ref(0)
const loading = ref(true)

onMounted(() => {
  const interval = setInterval(() => {
    progress.value += 1
    if (progress.value >= 100) {
      clearInterval(interval)
      router.push('/login')
      loading.value = false
    }
  }, 20) // Adjust the speed of the loading bar
})
</script>

<template>
  <v-responsive color="grey-darken-4">
    <v-app :theme="theme">
      <v-main>
        <v-container>
          <div v-if="loading" class="loading-screen">
            <v-progress-circular indeterminate color="primary" size="64"></v-progress-circular>
            <p>Loading, please wait...</p>
          </div>
          <div v-else>
            <div class="animated-bg">
              <v-row align="center" justify="center" class="fill-height">
                <v-col class="d-flex flex-column align-center">
                  <v-progress-circular :size="70" :width="7" color="primary" indeterminate />
                  <h2 class="my-4">{{ loadingText }}</h2>
                  <v-progress-linear :value="progress" height="10" color="primary" class="my-4" />
                </v-col>
              </v-row>
            </div>
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

.loading-screen {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  background-color: rgb(32, 32, 32);
}

.loading-screen p {
  margin-top: 16px;
  font-size: 18px;
  color: black;
}
</style>
