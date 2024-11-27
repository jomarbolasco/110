<script setup>
import RegisterForm from '@/components/auth/RegisterForm.vue'
import { ref } from 'vue'
import appLayout from '@/components/layout/appLayout.vue'

const theme = ref('dark')
</script>

<template>
  <appLayout>
    <template #navbar>
      <v-btn append-icon="mdi-home" prepend-icon="mdi-check-circle">
        <template v-slot:prepend> </template>
        <RouterLink style="text-decoration: none" to="/">HOME</RouterLink>
        <template v-slot:append>
          <v-icon color="warning"></v-icon>
        </template>
      </v-btn>
      <v-spacer></v-spacer>

      <v-btn append-icon="mdi-account" prepend-icon="mdi-check-circle">
        <template v-slot:prepend> </template>
        <RouterLink style="text-decoration: none" to="/login">Login</RouterLink>
        <template v-slot:append>
          <v-icon color="warning"></v-icon>
        </template>
      </v-btn>

      <v-btn active append-icon="mdi-account-plus" prepend-icon="mdi-check-circle">
        <template v-slot:prepend> </template>
        <RouterLink style="text-decoration: none" to="/register">Sign-up</RouterLink>
        <template v-slot:append>
          <v-icon color="warning"></v-icon>
        </template>
      </v-btn>
    </template>
    <template #content
      ><v-container>
        <v-row>
          <v-col cols="12" md="5">
            <div>
              <v-img
                class="mx-auto my-6"
                max-width="228"
                src="https://onhlawoqasmyceacldah.supabase.co/storage/v1/object/public/images/logoname.png"
              ></v-img>
              <v-card class="mx-auto pa-12 pb-8" elevation="8" max-width="448" rounded="lg">
                <v-divider class="mb-5" />
                <RegisterForm />
                <v-divider class="my-3" />
                <v-card-text class="text-center">
                  <p>
                    Already have an account?
                    <RouterLink
                      to="/login"
                      class="text-blue text-decoration-none"
                      rel="noopener noreferrer"
                    >
                      Login <v-icon icon="mdi-login"></v-icon>
                    </RouterLink>
                  </p>
                </v-card-text>
              </v-card>
            </div>
          </v-col>
        </v-row> </v-container
    ></template>
  </appLayout>
</template>
