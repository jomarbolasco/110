import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { useUserStore } from '@/stores/user'

// Vuetify
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
    defaultSet: 'mdi', // This is already the default value - only for display purposes
  },
  components,
  directives,
})

const app = createApp(App)

app.use(pinia) // Register Pinia
app.use(router)
app.use(vuetify)

// Now you can safely use the store
const userStore = useUserStore()
userStore.initializeUser() // Initialize user session

app.mount('#app')
