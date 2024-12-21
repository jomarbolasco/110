<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <h1>Ask About Your Illness</h1>
      </v-col>
      <v-col cols="12">
        <v-alert type="warning" border="start" colored-border>
          This page is currently unavailable and under maintenance. Please check back later.
        </v-alert>
      </v-col>
      <v-col cols="12">
        <v-form @submit.prevent="askQuestion">
          <v-textarea
            v-model="question"
            label="Describe your symptoms or ask about your illness"
            rows="5"
            required
          ></v-textarea>
          <v-btn type="submit" color="primary" :loading="loading">Ask</v-btn>
        </v-form>
      </v-col>
      <v-col cols="12" v-if="response">
        <v-card class="mt-4">
          <v-card-title>Response</v-card-title>
          <v-card-text>{{ response }}</v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import axios from 'axios'
import { ref } from 'vue'

const question = ref('')
const response = ref('')
const loading = ref(false)
const error = ref(null)

const askQuestion = async () => {
  loading.value = true
  error.value = null
  try {
    console.log('Question:', question.value) // Log the question value
    console.log('Authorization Token:', import.meta.env.VITE_COHERE_API_KEY) // Log the token

    const payload = {
      model: 'command-xlarge-nightly',
      prompt: question.value,
      max_tokens: 150,
      temperature: 0.7,
    }
    console.log('Payload:', payload) // Log the payload

    const result = await axios.post('https://api.cohere.ai/generate', payload, {
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${import.meta.env.VITE_COHERE_API_KEY}`,
      },
    })

    console.log('Result:', result) // Log the result

    if (result.data && result.data.text) {
      response.value = result.data.text
    } else {
      throw new Error('Unexpected response structure')
    }
  } catch (err) {
    error.value = 'An error occurred while fetching the response.'
    console.error('Error details:', err.response ? err.response.data : err.message) // Log error details
  } finally {
    loading.value = false
  }
}

console.log('API Key:', import.meta.env.VITE_COHERE_API_KEY)
</script>

<style scoped>
.mt-4 {
  margin-top: 1rem;
}
</style>
