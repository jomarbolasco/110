<script setup lang="ts">
import { ref } from 'vue'
import HeroSectionView from './dashBoardComponents/heroSection/heroSectionView.vue'
import userSchedule from './dashBoardComponents/untitledAreaOne/userSchedule.vue'
import UntitledAreaTwo from './dashBoardComponents/untitledAreaTwo/untitledAreaTwo.vue'
import UntitledAreaThree from './dashBoardComponents/untitledAreaThree/untitledAreaThree.vue'
</script>

<template>
  <v-row>
    <v-col cols="12" sm="12">
      <HeroSectionView />
    </v-col>
    <v-col cols="12" lg="4" class="d-flex align-items-stretch">
      <userSchedule />
    </v-col>
    <v-col cols="12" lg="8" class="d-flex align-items-stretch">
      <UntitledAreaTwo />
    </v-col>
    <v-col cols="12" sm="12">
      <UntitledAreaThree />
    </v-col>
  </v-row>
</template>
