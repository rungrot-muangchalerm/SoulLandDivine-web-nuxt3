<script setup lang="ts">
const route = useRoute()
const activityId = computed(() => Number(route.params.id))
</script>

<template>
  <ActivitySchedules :activity-id="activityId" />
</template>
