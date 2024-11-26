import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { useUserStore } from '@/stores/user' // Import the user store

import '@mdi/font/css/materialdesignicons.css'
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'

import App from './App.vue'
import router from './router'

const pinia = createPinia() // Create Pinia instance

const vuetify = createVuetify({
  icons: {
    defaultSet: 'mdi',
  },
  components,
  directives,
})

const app = createApp(App)

app.use(pinia) // Register Pinia
app.use(router)
app.use(vuetify)

// Now safely use the store
// const userStore = useUserStore(pinia) // Pass the Pinia instance to initialize the store
// await userStore.initializeUser() // Initialize user session after the store is available

const initializeApp = async () => {
  const userStore = useUserStore(pinia) // Pass the Pinia instance to initialize the store
  await userStore.initializeUser() // Initialize user session after the store is available
  app.mount('#app') // Mount the app after initialization
}
initializeApp()
