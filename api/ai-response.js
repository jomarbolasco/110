// api/ai-response.js (Node.js/Express example)
import express from 'express'

const app = express()
const configuration = new Configuration({
  apiKey: process.env.VITE_OPENAI_KEY,
})
import OpenAI from 'openai'
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
})

app.use(express.json())

app.post('/api/ai-response', async (req, res) => {
  const { query } = req.body

  try {
    const aiResponse = await openai.createCompletion({
      model: 'text-davinci-003',
      prompt: query,
      max_tokens: 150,
    })

    res.json({ message: aiResponse.data.choices[0].text.trim() })
  } catch (error) {
    console.error('Error with AI response:', error)
    res.status(500).json({ error: 'Failed to get AI response' })
  }
})

app.listen(3000, () => {
  console.log('Server is running on port 3000')
})
