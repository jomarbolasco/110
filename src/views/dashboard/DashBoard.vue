<script setup lang="ts">
import HeroSectionView from './dashBoardComponents/heroSection/heroSectionView.vue'
import ScheduleView from './dashBoardComponents/untitledAreaOne/ScheduleView.vue'
import UntitledAreaTwo from './dashBoardComponents/untitledAreaTwo/untitledAreaTwo.vue'
// import UntitledAreaThree from './dashBoardComponents/untitledAreaThree/untitledAreaThree.vue'
</script>

<template>
  <v-row>
    <v-col cols="12" class="d-flex align-items-stretch">
      <HeroSectionView />
    </v-col>
    <v-col cols="12" lg="6" class="d-flex align-items-stretch">
      <ScheduleView />
    </v-col>
    <v-col cols="12" lg="6" class="d-flex align-items-stretch">
      <UntitledAreaTwo />
    </v-col>
    <v-col cols="12" sm="12">
      <!-- <UntitledAreaThree /> -->
    </v-col>
  </v-row>
</template>
