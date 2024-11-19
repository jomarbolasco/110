<script>
export default {
  data: () => ({
    visible: false,
  }),
}
</script>

<template>
  <div class="text-subtitle-1 text-medium-emphasis">Register</div>

  <v-row>
    <v-col cols="12" md="6">
      <v-text-field label="First name" density="compact" variant="outlined"></v-text-field>
    </v-col>

    <v-col cols="12" md="6">
      <v-text-field label="Last name" density="compact" variant="outlined"></v-text-field>
    </v-col>

    <v-col cols="12">
      <v-text-field
        prepend-inner-icon="mdi-email-outline"
        label="Email"
        density="compact"
        variant="outlined"
      ></v-text-field>
    </v-col>

    <v-col cols="12">
      <v-text-field
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
        prepend-inner-icon="mdi-lock-outline"
        :append-inner-icon="visible ? 'mdi-eye-off' : 'mdi-eye'"
        :type="visible ? 'text' : 'password'"
        label="Password Confirmation"
        density="compact"
        variant="outlined"
        @click:append-inner="visible = !visible"
      ></v-text-field>
    </v-col>
  </v-row>
</template>
