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
import { ref } from 'vue'
import axios from 'axios'

const question = ref('')
const response = ref('')
const loading = ref(false)

const askQuestion = async () => {
  loading.value = true
  try {
    const result = await axios.post(
      'https://api-inference.huggingface.co/models/gpt2',
      {
        inputs: question.value,
        parameters: {
          max_length: 150,
          temperature: 0.7,
        },
      },
      {
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${import.meta.env.VITE_HUGGING_FACE_API_KEY}`,
        },
      },
    )

    response.value = result.data[0].generated_text
  } catch (error) {
    console.error('Error fetching response:', error)
    response.value = 'Sorry, there was an error generating a response. Please try again later.'
  } finally {
    loading.value = false
  }
}

console.log('API Key:', import.meta.env.VITE_HUGGING_FACE_API_KEY)
</script>

<style scoped>
.mt-4 {
  margin-top: 1rem;
}
</style>
