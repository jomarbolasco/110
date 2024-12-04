<script setup>
import { ref } from 'vue'
import axios from 'axios'

const prompt = ref('')
const response = ref('')

async function generateText() {
  try {
    const res = await axios.post(
      'https://api.openai.com/v1/engines/davinci-codex/completions',
      {
        prompt: prompt.value,
        max_tokens: 50,
        n: 1,
        stop: '\n',
      },
      {
        headers: {
          Authorization: `Bearer ${import.meta.env.VITE_OPENAI_API_KEY}`,
        },
      },
    )
    response.value = res.data.choices[0].text.trim()
  } catch (error) {
    console.error('Error generating text:', error)
  }
}
</script>

<!-- OpenAIComponent.vue -->
<template>
  <div>
    <input v-model="prompt" placeholder="Enter your prompt here" />
    <button @click="generateText">Generate Text</button>
    <p v-if="response">Generated Text: {{ response }}</p>
  </div>
</template>
