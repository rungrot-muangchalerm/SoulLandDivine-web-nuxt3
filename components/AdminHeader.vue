<script setup lang="ts">
import md5 from 'js-md5'
import { BsMessage } from '~/utils/bootstrap-message'

const props = defineProps<{
  username: string
  channel: string
}>()
const passwordDialogVisible = ref(false)
const form = reactive({ oldPsw: '', newPsw: '', againPsw: '' })
function openPasswordDialog() {
  form.oldPsw = ''
  form.newPsw = ''
  form.againPsw = ''
  passwordDialogVisible.value = true
}

async function changePassword() {
  if (!form.oldPsw || !form.newPsw || !form.againPsw) {
    BsMessage.error('กรุณากรอกรหัสผ่านเดิมและรหัสผ่านใหม่')
    return
  }
  if (form.newPsw.length < 6) {
    BsMessage.error('รหัสผ่านใหม่ต้องมีอย่างน้อย 6 ตัวอักษร')
    return
  }
  if (form.newPsw !== form.againPsw) {
    BsMessage.error('รหัสผ่านใหม่ไม่ตรงกัน')
    return
  }

  try {
    const result = await $fetch<number[]>('/api/users/changePsw', {
      method: 'POST',
      body: {
        username: props.username,
        currentPassword: md5(props.username + form.oldPsw),
        password: md5(props.username + form.newPsw),
      },
    })
    if (result[0] === 1) {
      BsMessage.success('เปลี่ยนรหัสผ่านสำเร็จ กรุณาเข้าสู่ระบบอีกครั้ง')
      passwordDialogVisible.value = false
      await logout()
    }
  } catch (error) {
    BsMessage.error(error instanceof Error ? error.message : 'เปลี่ยนรหัสผ่านไม่สำเร็จ')
  }
}

async function logout() {
  try {
    await $fetch('/api/logout')
  } finally {
    await navigateTo('/login')
  }
}

const fullscreen = ref(false)
function toggleFullscreen() {
  if (!document.fullscreenElement) {
    void document.documentElement.requestFullscreen?.()
    fullscreen.value = true
  } else {
    void document.exitFullscreen?.()
    fullscreen.value = false
  }
}

const channelName = ref(props.channel)
onMounted(async () => {
  try {
    const channels = await $fetch<Array<{ name: string }>>('/api/set/searchChannelOne', {
      method: 'POST',
      body: { channel: props.channel },
    })
    channelName.value = channels[0]?.name || props.channel
  } catch {
    channelName.value = props.channel
  }
})
</script>

<template>
  <header class="navbar navbar-dark bg-dark shadow-sm sticky-top">
    <div class="container-fluid gap-2">
      <div class="navbar-brand mb-0 me-auto text-truncate">
        ระบบจัดการ GM Douluo Continent <span class="text-white-50">- {{ channelName }}</span>
      </div>
      <div class="d-flex align-items-center gap-2">
        <button class="btn btn-outline-light btn-sm" type="button" aria-label="เต็มหน้าจอ" @click="toggleFullscreen">
          {{ fullscreen ? 'ออกจากเต็มจอ' : 'เต็มหน้าจอ' }}
        </button>
        <div class="dropdown">
          <button
            class="btn btn-outline-light dropdown-toggle"
            type="button"
            data-bs-toggle="dropdown"
            aria-expanded="false"
          >
            {{ username }}
          </button>
          <ul class="dropdown-menu dropdown-menu-end">
            <li><button class="dropdown-item" type="button" @click="openPasswordDialog">เปลี่ยนรหัสผ่าน</button></li>
            <li><hr class="dropdown-divider"></li>
            <li><button class="dropdown-item text-danger" type="button" @click="logout">ออกจากระบบ</button></li>
          </ul>
        </div>
      </div>
    </div>
    <div v-if="passwordDialogVisible">
      <div class="modal-backdrop fade show" @click="passwordDialogVisible = false"></div>
      <div class="modal d-block" tabindex="-1" role="dialog" aria-modal="true" aria-labelledby="password-dialog-title">
        <div class="modal-dialog modal-dialog-centered">
          <form class="modal-content" @submit.prevent="changePassword">
            <div class="modal-header">
              <h2 id="password-dialog-title" class="modal-title fs-5">เปลี่ยนรหัสผ่าน</h2>
              <button class="btn-close" type="button" aria-label="ปิด" @click="passwordDialogVisible = false"></button>
            </div>
            <div class="modal-body">
              <div class="mb-3">
                <label class="form-label" for="old-password">รหัสผ่านเดิม</label>
                <input id="old-password" v-model="form.oldPsw" class="form-control" type="password" autocomplete="current-password" placeholder="กรอกรหัสผ่านเดิม">
              </div>
              <div class="mb-3">
                <label class="form-label" for="new-password">รหัสผ่านใหม่</label>
                <input id="new-password" v-model="form.newPsw" class="form-control" type="password" autocomplete="new-password" placeholder="กรอกรหัสผ่านใหม่">
              </div>
              <div>
                <label class="form-label" for="again-password">ยืนยันรหัสผ่านใหม่</label>
                <input id="again-password" v-model="form.againPsw" class="form-control" type="password" autocomplete="new-password" placeholder="กรอกรหัสผ่านใหม่อีกครั้ง">
              </div>
            </div>
            <div class="modal-footer">
              <button class="btn btn-outline-secondary" type="button" @click="passwordDialogVisible = false">ยกเลิก</button>
              <button class="btn btn-primary" type="submit">ยืนยัน</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </header>
</template>
