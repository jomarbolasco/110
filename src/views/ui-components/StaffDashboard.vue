<script setup lang="ts">
import { ref } from 'vue'
// import HeroSectionView from './dashBoardComponents/heroSection/heroSectionView.vue'
// import ScheduleView from './dashBoardComponents/untitledAreaOne/ScheduleView.vue'
// import UntitledAreaTwo from './dashBoardComponents/untitledAreaTwo/untitledAreaTwo.vue'
// import UntitledAreaThree from './dashBoardComponents/untitledAreaThree/untitledAreaThree.vue'
import HeroSection from '../staffDashboard/Schedules.vue'
import ScheduleView from '../dashboard/dashBoardComponents/untitledAreaOne/ScheduleView.vue'
</script>

<template>
  <v-row>
    <v-col cols="12" sm="12">
      <!-- <HeroSection /> -->
      <h1>yawa</h1>
    </v-col>
    <v-col cols="12" lg="6" class="d-flex align-items-stretch">
      <!-- <ScheduleView /> -->
      <HeroSection />
    </v-col>
    <v-col cols="12" lg="6" class="d-flex align-items-stretch">
      <!-- <UntitledAreaTwo /> -->
    </v-col>
    <v-col cols="12" sm="12">
      <!-- <UntitledAreaThree /> -->
    </v-col>
  </v-row>
</template>
