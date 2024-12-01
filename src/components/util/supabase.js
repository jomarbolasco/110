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

// export const saveSymptomQuery = async (userId, query, response) => {
//   const { error } = await supabase
//     .from('symptom_queries')
//     .insert([{ user_id: userId, query, response }])

//   if (error) throw new Error(error.message)
// }

// export const fetchDoctors = async () => {
//   const { data, error } = await supabase.from('doctors').select('*')
//   if (error) throw new Error(error.message)
//   return data
// }

// export const fetchSchedules = async (doctorId) => {
//   const { data, error } = await supabase.from('schedule').select('*').eq('doctor_id', doctorId)
//   if (error) throw new Error(error.message)
//   return data
// }

// export const bookAppointment = async (userId, doctorId, appointmentDate) => {
//   const { error } = await supabase.from('appointments').insert([
//     {
//       user_id: userId,
//       doctor_id: doctorId,
//       appointment_date: appointmentDate,
//     },
//   ])
//   if (error) throw new Error(error.message)
// }
