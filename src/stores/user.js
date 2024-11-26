import { defineStore } from 'pinia'
import { supabase } from '@/components/util/supabase'

export const useUserStore = defineStore('user', {
  state: () => ({
    user: null, // Holds user info
  }),
  actions: {
    async setUser(userData) {
      this.user = userData
    },
    logout() {
      this.user = null
    },
    async initializeUser() {
      const { data } = await supabase.auth.getUser()
      if (data.user) {
        this.user = {
          name: data.user.user_metadata?.name || '',
          email: data.user.email,
        }
      }
    },
  },
})
