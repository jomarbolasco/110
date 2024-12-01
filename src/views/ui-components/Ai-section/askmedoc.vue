<!-- <script>
import { useUserStore } from '@/stores/user'
import { saveSymptomQuery } from '@/components/util/supabase'
import { getAIResponse } from '@/components/util/openai'

export default {
  data() {
    return {
      symptomQuery: '',
      aiResponse: '',
      loading: false,
      errorMessage: '',
    }
  },
  setup() {
    const userStore = useUserStore()
    return { userStore }
  },
  methods: {
    async submitQuery() {
      if (!this.symptomQuery.trim()) {
        this.errorMessage = 'Please enter your symptoms.'
        return
      }
      this.loading = true
      this.errorMessage = ''
      this.aiResponse = ''
      try {
        const userId = this.userStore.user?.id
        if (!userId) throw new Error('User not logged in')

        // Get AI response
        const response = await getAIResponse(this.symptomQuery)
        this.aiResponse = response

        // Save to database
        await saveSymptomQuery(userId, this.symptomQuery, response)
      } catch (error) {
        console.error(error.message)
        this.errorMessage = error.message || 'An error occurred while processing your query.'
      } finally {
        this.loading = false
      }
    },
  },
}
</script>

<template>
  <v-container>
    <v-text-field
      v-model="symptomQuery"
      label="Describe your symptoms"
      outlined
      clearable
      :error="!!errorMessage"
      :error-messages="[errorMessage]"
    ></v-text-field>
    <v-btn :loading="loading" color="primary" @click="submitQuery">Ask AI</v-btn>
    <v-alert v-if="aiResponse" type="success" class="mt-4">
      {{ aiResponse }}
    </v-alert>
    <v-alert v-if="errorMessage" type="error" class="mt-4">
      {{ errorMessage }}
    </v-alert>
  </v-container>
</template> -->
