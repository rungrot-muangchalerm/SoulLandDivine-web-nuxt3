<script setup lang="ts">
import md5 from 'js-md5'
import { ElButton, ElDialog, ElDropdown, ElDropdownItem, ElDropdownMenu, ElForm, ElFormItem, ElInput, ElMessage } from 'element-plus'

const props = defineProps<{
  username: string
  channel: string
}>()
const emit = defineEmits<{ collapse: [] }>()
const passwordDialogVisible = ref(false)
const form = reactive({ oldPsw: '', newPsw: '', againPsw: '' })
async function openPasswordDialog() {
  form.oldPsw = ''
  form.newPsw = ''
  form.againPsw = ''
  passwordDialogVisible.value = true
}

async function changePassword() {
  if (!form.oldPsw || !form.newPsw || !form.againPsw) {
    ElMessage.error('กรุณากรอกรหัสผ่านเดิมและรหัสผ่านใหม่')
    return
  }
  if (form.newPsw.length < 6) {
    ElMessage.error('รหัสผ่านใหม่ต้องมีอย่างน้อย 6 ตัวอักษร')
    return
  }
  if (form.newPsw !== form.againPsw) {
    ElMessage.error('รหัสผ่านใหม่ไม่ตรงกัน')
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
      ElMessage.success('เปลี่ยนรหัสผ่านสำเร็จ กรุณาเข้าสู่ระบบอีกครั้ง')
      passwordDialogVisible.value = false
      await logout()
    }
  } catch (error) {
    ElMessage.error(error instanceof Error ? error.message : 'เปลี่ยนรหัสผ่านไม่สำเร็จ')
  }
}

async function logout() {
  try {
    await $fetch('/api/logout')
  } finally {
    await navigateTo('/login')
  }
}

async function handleCommand(command: string) {
  if (command === 'changePsw') await openPasswordDialog()
  if (command === 'loginout') await logout()
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
  <header class="admin-header">
    <el-button class="collapse-button" text @click="emit('collapse')">☰</el-button>
    <div class="brand">ระบบจัดการ GM Douluo Continent - {{ channelName }}</div>
    <div class="header-actions">
      <el-button text aria-label="เต็มหน้าจอ" @click="toggleFullscreen">
        {{ fullscreen ? 'ออกจากโหมดเต็มหน้าจอ' : 'เต็มหน้าจอ' }}
      </el-button>
      <el-dropdown @command="handleCommand">
        <button class="user-menu" type="button">{{ username }}⌄</button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="changePsw">เปลี่ยนรหัสผ่าน</el-dropdown-item>
            <el-dropdown-item divided command="loginout">ออกจากระบบ</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
    <el-dialog v-model="passwordDialogVisible" title="เปลี่ยนรหัสผ่าน" width="420px">
      <el-form label-width="100px">
        <el-form-item label="รหัสผ่านเดิม"><el-input v-model="form.oldPsw" type="password" show-password placeholder="กรอกรหัสผ่านเดิม" /></el-form-item>
        <el-form-item label="รหัสผ่านใหม่"><el-input v-model="form.newPsw" type="password" show-password placeholder="กรอกรหัสผ่านใหม่" /></el-form-item>
        <el-form-item label="ยืนยันรหัสผ่านใหม่"><el-input v-model="form.againPsw" type="password" show-password placeholder="กรอกรหัสผ่านใหม่อีกครั้ง" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="passwordDialogVisible = false">ยกเลิก</el-button>
        <el-button type="primary" @click="changePassword">ยืนยัน</el-button>
      </template>
    </el-dialog>
  </header>
</template>

<style scoped>
.admin-header {
  display: flex;
  align-items: center;
  height: 70px;
  padding: 0 24px 0 8px;
  color: #fff;
  background: #242f3e;
}
.collapse-button { color: #fff; font-size: 20px; }
.brand { flex: 1; padding-left: 14px; font-size: 20px; }
.header-actions { display: flex; align-items: center; gap: 18px; }
.header-actions :deep(.el-button) { color: #fff; }
.user-menu { border: 0; color: #fff; background: transparent; cursor: pointer; font: inherit; }
</style>
