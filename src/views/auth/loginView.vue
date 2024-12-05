<script setup>
import {
  requiredValidator,
  emailValidator,
  passwordValidator,
  confirmedValidator,
} from '@/components/util/validators'
import { ref } from 'vue'
import { supabase } from '@/components/util/supabase'
import { useRouter } from 'vue-router'

const loginForm = ref()
const registerForm = ref()
const router = useRouter()
const loginData = ref({
  email: '',
  password: '',
})
const registerData = ref({
  name: '',
  email: '',
  password: '',
  password_confirmation: '',
  role: 'user', // Default value for role
})
const loading = ref(false)
const messageType = ref('error') // Type for v-alert
const loginMessage = ref('')
const registerMessage = ref('')
const step = ref(1)
const visible = ref(false)
const roles = ['user', 'admin'] // Options for the dropdown

const onLoginFormSubmit = async () => {
  loading.value = true
  loginMessage.value = ''
  messageType.value = 'error'

  try {
    const { error, data } = await supabase.auth.signInWithPassword({
      email: loginData.value.email,
      password: loginData.value.password,
    })

    if (error) {
      loginMessage.value = error.message
    } else {
      const user = data.user
      if (user.user_metadata.role === 'admin') {
        router.replace('/admin')
      } else {
        router.replace('/dashboard')
      }
      messageType.value = 'success'
      loginMessage.value = 'Login successful!'
    }
  } catch (error) {
    loginMessage.value = 'An unexpected error occurred. Please try again.'
    console.error(error)
  } finally {
    loading.value = false
  }
}

const onRegisterFormSubmit = async () => {
  loading.value = true
  registerMessage.value = ''
  messageType.value = 'error'

  try {
    const { error, data } = await supabase.auth.signUp({
      email: registerData.value.email,
      password: registerData.value.password,
      options: {
        data: {
          name: registerData.value.name,
          role: registerData.value.role, // Ensure role is included in metadata
        },
      },
    })

    if (error) {
      registerMessage.value = error.message
    } else {
      messageType.value = 'success'
      registerMessage.value = 'Registration successful!'
      router.replace('/dashboard')
    }
  } catch (error) {
    registerMessage.value = 'An unexpected error occurred. Please try again.'
    console.error(error)
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <v-container>
    <v-row align="center" justify="center">
      <v-col cols="12" sm="10">
        <v-card class="elevation-6 mt-10">
          <v-window v-model="step">
            <!-- Login Form -->
            <v-window-item :value="1">
              <v-row>
                <v-col cols="12" md="6">
                  <v-card-text class="mt-12">
                    <h4 class="text-center">Login to Your Account</h4>
                    <h6 class="text-center grey--text">
                      Log in to your account so you can continue building and editing your
                      onboarding flows
                    </h6>
                    <v-row align="center" justify="center">
                      <v-col cols="12" sm="8">
                        <v-form ref="loginForm" @submit.prevent="onLoginFormSubmit">
                          <v-text-field
                            v-model="loginData.email"
                            :rules="[requiredValidator, emailValidator]"
                            density="compact"
                            placeholder="Email address"
                            prepend-inner-icon="mdi-email-outline"
                            variant="outlined"
                            outlined
                            dense
                            color="blue"
                            autocomplete="false"
                            class="mt-16"
                          ></v-text-field>
                          <v-text-field
                            v-model="loginData.password"
                            :rules="[requiredValidator]"
                            :append-inner-icon="visible ? 'mdi-eye-off' : 'mdi-eye'"
                            :type="visible ? 'text' : 'password'"
                            density="compact"
                            placeholder="Enter your password"
                            prepend-inner-icon="mdi-lock-outline"
                            variant="outlined"
                            outlined
                            dense
                            color="blue"
                            autocomplete="false"
                            @click:append-inner="visible = !visible"
                          ></v-text-field>

                          <v-row>
                            <v-col cols="12" sm="7">
                              <v-checkbox
                                label="Remember Me"
                                class="mt-n1"
                                color="blue"
                              ></v-checkbox>
                            </v-col>
                            <v-col cols="12" sm="5">
                              <span class="caption blue--text">Forgot password</span>
                            </v-col>
                          </v-row>

                          <v-btn
                            :disabled="loading"
                            class="mb-8"
                            color="blue"
                            size="large"
                            variant="tonal"
                            block
                            tile
                            type="submit"
                          >
                            <span v-if="loading">Logging in...</span>
                            <span v-else>Log In</span>
                          </v-btn>

                          <v-alert :type="messageType" v-if="loginMessage" class="text-caption">{{
                            loginMessage
                          }}</v-alert>
                        </v-form>
                      </v-col>
                    </v-row>
                    <h5 class="text-center grey--text mt-4 mb-3">Or Log in using</h5>
                    <div class="d-flex justify-space-between align-center mx-4 mb-16">
                      <v-btn depressed outlined color="grey"
                        ><v-icon color="red">fab fa-google</v-icon></v-btn
                      >
                      <v-btn depressed outlined color="grey"
                        ><v-icon color="blue">fab fa-facebook-f</v-icon></v-btn
                      >
                      <v-btn depressed outlined color="grey"
                        ><v-icon color="light-blue lighten-3">fab fa-twitter</v-icon></v-btn
                      >
                    </div>
                  </v-card-text>
                </v-col>
                <v-col cols="12" md="6" class="bg-blue rounded-bl-xl">
                  <div style="text-align: center; padding: 180px 0">
                    <v-card-text class="white--text">
                      <h3 class="text-center">Don't Have an Account Yet?</h3>
                      <h6 class="text-center">
                        Let's get you all set up so you can start creating your first onboarding
                        experience
                      </h6>
                    </v-card-text>
                    <div class="text-center">
                      <v-btn tile outlined dark @click="step = 2">SIGN UP</v-btn>
                    </div>
                  </div>
                </v-col>
              </v-row>
            </v-window-item>
            <!-- Register Form -->
            <v-window-item :value="2">
              <v-row>
                <v-col cols="12" md="6" class="blue rounded-br-xl">
                  <div style="text-align: center; padding: 180px 0">
                    <v-card-text class="white--text">
                      <h3 class="text-center">Already Signed up?</h3>
                      <h6 class="text-center">
                        Log in to your account so you can continue building and editing your
                        onboarding flows
                      </h6>
                    </v-card-text>
                    <div class="text-center">
                      <v-btn tile outlined dark @click="step = 1">Log in</v-btn>
                    </div>
                  </div>
                </v-col>
                <v-col cols="12" md="6">
                  <v-card-text class="mt-12">
                    <h4 class="text-center">Sign Up for an Account</h4>
                    <h6 class="text-center grey--text">
                      Let's get you all set up so you can start creating your first onboarding
                      experience
                    </h6>
                    <v-row align="center" justify="center">
                      <v-col cols="12" sm="8">
                        <v-form ref="registerForm" @submit.prevent="onRegisterFormSubmit">
                          <v-text-field
                            v-model="registerData.name"
                            :rules="[requiredValidator]"
                            label="Name"
                            density="compact"
                            variant="outlined"
                            outlined
                            dense
                            color="blue"
                            autocomplete="false"
                          ></v-text-field>
                          <v-text-field
                            v-model="registerData.email"
                            :rules="[requiredValidator, emailValidator]"
                            prepend-inner-icon="mdi-email-outline"
                            label="Email"
                            density="compact"
                            variant="outlined"
                            outlined
                            dense
                            color="blue"
                            autocomplete="false"
                          ></v-text-field>
                          <v-text-field
                            v-model="registerData.password"
                            :rules="[requiredValidator, passwordValidator]"
                            prepend-inner-icon="mdi-lock-outline"
                            :append-inner-icon="visible ? 'mdi-eye-off' : 'mdi-eye'"
                            :type="visible ? 'text' : 'password'"
                            label="Password"
                            density="compact"
                            variant="outlined"
                            outlined
                            dense
                            color="blue"
                            autocomplete="false"
                            @click:append-inner="visible = !visible"
                          ></v-text-field>
                          <v-text-field
                            v-model="registerData.password_confirmation"
                            :rules="[
                              requiredValidator,
                              confirmedValidator(
                                registerData.password_confirmation,
                                registerData.password,
                              ),
                            ]"
                            prepend-inner-icon="mdi-lock-outline"
                            :append-inner-icon="visible ? 'mdi-eye-off' : 'mdi-eye'"
                            :type="visible ? 'text' : 'password'"
                            label="Password Confirmation"
                            density="compact"
                            variant="outlined"
                            outlined
                            dense
                            color="blue"
                            autocomplete="false"
                            @click:append-inner="visible = !visible"
                          ></v-text-field>
                          <v-select
                            v-model="registerData.role"
                            :items="roles"
                            label="Role"
                            density="compact"
                            variant="outlined"
                            outlined
                            dense
                            color="blue"
                          ></v-select>

                          <v-btn
                            :disabled="loading"
                            class="mb-8"
                            color="blue"
                            size="large"
                            variant="tonal"
                            block
                            tile
                            type="submit"
                            :loading="loading"
                            >Register</v-btn
                          >

                          <v-alert :type="messageType" v-if="registerMessage">{{
                            registerMessage
                          }}</v-alert>
                        </v-form>
                      </v-col>
                    </v-row>
                  </v-card-text>
                </v-col>
              </v-row>
            </v-window-item>
          </v-window>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<style scoped>
.v-application .rounded-bl-xl {
  border-bottom-left-radius: 300px !important;
}
.v-application .rounded-br-xl {
  border-bottom-right-radius: 300px !important;
}
</style>
