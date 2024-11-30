import { createClient } from '@supabase/supabase-js' // Use this for Supabase SDK

// Create a single Supabase client for interacting with your database
export const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY,
)

// Form action utils
export const formActionDefault = {
  formProcess: false,
  formStatus: 200,
  formErrorMessage: '',
  formSuccessMessage: '',
}

// Save a new symptom query and AI response
export async function saveSymptomQuery(userId, query, response) {
  const { data, error } = await supabase
    .from('AI.symptom_queries')
    .insert([{ user_id: userId, query, response }])

  if (error) throw new Error(`Error saving query: ${error.message}`)
  return data
}

// Fetch past symptom queries for a user
export async function fetchSymptomQueries(userId) {
  const { data, error } = await supabase
    .from('AI.symptom_queries')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })

  if (error) throw new Error(`Error fetching queries: ${error.message}`)
  return data
}
