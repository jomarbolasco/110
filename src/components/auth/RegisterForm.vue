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

const router = useRouter()

const formDataDefault = {
  name: '',
  email: '',
  password: '',
  password_confirmation: '',
  role: 'user', // Default value for role
}

const formData = ref({
  ...formDataDefault,
})

const formAction = ref({
  ...formActionDefault,
})

const refVForm = ref()

const roles = ['user', 'admin'] // Options for the dropdown

const onSubmit = async () => {
  formAction.value = { ...formActionDefault }
  formAction.value.formProcess = true

  const { data, error } = await supabase.auth.signUp({
    email: formData.value.email,
    password: formData.value.password,
    options: {
      data: {
        name: formData.value.name,
        role: formData.value.role, // Ensure role is included in metadata
      },
    },
  })

  if (error) {
    console.error('Error during sign-up:', error)
    formAction.value.formProcess = false
    return
  }

  if (data) {
    console.log('Auth data:', data)
    // Redirect to dashboard after successful sign-up
    router.replace('/dashboard')
  }

  formAction.value.formProcess = false
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
      <v-col cols="12">
        <v-text-field
          v-model="formData.name"
          :rules="[requiredValidator]"
          label="Name"
          density="compact"
          variant="outlined"
        ></v-text-field>
      </v-col>

      <v-col cols="12">
        <v-text-field
          v-model="formData.email"
          :rules="[requiredValidator, emailValidator]"
          prepend-inner-icon="mdi-email-outline"
          label="Email"
          density="compact"
          variant="outlined"
        ></v-text-field>
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
        ></v-text-field>
      </v-col>

      <v-col cols="12">
        <v-text-field
          v-model="formData.password_confirmation"
          :rules="[
            requiredValidator,
            confirmedValidator(formData.password_confirmation, formData.password),
          ]"
          prepend-inner-icon="mdi-lock-outline"
          :append-inner-icon="visible ? 'mdi-eye-off' : 'mdi-eye'"
          :type="visible ? 'text' : 'password'"
          label="Password Confirmation"
          density="compact"
          variant="outlined"
          @click:append-inner="visible = !visible"
        ></v-text-field>
      </v-col>

      <v-col cols="12">
        <v-select
          v-model="formData.role"
          :items="roles"
          label="Role"
          density="compact"
          variant="outlined"
        ></v-select>
      </v-col>

      <v-col cols="12">
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
