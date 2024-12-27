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
import { supabase } from '@/components/util/supabase' // Import supabase client

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
      prompt: `This is a health-related question: ${question.value}. Please provide an answer and suggest possible medicines that could be used.`,
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

      // Get the current user
      const { data: user, error: userError } = await supabase.auth.getUser()
      if (userError) {
        throw new Error('Error fetching user details')
      }

      // Save the response to the ai_responses table
      const { error: insertError } = await supabase.from('ai_responses').insert([
        {
          user_id: user.id, // Use the fetched user ID
          question: question.value,
          response: response.value,
        },
      ])

      if (insertError) {
        console.error('Error saving AI response:', insertError.message)
      }
    }
  } catch (err) {
    console.error(err)
    error.value = 'An error occurred while fetching the response.'
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
