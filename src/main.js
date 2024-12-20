import { createApp } from 'vue'
import App from './App.vue'
import { createPinia } from 'pinia'
import { createVuetify } from 'vuetify'
import 'vuetify/styles' // Ensure Vuetify styles are imported
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import router from './router'

import { useUserStore } from '@/stores/userStore'

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

const initializeApp = async () => {
  const userStore = useUserStore(pinia) // Pass the Pinia instance to initialize the store
  await userStore.initializeUser() // Initialize user session after the store is available
  app.mount('#app') // Mount the app after initialization
}
initializeApp()
