import { createClient } from '@supabase/supabase-js'

// Create a single supabase client for interacting with your database
const supabase = createClient(import.meta.VITE_SUPABASE_URL, import.meta.VITE_SUPABASE_ANON_KEY)
