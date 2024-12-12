<template>
  <div>
    <v-img
      class="mx-auto my-6"
      max-width="228"
      src="https://cdn.vuetifyjs.com/docs/images/logos/vuetify-logo-v3-slim-text-light.svg"
    ></v-img>

    <v-card class="mx-auto pa-12 pb-8" elevation="8" max-width="448" rounded="lg">
      <div class="text-subtitle-1 text-medium-emphasis">Create Account</div>

      <v-select
        v-model="userType"
        :items="['Normal User', 'Medical Staff']"
        label="Select User Type"
      ></v-select>

      <v-text-field
        v-model="formData.email"
        density="compact"
        placeholder="Email address"
        prepend-inner-icon="mdi-email-outline"
        variant="outlined"
      ></v-text-field>

      <v-text-field
        v-model="formData.password"
        :append-inner-icon="visible ? 'mdi-eye-off' : 'mdi-eye'"
        :type="visible ? 'text' : 'password'"
        density="compact"
        placeholder="Enter your password"
        prepend-inner-icon="mdi-lock-outline"
        variant="outlined"
        @click:append-inner="visible = !visible"
      ></v-text-field>

      <v-text-field
        v-model="formData.fullName"
        density="compact"
        placeholder="Full Name"
        prepend-inner-icon="mdi-account-outline"
        variant="outlined"
      ></v-text-field>

      <v-text-field
        v-model="formData.dateOfBirth"
        density="compact"
        placeholder="Date of Birth"
        prepend-inner-icon="mdi-calendar"
        variant="outlined"
      ></v-text-field>

      <v-text-field
        v-if="userType === 'Normal User'"
        v-model="formData.gender"
        density="compact"
        placeholder="Gender"
        prepend-inner-icon="mdi-gender-male-female"
        variant="outlined"
      ></v-text-field>

      <v-text-field
        v-model="formData.phoneNumber"
        density="compact"
        placeholder="Phone Number"
        prepend-inner-icon="mdi-phone"
        variant="outlined"
      ></v-text-field>

      <v-text-field
        v-if="userType === 'Normal User'"
        v-model="formData.address"
        density="compact"
        placeholder="Address"
        prepend-inner-icon="mdi-map-marker"
        variant="outlined"
      ></v-text-field>

      <v-text-field
        v-if="userType === 'Medical Staff'"
        v-model="formData.role"
        density="compact"
        placeholder="Role"
        prepend-inner-icon="mdi-account-outline"
        variant="outlined"
      ></v-text-field>

      <v-text-field
        v-if="userType === 'Medical Staff'"
        v-model="formData.specialization"
        density="compact"
        placeholder="Specialization"
        prepend-inner-icon="mdi-hospital"
        variant="outlined"
      ></v-text-field>

      <v-text-field
        v-if="userType === 'Medical Staff'"
        v-model="formData.availableHours"
        density="compact"
        placeholder="Available Hours"
        prepend-inner-icon="mdi-clock"
        variant="outlined"
      ></v-text-field>

      <v-btn class="mb-8" color="blue" size="large" variant="tonal" block @click="signUp">
        Sign Up
      </v-btn>

      <v-card-text class="text-center">
        <a
          class="text-blue text-decoration-none"
          href="#"
          rel="noopener noreferrer"
          target="_blank"
        >
          Already have an account? Log in <v-icon icon="mdi-chevron-right"></v-icon>
        </a>
      </v-card-text>
    </v-card>
  </div>
</template>

<script>
import { supabase, formActionDefault } from '@/components/util/supabase' // Make sure the path is correct

export default {
  data: () => ({
    visible: false,
    userType: '',
    formData: {
      email: '',
      password: '',
      fullName: '',
      dateOfBirth: '',
      gender: '',
      phoneNumber: '',
      address: '',
      role: '',
      specialization: '',
      availableHours: '',
    },
    formAction: { ...formActionDefault },
  }),
  methods: {
    async signUp() {
      this.formAction.formProcess = true
      try {
        // Sign up the user with Supabase Auth
        const { data, error } = await supabase.auth.signUp({
          email: this.formData.email,
          password: this.formData.password,
        })
        if (error) throw error

        const userId = data.user.id

        if (this.userType === 'Normal User') {
          await this.createNormalUser(userId)
        } else if (this.userType === 'Medical Staff') {
          await this.createMedicalStaff(userId)
        }

        this.formAction.formSuccessMessage = 'Account created successfully!'
      } catch (error) {
        this.formAction.formErrorMessage = error.message
      } finally {
        this.formAction.formProcess = false
      }
    },
    async createNormalUser(userId) {
      const { error } = await supabase.from('Patients').insert({
        user_id: userId,
        name: this.formData.fullName,
        date_of_birth: this.formData.dateOfBirth,
        gender: this.formData.gender,
        phone_number: this.formData.phoneNumber,
        address: this.formData.address,
      })
      if (error) throw error
    },
    async createMedicalStaff(userId) {
      const { error } = await supabase.from('Medical_Staff').insert({
        user_id: userId,
        name: this.formData.fullName,
        role: this.formData.role,
        specialization: this.formData.specialization,
        phone_number: this.formData.phoneNumber,
        available_hours: this.formData.availableHours,
      })
      if (error) throw error
    },
  },
}
</script>
