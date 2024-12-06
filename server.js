// server.js
import express from 'express'
import OpenAI from 'openai'
import bodyParser from 'body-parser'
import cors from 'cors'
import dotenv from 'dotenv'
import rateLimit from 'express-rate-limit'
import NodeCache from 'node-cache'

dotenv.config()

const app = express()
const port = process.env.PORT || 3000

const openai = new OpenAI({
  apiKey: process.env.VITE_OPENAI_KEY,
})

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
})

const cache = new NodeCache({ stdTTL: 3600, checkperiod: 600 }) // Cache responses for 1 hour

app.use(
  cors({
    origin: 'http://localhost:5173', // Replace with your frontend URL
  }),
) // Enable CORS for your frontend
app.use(bodyParser.json())
app.use(limiter) // Apply rate limiter to all requests

app.post('/api/ai-response', async (req, res) => {
  const { query } = req.body

  const cachedResponse = cache.get(query)
  if (cachedResponse) {
    return res.json({ message: cachedResponse })
  }

  try {
    const response = await openai.completions.create({
      model: 'gpt-4o',
      prompt: query,
      max_tokens: 150,
    })

    const responseText = response.choices[0].text.trim()
    cache.set(query, responseText)
    res.json({ message: responseText })
  } catch (error) {
    console.error('Error with AI response:', error)
    res.status(500).json({ error: 'Failed to get AI response' })
  }
})

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`)
})
