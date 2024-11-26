<script setup>
import {
  requiredValidator,
  emailValidator,
  passwordValidator,
  confirmedValidator,
} from '@/components/util/validators'
import { ref } from 'vue'
import { supabase, formActionDefault } from '@/components/util/supabase.js'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'

// Initialize the router and user store
const router = useRouter()
const userStore = useUserStore() // Create an instance of the user store

// const router = useRouter()

const formDataDefault = {
  firstname: '',
  lastname: '',
  email: '',
  password: '',
  password_confirmation: '',
}

const formData = ref({
  ...formDataDefault,
})

const formAction = ref({
  ...formActionDefault,
})

const refVForm = ref()

const visible = ref(false)

const onSubmit = async () => {
  formAction.value.formProcess = true

  try {
    // Register the user in Supabase Auth
    const { data, error } = await supabase.auth.signUp({
      email: formData.value.email,
      password: formData.value.password,
      options: {
        data: {
          firstname: formData.value.firstname,
          lastname: formData.value.lastname,
        },
      },
    })

    if (error) throw error

    // Insert user data into the "Users" table
    const { error: insertError } = await supabase.from('Users').insert({
      name: `${formData.value.firstname} ${formData.value.lastname}`,
      email: formData.value.email,
      password_hash: await hashPassword(formData.value.password),
    })

    if (insertError) throw insertError

    // Automatically log the user in
    const { data: session } = await supabase.auth.getSession()
    if (session?.session?.user) {
      userStore.setUser({
        name: session.session.user.user_metadata?.name || '',
        email: session.session.user.email || '',
      })
    }

    // Fetch user profile
    const { data: profileData, error: profileError } = await supabase
      .from('Users')
      .select('*')
      .eq('email', formData.value.email)
      .single()

    if (profileError) throw profileError

    // Save user profile in the store
    userStore.setUser(profileData)

    // Redirect to profile page
    router.push('/dashboard')
  } catch (error) {
    console.error('Error during registration:', error.message)
    formAction.value.formErrorMessage = error.message
  } finally {
    formAction.value.formProcess = false
  }
}

// Hash password using a function (use a library for hashing, e.g., bcrypt.js or a secure API call)
const hashPassword = async (password) => {
  return btoa(password) // Replace with a real hash function for production
}

const onFormSubmit = () => {
  refVForm.value.validate().then(({ valid }) => {
    if (valid) onSubmit()
  })
}
</script>

<script>
export default {
  data: () => ({
    visible: false,
  }),
}
</script>

<template>
  <v-form ref="refVForm" @submit.prevent="onFormSubmit">
    <v-row>
      <v-col cols="12" md="6">
        <v-text-field
          v-model="formData.firstname"
          :rules="[requiredValidator]"
          label="First name"
          density="compact"
          variant="outlined"
        />
      </v-col>

      <v-col cols="12" md="6">
        <v-text-field
          v-model="formData.lastname"
          :rules="[requiredValidator]"
          label="Last name"
          density="compact"
          variant="outlined"
        />
      </v-col>

      <v-col cols="12">
        <v-text-field
          v-model="formData.email"
          :rules="[requiredValidator, emailValidator]"
          prepend-inner-icon="mdi-email-outline"
          label="Email"
          density="compact"
          variant="outlined"
        />
      </v-col>

      <v-col cols="12">
        <v-text-field
          v-model="formData.password"
          :rules="[requiredValidator, passwordValidator]"
          prepend-inner-icon="mdi-lock-outline"
          :append-inner-icon="visible ? 'mdi-eye-off' : 'mdi-eye'"
          :type="visible ? 'text' : 'password'"
          label="Password"
          density="compact"
          variant="outlined"
          @click:append-inner="visible = !visible"
        />
      </v-col>

      <v-col cols="12">
        <v-text-field
          v-model="formData.password_confirmation"
          :rules="[confirmedValidator(formData.password_confirmation, formData.password)]"
          prepend-inner-icon="mdi-lock-outline"
          :append-inner-icon="visible ? 'mdi-eye-off' : 'mdi-eye'"
          :type="visible ? 'text' : 'password'"
          label="Password Confirmation"
          density="compact"
          variant="outlined"
          @click:append-inner="visible = !visible"
        />
        <v-btn
          class="mb-8"
          color="blue"
          size="large"
          variant="tonal"
          block
          type="submit"
          :disabled="formAction.formProcess"
          :loading="formAction.formProcess"
        >
          Register
        </v-btn>
      </v-col>
    </v-row>
  </v-form>
</template>
