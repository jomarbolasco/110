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
  <v-card>
    <v-card-text class="pa-7">
      <div class="d-sm-flex align-center mb-5">
        <div>
          <h3 class="text-h6 title font-weight-medium">Health Tips</h3>
          <p v-if="healthTips.length > 0">{{ healthTips[currentTipIndex] }}</p>
          <p v-else>No health tips available at the moment.</p>
        </div>
      </div>
      <v-spacer></v-spacer>
      <div class="d-flex justify-center mt-4">
        <v-btn @click="prevTip" :disabled="healthTips.length === 0">Previous</v-btn>
        <v-btn @click="changeTip" :disabled="healthTips.length === 0" class="ml-2">Next</v-btn>
      </div>
    </v-card-text>
  </v-card>
</template>
