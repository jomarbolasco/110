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
  userType: 'patient', // Default value for user type
  specialty: '',
  contact_number: '',
  check_up_type: '',
}

const formData = ref({
  ...formDataDefault,
})

const formAction = ref({
  ...formActionDefault,
})

const refVForm = ref()

const userTypes = ['patient', 'doctor'] // Options for the dropdown

const onSubmit = async () => {
  formAction.value = { ...formActionDefault }
  formAction.value.formProcess = true

  const { data, error } = await supabase.auth.signUp({
    email: formData.value.email,
    password: formData.value.password,
    options: {
      data: {
        name: formData.value.name,
        userType: formData.value.userType, // Ensure userType is included in metadata
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

    // Insert the user into the appropriate table based on userType
    let insertData = {}
    let table = ''
    if (formData.value.userType === 'patient') {
      insertData = {
        p_id: data.user.id, // Use the UUID from Supabase auth for patient
        name: formData.value.name,
        check_up_type: formData.value.check_up_type,
      }
      table = 'patient' // Ensure table name is lowercase
    } else if (formData.value.userType === 'doctor') {
      insertData = {
        name: formData.value.name,
        specialty: formData.value.specialty,
        contact_number: formData.value.contact_number,
      }
      table = 'doctors' // Ensure table name is lowercase
    }

    console.log(`Inserting into ${table}:`, insertData)

    const { error: insertError, data: insertDataResponse } = await supabase
      .from(table)
      .upsert(insertData)
      .select()

    if (insertError) {
      console.error(`Error inserting into ${table} table:`, insertError)
    } else {
      console.log(`User successfully inserted into ${table} table`, insertDataResponse)
      // Redirect to dashboard after successful sign-up
      router.replace('/dashboard')
    }
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
          v-model="formData.userType"
          :items="userTypes"
          label="User Type"
          density="compact"
          variant="outlined"
        ></v-select>
      </v-col>

      <v-col cols="12" v-if="formData.userType === 'patient'">
        <v-text-field
          v-model="formData.check_up_type"
          :rules="[requiredValidator]"
          label="Check-up Type"
          density="compact"
          variant="outlined"
        ></v-text-field>
      </v-col>

      <v-col cols="12" v-if="formData.userType === 'doctor'">
        <v-text-field
          v-model="formData.specialty"
          :rules="[requiredValidator]"
          label="Specialty"
          density="compact"
          variant="outlined"
        ></v-text-field>
      </v-col>

      <v-col cols="12" v-if="formData.userType === 'doctor'">
        <v-text-field
          v-model="formData.contact_number"
          :rules="[requiredValidator]"
          label="Contact Number"
          density="compact"
          variant="outlined"
        ></v-text-field>
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
