<template>
  <v-container class="my-5">
    <v-row>
      <v-col cols="12" md="8" offset-md="2">
        <v-card class="pa-5">
          <v-card-title class="text-h5">Ask Me Doc!</v-card-title>
          <v-card-subtitle>Type your question about your illness and get advice.</v-card-subtitle>

          <v-divider class="my-4"></v-divider>

          <v-alert v-if="errorMessage" type="error" class="mb-4">{{ errorMessage }}</v-alert>

          <v-form @submit.prevent="userInput">
            <v-textarea
              label="Ask your question"
              v-model="message"
              :disabled="loading"
              variant="underlined"
              class="me-5"
            ></v-textarea>
            <v-btn @click="userInput" icon="mdi-send" class="align-self-center">Send</v-btn>
          </v-form>

          <v-sheet class="mx-auto mt-1 container" elevation="4" max-width="85%">
            <div v-for="(msg, index) in messages" :key="index">
              <strong v-if="msg.role === 'user'">User:</strong>
              <strong v-else-if="msg.role === 'assistant'">Assistant:</strong>
              <span>{{ msg.content }}</span>
            </div>
          </v-sheet>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { getChatResponse } from '@/components/util/openaiService'

const message = ref(null)
const messages = reactive([])
const loading = ref(false)
const errorMessage = ref('')

const userInput = async () => {
  if (!message.value.trim()) return

  messages.push({
    role: 'user',
    content: message.value,
  })
  const userMessage = message.value
  message.value = ''

  try {
    loading.value = true
    const assistantMessage = await getChatResponse(messages)
    messages.push({
      role: 'assistant',
      content: assistantMessage,
    })
  } catch (error) {
    console.error('Error getting AI response:', error)
    errorMessage.value = 'An error occurred while getting the AI response.'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.container {
  max-height: 75hv;
  overflow-y: auto;
  flex-direction: column;
}
</style>
