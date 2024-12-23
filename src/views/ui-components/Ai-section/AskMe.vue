<template>
  <v-container>
    <v-row justify="center">
      <v-col cols="12" md="8">
        <h1 class="text-center mb-4">Ask About Your Illness</h1>
      </v-col>
      <v-col cols="12" md="8">
        <v-form @submit.prevent="askQuestion">
          <v-textarea
            v-model="question"
            label="Describe your symptoms or ask about your illness"
            rows="5"
            required
            outlined
            class="mb-4"
          ></v-textarea>
          <v-btn type="submit" color="primary" :loading="loading" block>Ask</v-btn>
        </v-form>
      </v-col>
      <v-col cols="12" md="8" v-if="response">
        <v-card class="mt-4 pa-4">
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
    const payload = {
      model: 'command-xlarge-nightly',
      prompt: `This is a health-related question: ${question.value}. if not please dont answer it.`,
      max_tokens: 150,
      temperature: 0.7,
    }

    const result = await axios.post('https://api.cohere.ai/generate', payload, {
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${import.meta.env.VITE_COHERE_API_KEY}`,
      },
    })

    if (result.data && result.data.text) {
      response.value = result.data.text
    } else {
      throw new Error('Unexpected response structure')
    }
  } catch (err) {
    error.value = 'An error occurred while fetching the response.'
    console.error('Error details:', err.response ? err.response.data : err.message)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.text-center {
  text-align: center;
}
.mb-4 {
  margin-bottom: 1rem;
}
.pa-4 {
  padding: 1rem;
}
.mt-4 {
  margin-top: 1rem;
}
</style>
