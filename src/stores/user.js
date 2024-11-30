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
    async logout() {
      await supabase.auth.signOut() // Clear Supabase session
      this.user = null
    },
    async initializeUser() {
      const { data: session, error } = await supabase.auth.getSession()
      if (error || !session?.session?.user) {
        console.warn('No active session found:', error?.message || 'User is not logged in.')
        this.user = null
      } else {
        // Assign user details, including id
        this.user = {
          id: session.session.user.id, // Add user id
          name: session.session.user.user_metadata?.name || '',
          email: session.session.user.email,
        }
      }
    },
  },
})
