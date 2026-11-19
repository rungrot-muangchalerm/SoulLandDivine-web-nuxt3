<script setup lang="ts">
import { ref } from 'vue'

interface LinkedActivity {
  configId?: string
  id: number
  name: string
  imageUrl?: string
}

defineProps<{ activities: LinkedActivity[] }>()

const brokenImages = ref<Record<string, boolean>>({})
</script>

<template>
  <section v-if="activities.length" class="boss-linked-section" role="group" aria-label="กิจกรรมพ่วง">
    <div class="boss-linked-heading">
      <span>กิจกรรมพ่วง</span>
      <span class="boss-linked-description">เปิด–ปิดตามกิจกรรมหลัก</span>
    </div>
    <div class="boss-linked-previews">
      <NuxtLink
        v-for="activity in activities"
        :key="(activity.configId ?? 'recharge-tabs') + ':' + activity.id"
        class="linked-thumb linked-activity"
        :to="{ path: '/activities/' + activity.id, query: activity.configId === 'recharge-time' ? { config: 'recharge-time' } : {} }"
        :title="activity.name + ' · ID ' + activity.id + ' · เปิด–ปิดตามกิจกรรมหลัก'"
        :aria-label="'ดูรายละเอียดกิจกรรมพ่วง ' + activity.name + ' ID ' + activity.id"
      >
        <img v-if="activity.imageUrl && !brokenImages[(activity.configId ?? 'recharge-tabs') + ':' + activity.id]" :src="activity.imageUrl" :alt="activity.name" loading="lazy" @error="brokenImages[(activity.configId ?? 'recharge-tabs') + ':' + activity.id] = true">
        <span v-else class="linked-placeholder">{{ activity.name }}</span>
        <span class="linked-caption">ID {{ activity.id }}</span>
      </NuxtLink>
    </div>
  </section>
</template>

<style scoped>
.boss-linked-section {
  min-width: 0;
  padding: 0.65rem 0.8rem 0.75rem;
  border-top: 1px solid var(--bs-border-color);
  background: var(--bs-tertiary-bg);
}

.boss-linked-heading {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: 0.3rem 0.7rem;
  font-size: 0.83rem;
  font-weight: 700;
  margin-bottom: 0.45rem;
}

.boss-linked-description {
  color: var(--bs-secondary-color);
  font-size: 0.73rem;
  font-weight: 400;
}

.boss-linked-previews {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.55rem;
}

.linked-thumb {
  position: relative;
  display: block;
  flex: 0 0 auto;
  overflow: hidden;
  border: 1px solid var(--bs-border-color);
  border-radius: 0.5rem;
  background: rgb(10 16 25 / 90%);
  color: #fff;
  text-decoration: none;
}

.linked-thumb:hover {
  border-color: var(--bs-primary);
}

.linked-thumb:focus-visible {
  outline: 2px solid var(--bs-primary);
  outline-offset: 3px;
}

.linked-activity {
  width: 144px;
  height: 64px;
  max-width: 100%;
}

.linked-activity img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.linked-placeholder {
  display: grid;
  place-items: center;
  width: 100%;
  height: 100%;
  padding: 0.35rem;
  font-size: 0.72rem;
  text-align: center;
}

.linked-caption {
  position: absolute;
  right: 0;
  bottom: 0;
  padding: 0.05rem 0.3rem;
  border-radius: 0.3rem 0 0;
  background: rgb(0 0 0 / 83%);
  color: #fff;
  font-size: 0.65rem;
}
</style>
