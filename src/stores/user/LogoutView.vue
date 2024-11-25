<script setup>
import { useSupabaseClient } from '@supabase/supabase-js'
import { useRouter } from 'vue-router'

const supabase = useSupabaseClient()
const router = useRouter()

const logout = async () => {
  await supabase.auth.signOut()
  router.push('/login')
}

logout()
</script>
