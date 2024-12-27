<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/components/util/supabase'

const healthTips = ref([])
const currentTipIndex = ref(0)

const fetchHealthTips = async () => {
  const { data, error } = await supabase
    .from('ai_responses')
    .select('response')
    .order('created_at', { ascending: false })
    .limit(10) // Fetch the latest 10 responses

  if (error) {
    console.error('Error fetching health tips:', error.message)
  } else {
    healthTips.value = data.map((item) => item.response)
  }
}

const changeTip = () => {
  if (healthTips.value.length > 0) {
    currentTipIndex.value = (currentTipIndex.value + 1) % healthTips.value.length
  }
}

const prevTip = () => {
  if (healthTips.value.length > 0) {
    currentTipIndex.value =
      (currentTipIndex.value - 1 + healthTips.value.length) % healthTips.value.length
  }
}

onMounted(async () => {
  await fetchHealthTips()
  setInterval(changeTip, 10000) // Change tip every 10 seconds
})
</script>

<template>
  <v-card class="mx-auto my-12" elevation="10">
    <v-card-title class="headline text-s">Health Tips</v-card-title>
    <v-card-text>
      <v-container>
        <v-row justify="center">
          <v-col cols="12" class="text-center">
            <v-alert v-if="healthTips.length === 0" type="info" border="start" colored-border>
              No health tips available at the moment.
            </v-alert>
            <v-alert v-else type="success" border="start" colored-border>
              {{ healthTips[currentTipIndex] }}
            </v-alert>
          </v-col>
        </v-row>
        <v-row justify="end" class="mt-4">
          <v-btn @click="prevTip" :disabled="healthTips.length === 0" icon>
            <v-icon>mdi-chevron-left</v-icon>
          </v-btn>
          <v-btn @click="changeTip" :disabled="healthTips.length === 0" icon>
            <v-icon>mdi-chevron-right</v-icon>
          </v-btn>
        </v-row>
      </v-container>
    </v-card-text>
  </v-card>
</template>

<style scoped>
.v-card {
  background-color: gray;
  border-radius: 12px;
}

.v-card-title {
  background: linear-gradient(90deg, rgba(236, 62, 62, 0.678), purple);
  color: white;
  /* padding: 16px; */
  border-top-left-radius: 12px;
  border-top-right-radius: 12px;
}

.v-btn {
  margin: 0 8px;
}

.v-alert {
  font-size: 1.2em;
  padding: 16px;
}
</style>
