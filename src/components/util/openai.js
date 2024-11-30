import axios from 'axios'

export async function getAIResponse(query) {
  const API_KEY = import.meta.env.VITE_OPENAI_API_KEY
  if (!API_KEY) throw new Error('OpenAI API key is missing')

  try {
    const response = await axios.post(
      'https://api.openai.com/v1/chat/completions', // New API endpoint
      {
        model: 'gpt-4', // Change model if needed, e.g., gpt-4
        messages: [{ role: 'user', content: query }], // Chat-based model requires messages format
        max_tokens: 150,
      },
      {
        headers: {
          Authorization: `Bearer ${API_KEY}`,
          'Content-Type': 'application/json',
        },
      },
    )

    return response.data.choices[0]?.message.content.trim() || 'No response'
  } catch (error) {
    console.error('OpenAI API error:', error.response?.data || error.message)
    throw new Error('Failed to fetch AI response')
  }
}
