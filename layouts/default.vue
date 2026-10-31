<script setup lang="ts">
interface AdminSession {
  username: string
  authorization: string
  channel: string
}

const { data: session, error } = await useFetch<AdminSession>('/api/session')
if (error.value) {
  await navigateTo('/login')
}

const collapsed = ref(false)
</script>

<template>
  <div v-if="session" class="admin-shell">
    <AdminHeader
      :username="session.username"
      :channel="session.channel"
      @collapse="collapsed = !collapsed"
    />
    <AdminSidebar :authorization="session.authorization" :collapsed="collapsed" />
    <main class="admin-content" :class="{ collapsed }">
      <slot />
    </main>
  </div>
</template>

<style>
.admin-shell { min-height: 100vh; background: #f3f6fa; }
.admin-content { min-height: calc(100vh - 70px); margin-left: 250px; padding: 22px; transition: margin-left .2s ease; }
.admin-content.collapsed { margin-left: 64px; }
@media (max-width: 760px) {
  .admin-content { margin-left: 64px; padding: 12px; }
}
</style>
