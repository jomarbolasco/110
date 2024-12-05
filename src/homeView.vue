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
  }, 50) // Adjust the speed of the loading bar
})
</script>

<template>
  <v-responsive>
    <v-app :theme="theme">
      <v-main>
        <v-container>
          <!-- Animated Background -->
          <div class="animated-bg">
            <v-row align="center" justify="center" class="fill-height">
              <v-col class="d-flex flex-column align-center">
                <!-- Loading Spinner -->
                <v-progress-circular
                  :size="70"
                  :width="7"
                  color="primary"
                  indeterminate
                ></v-progress-circular>
                <!-- Loading Text -->
                <h2 class="my-4">{{ loadingText }}</h2>
                <!-- Loading Bar -->
                <v-progress-linear
                  :value="progress"
                  height="10"
                  color="primary"
                  class="my-4"
                ></v-progress-linear>
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
  position: absolute;
  width: 100%;
  height: 100%;
  background: linear-gradient(-45deg, #ee7752, #e73c7e, #23a6d5, #23d5ab);
  background-size: 400% 400%;
  animation: gradient 15s ease infinite;
  display: flex;
  align-items: center;
  justify-content: center;
}

@keyframes gradient {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}
</style>
