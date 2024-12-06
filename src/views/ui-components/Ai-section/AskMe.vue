<template>
  <v-container class="my-5">
    <h1>Ask about your health</h1>
    <v-form @submit.prevent="submitQuery">
      <v-textarea
        v-model="query"
        label="Ask me anything about your illness"
        outlined
        rows="5"
      ></v-textarea>
      <v-btn type="submit" color="primary" :loading="loading" :disabled="loading"> Submit </v-btn>
    </v-form>
    <p v-if="response">{{ response }}</p>
    <p v-if="errorMessage" style="color: red">{{ errorMessage }}</p>
  </v-container>
</template>

<script setup>
import { ref } from 'vue'
import { supabase } from '@/components/util/supabase'

const query = ref('')
const response = ref('')
const loading = ref(false)
const errorMessage = ref('')

const submitQuery = async () => {
  loading.value = true
  errorMessage.value = ''

  try {
    // Get the current session
    const {
      data: { session },
    } = await supabase.auth.getSession()

    if (!session?.user) {
      throw new Error('User not logged in')
    }

    const user_id = session.user.id // Fetching the user ID from the session

    // Insert user query into Supabase
    const { data: queryData, error: queryError } = await supabase
      .from('user_queries')
      .insert([{ user_id, query_text: query.value }])
      .select()
      .single()

    if (queryError) throw queryError

    // Call the AI API to get the response (replace with your actual AI API call)
    const aiResponse = await fetch('http://localhost:3000/api/ai-response', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ query: query.value }),
    })

    if (!aiResponse.ok) {
      const errorDetail = await aiResponse.text()
      throw new Error(`Failed to fetch AI response: ${errorDetail}`)
    }

    const aiResponseData = await aiResponse.json()

    response.value = aiResponseData.message

    // Insert AI response into Supabase
    const { error: responseError } = await supabase
      .from('ai_responses')
      .insert([{ query_id: queryData.query_id, response_text: aiResponseData.message }])

    if (responseError) throw responseError
  } catch (error) {
    console.error('Error submitting query:', error.message)
    errorMessage.value = error.message
  } finally {
    loading.value = false
  }
}
</script>

<style scoped></style>
