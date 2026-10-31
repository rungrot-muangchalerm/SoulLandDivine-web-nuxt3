<script setup lang="ts">
import AdminSidebar from '~/components/AdminSidebar.vue'

interface AdminSession {
  username: string
  authorization: string
  channel: string
}

const { data: session, error } = await useFetch<AdminSession>('/api/session')
if (error.value) {
  await navigateTo('/login')
}

</script>

<template>
  <div v-if="session" class="container-fluid min-vh-100 bg-body-tertiary">
    <div class="row g-0 sticky-top z-1">
      <div class="d-none d-md-block col-md-3 col-lg-2" aria-hidden="true"></div>
      <div class="col-12 col-md-9 col-lg-10">
        <AdminHeader
          :username="session.username"
          :channel="session.channel"
        />
      </div>
    </div>
    <div class="row g-3 py-3 align-items-start">
      <AdminSidebar
        class="col-12 col-md-3 col-lg-2"
        :authorization="session.authorization"
      />
      <main class="col-12 col-md-9 col-lg-10">
        <div class="container-fluid px-0 py-2">
        <slot />
        </div>
      </main>
    </div>
  </div>
</template>
