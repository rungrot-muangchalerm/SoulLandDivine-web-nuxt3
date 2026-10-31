<script setup lang="ts">
import AdminSidebarMenu from '~/components/AdminSidebarMenu.vue'

defineProps<{
  authorization: string
}>()
</script>

<template>
  <div>
    <aside class="card bg-dark-subtle d-none d-md-block position-fixed top-0 bottom-0 start-0 col-md-3 col-lg-2 overflow-y-auto z-2" aria-label="เมนูหลัก">
      <AdminSidebarMenu :authorization="authorization" />
    </aside>
    <Teleport to="body">
      <aside
        id="adminSidebar"
        class="offcanvas offcanvas-start d-md-none bg-dark-subtle"
        tabindex="-1"
        aria-label="เมนูหลัก"
        data-bs-backdrop="true"
        data-bs-scroll="false"
      >
        <div class="offcanvas-header">
          <h2 class="offcanvas-title h5">เมนูหลัก</h2>
          <button class="btn-close" type="button" data-bs-dismiss="offcanvas" aria-label="ปิดเมนู" />
        </div>
        <div class="offcanvas-body p-0 overflow-y-auto">
          <AdminSidebarMenu :authorization="authorization" mobile />
        </div>
        <button
          class="btn btn-primary rounded-circle shadow position-absolute bottom-0 start-0 m-3"
          type="button"
          data-bs-dismiss="offcanvas"
          aria-label="ปิดเมนู"
        >
          ×
        </button>
      </aside>
    </Teleport>
    <button
      class="btn btn-primary rounded-circle shadow position-fixed bottom-0 start-0 m-3 d-md-none z-3"
      type="button"
      data-bs-toggle="offcanvas"
      data-bs-target="#adminSidebar"
      aria-controls="adminSidebar"
      aria-label="เปิดเมนู"
    >
      ☰
    </button>
  </div>
</template>
