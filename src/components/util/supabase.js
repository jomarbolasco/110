import { createClient } from '@supabase/supabase-js'

//form action utils
export const formActionDefault = {
  formProcess: false,
  formStatus: 200,
  formErrorMessage: '',
  formSuccessMessage: '',
}

export const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY,
)

export async function fetchSchedules() {
  try {
    const { data, error } = await supabase.rpc('get_available_schedules')
    if (error) {
      throw error
    }
    return data
  } catch (error) {
    console.error('Error fetching schedules:', error.message)
    throw error
  }
}
