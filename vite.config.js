import { fileURLToPath, URL } from 'node:url'
import dotenv from 'dotenv'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

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
    'process.env': {
      VITE_HUGGING_FACE_API_KEY: process.env.VITE_HUGGING_FACE_API_KEY,
    },
  },
})
