<script setup>
import { ref } from 'vue'
import { getAIResponse } from '@/components/util/openaiService'

const userInput = ref('')
const aiResponse = ref('')
const loading = ref(false)
const errorMessage = ref('')

const handleSendMessage = async () => {
  if (userInput.value.trim() === '') return

  loading.value = true
  errorMessage.value = ''
  aiResponse.value = ''

  try {
    aiResponse.value = await getAIResponse(userInput.value)
  } catch (error) {
    errorMessage.value = 'An error occurred while getting the AI response.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <v-container class="my-5">
    <v-row>
      <v-col cols="12" md="8" offset-md="2">
        <v-card class="pa-5">
          <v-card-title class="text-h5">Ask Me Doc!</v-card-title>
          <v-card-subtitle>Type your question about your illness and get advice.</v-card-subtitle>

          <v-divider class="my-4"></v-divider>

          <v-alert v-if="errorMessage" type="error" class="mb-4">{{ errorMessage }}</v-alert>

          <v-form @submit.prevent="handleSendMessage">
            <v-text-field
              v-model="userInput"
              label="Ask your question"
              :disabled="loading"
            ></v-text-field>
            <v-btn type="submit" :loading="loading">Send</v-btn>
          </v-form>

          <v-card class="mt-4" v-if="aiResponse">
            <v-card-title class="text-h6">Response:</v-card-title>
            <v-card-text>{{ aiResponse }}</v-card-text>
          </v-card>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>
