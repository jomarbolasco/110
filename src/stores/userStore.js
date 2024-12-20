// src/store/userStore.js
import { defineStore } from 'pinia'
import { supabase } from '@/components/util/supabase'

export const useUserStore = defineStore('user', {
  state: () => ({
    user: null, // Holds user info
    bookedSchedules: [], // Holds booked schedules
  }),
  actions: {
    async setUser(userData) {
      this.user = userData
    },
    async logout() {
      await supabase.auth.signOut() // Clear Supabase session
      this.user = null // Clear user state
      console.log('User state cleared:', this.user) // Log for debugging
    },
    async initializeUser() {
      try {
        const { data: session, error } = await supabase.auth.getSession()
        if (error || !session?.session?.user) {
          console.warn('No active session found:', error?.message || 'User is not logged in.')
          this.user = null
        } else {
          const { data: userDetails, error: userError } = await supabase.auth.getUser()
          if (userError) {
            console.error('Error fetching user details:', userError.message)
          }

          this.user = {
            id: session.session.user.id,
            name: session.session.user.user_metadata?.name || '',
            email: session.session.user.email,
            additionalDetails: {
              ...userDetails?.user,
              role: session.session.user.user_metadata?.role || 'Normal User', // Default to 'Normal User'
            },
          }

          // Fetch booked schedules for the user
          await this.fetchBookedSchedules()
        }
      } catch (err) {
        console.error('Unexpected error initializing user:', err.message)
        this.user = null
      }
    },
    async fetchBookedSchedules() {
      if (!this.user) return

      try {
        const { data, error } = await supabase
          .from('appointments')
          .select(
            `
            appointment_id,
            appointment_date_time,
            status,
            reason,
            schedules (
              schedule_id,
              schedule_date,
              start_time,
              end_time,
              available_slots,
              medical_staff (
                name
              ),
              appointment_types (
                type_name
              )
            )
          `,
          )
          .eq('booked_by_user_id', this.user.id)

        if (error) {
          console.error('Error fetching booked schedules:', error.message)
          this.bookedSchedules = []
        } else {
          this.bookedSchedules = data
        }
      } catch (err) {
        console.error('Unexpected error fetching booked schedules:', err.message)
        this.bookedSchedules = []
      }
    },
  },
})
