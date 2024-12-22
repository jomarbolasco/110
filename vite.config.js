import { fileURLToPath, URL } from 'node:url'
import dotenv from 'dotenv'
import process from 'node:process'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

// Load environment variables from .env file
dotenv.config()

export default defineConfig({
  plugins: [vue(), vueDevTools()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  base: '/',
  define: {
    'import.meta.env.VITE_COHERE_API_KEY': JSON.stringify(process.env.VITE_COHERE_API_KEY),
  },
})
