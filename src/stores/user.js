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
      try {
        const { data: session, error } = await supabase.auth.getSession()
        if (error || !session?.session?.user) {
          console.warn('No active session found:', error?.message || 'User is not logged in.')
          this.user = null
        } else {
          // Fetch detailed user data
          const { data: userDetails, error: userError } = await supabase.auth.getUser()
          if (userError) {
            console.error('Error fetching user details:', userError.message)
          }

          // Assign user details, including id and metadata
          this.user = {
            id: session.session.user.id, // User ID
            name: session.session.user.user_metadata?.name || '',
            email: session.session.user.email,
            additionalDetails: userDetails?.user || {}, // Store extra user details
          }
        }
      } catch (err) {
        console.error('Unexpected error initializing user:', err.message)
        this.user = null
      }
    },
  },
})
