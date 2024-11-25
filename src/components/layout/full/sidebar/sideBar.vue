<script setup lang="ts">
import { ref, watch } from 'vue'
import sideBarItems from './sideBarItems'

const sidebarMenu = ref(sideBarItems)
</script>

<template>
  <div>
    <!-- ---------------------------------------------- -->
    <!---Logo part -->
    <!-- ---------------------------------------------- -->
    <div class="pa-4">
      <!-- <logoDark /> -->
      <div class="logo">
        <img src="/src/assets/images/logos/logoname.png" alt="Logo" width="200" height="60" />
      </div>
    </div>
    <!-- ---------------------------------------------- -->
    <!---Navigation -->
    <!-- ---------------------------------------------- -->
    <div class="scrollnavbar">
      <v-list class="pa-4" color="transparent">
        <!-- ---------------------------------------------- -->
        <!---Menu Loop -->
        <!-- ---------------------------------------------- -->
        <template v-for="(item, i) in sidebarMenu" :key="i">
          <!-- ---------------------------------------------- -->
          <!---Single Item-->
          <!-- ---------------------------------------------- -->
          <v-list-item :to="item.to" rounded="lg" class="mb-1">
            <v-list-item-avatar start class="v-list-item-avatar--start">
              <v-icon class="feather-sm v-icon v-icon--size-default">{{ item.icon }}</v-icon>
            </v-list-item-avatar>
            <v-list-item-title v-text="item.title"></v-list-item-title>
          </v-list-item>
        </template>
      </v-list>
    </div>
    <div class="pa-4 ma-4 bg-light-primary rounded-lg text-center">
      <img src="./images/logofavicon.png " width="100" height="100" />
      <h4 class="font-weight-regular mb-3">HospiAPP</h4>
      <v-btn class="mb-2" href="" block>sample button</v-btn>
      <v-btn color="info" href="" block>button sample</v-btn>
    </div>
  </div>
</template>
