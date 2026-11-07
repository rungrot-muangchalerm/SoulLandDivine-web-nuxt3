<script setup lang="ts">
import AdminHeader from '~/components/AdminHeader.vue'
import AdminSidebar from '~/components/AdminSidebar.vue'
import { BsMessage } from '~/utils/bootstrap-message'

definePageMeta({ layout: false })

interface AdminSession {
  username: string
  authorization: string
  channel: string
}

interface PlatformStatus {
  platform: 'windows' | 'android'
  fileReady: boolean
  fileSize: number
  manifest: null | {
    version: string
    minimumVersion: string
    androidVersionCode?: number
    releaseNotes: string
    sha256: string
    publishedAt: string
  }
}

const session = ref<AdminSession | null>(null)
const status = ref<PlatformStatus[]>([])
const platform = ref<'windows' | 'android'>('windows')
const form = reactive({ version: '', minimumVersion: '', androidVersionCode: 1, releaseNotes: '' })
const loading = ref(false)

const selectedStatus = computed(() => status.value.find((item: PlatformStatus) => item.platform === platform.value))
const expectedFileName = computed(() => platform.value === 'windows'
  ? 'SoulLandDivine-Setup.exe'
  : 'SoulLandDivine.apk')

async function loadStatus() {
  status.value = await $fetch<PlatformStatus[]>('/api/client-update/status')
  const current = status.value.find((item: PlatformStatus) => item.platform === platform.value)?.manifest
  form.version = current?.version || ''
  form.minimumVersion = current?.minimumVersion || ''
  form.androidVersionCode = current?.androidVersionCode || 1
  form.releaseNotes = current?.releaseNotes || ''
}

onMounted(async () => {
  try {
    session.value = await $fetch<AdminSession>('/api/session')
    if (session.value.authorization !== 'admin') {
      BsMessage.error('ต้องใช้สิทธิ์ผู้ดูแลระบบ')
      await navigateTo('/role')
      return
    }
    await loadStatus()
  } catch (error) {
    BsMessage.error(error instanceof Error ? error.message : 'โหลดข้อมูลการอัปเดตไม่สำเร็จ')
    await navigateTo('/login')
  }
})

watch(platform, () => {
  const current = selectedStatus.value?.manifest
  form.version = current?.version || ''
  form.minimumVersion = current?.minimumVersion || ''
  form.androidVersionCode = current?.androidVersionCode || 1
  form.releaseNotes = current?.releaseNotes || ''
}, { immediate: true })

async function publishUpdate() {
  if (!selectedStatus.value?.fileReady) {
    BsMessage.error(`นำไฟล์ ${expectedFileName.value} ไปวางในโฟลเดอร์ client update ก่อน`)
    return
  }
  loading.value = true
  try {
    const result = await $fetch<{ message: string }>('/api/client-update/publish', {
      method: 'POST',
      body: { platform: platform.value, ...form },
    })
    BsMessage.success(result.message)
    await loadStatus()
  } catch (error) {
    BsMessage.error(error instanceof Error ? error.message : 'เผยแพร่ client update ไม่สำเร็จ')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="admin-page-shell">
    <AdminSidebar :authorization="session?.authorization || '0'" />
    <div class="admin-main">
      <AdminHeader :username="session?.username || ''" :channel="session?.channel || '*'" />
      <main class="container-fluid p-3 p-lg-4">
        <div class="mb-4">
          <h1 class="h3 mb-2">เผยแพร่ Client Update</h1>
          <p class="text-secondary mb-0">ไฟล์ที่เผยแพร่จะให้เกมตรวจพบและพาผู้เล่นไปติดตั้งเวอร์ชันใหม่</p>
        </div>

        <div class="card shadow-sm">
          <div class="card-body">
            <div class="alert alert-info">
              วางไฟล์ <code>{{ expectedFileName }}</code> ในโฟลเดอร์อัปเดตของ Nuxt ก่อนเผยแพร่
              <span v-if="selectedStatus?.fileReady">พบไฟล์ ({{ (selectedStatus.fileSize / 1024 / 1024).toFixed(1) }} MB)</span>
              <span v-else>ยังไม่พบไฟล์</span>
            </div>

            <form class="row g-3" @submit.prevent="publishUpdate">
              <div class="col-md-4">
                <label class="form-label" for="update-platform">แพลตฟอร์ม</label>
                <select id="update-platform" v-model="platform" class="form-select">
                  <option value="windows">Windows installer</option>
                  <option value="android">Android APK</option>
                </select>
              </div>
              <div class="col-md-4">
                <label class="form-label" for="update-version">เวอร์ชันล่าสุด</label>
                <input id="update-version" v-model.trim="form.version" class="form-control" inputmode="decimal" placeholder="1.0.1" required>
              </div>
              <div class="col-md-4">
                <label class="form-label" for="update-minimum-version">เวอร์ชันขั้นต่ำที่ต้องอัปเดต</label>
                <input id="update-minimum-version" v-model.trim="form.minimumVersion" class="form-control" inputmode="decimal" placeholder="1.0.0" required>
                <div class="form-text">ผู้เล่นที่ต่ำกว่าค่านี้จะข้ามการอัปเดตไม่ได้</div>
              </div>
              <div v-if="platform === 'android'" class="col-md-4">
                <label class="form-label" for="update-version-code">Android versionCode</label>
                <input id="update-version-code" v-model.number="form.androidVersionCode" class="form-control" type="number" min="1" step="1" required>
                <div class="form-text">ต้องมากกว่าค่าเดิมทุกครั้งที่ออก APK ใหม่</div>
              </div>
              <div class="col-12">
                <label class="form-label" for="update-notes">รายละเอียดการอัปเดต</label>
                <textarea id="update-notes" v-model.trim="form.releaseNotes" class="form-control" rows="3" maxlength="2000" />
              </div>
              <div class="col-12 d-flex align-items-center gap-3">
                <button class="btn btn-primary" type="submit" :disabled="loading || !selectedStatus?.fileReady">
                  {{ loading ? 'กำลังเผยแพร่...' : 'เผยแพร่เวอร์ชัน' }}
                </button>
                <span v-if="selectedStatus?.manifest" class="text-secondary small">
                  เผยแพร่ล่าสุด {{ selectedStatus.manifest.version }} · {{ new Date(selectedStatus.manifest.publishedAt).toLocaleString() }}
                </span>
              </div>
            </form>

            <details v-if="selectedStatus?.manifest" class="mt-4">
              <summary>รายละเอียดไฟล์ที่เผยแพร่</summary>
              <dl class="row mt-3 mb-0 small">
                <dt class="col-sm-2">SHA-256</dt>
                <dd class="col-sm-10 font-monospace text-break">{{ selectedStatus.manifest.sha256 }}</dd>
                <dt class="col-sm-2">รายละเอียด</dt>
                <dd class="col-sm-10 text-break">{{ selectedStatus.manifest.releaseNotes || '-' }}</dd>
              </dl>
            </details>
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<style scoped>
.admin-page-shell { min-height: 100vh; background: #f3f5f9; }
.admin-main { min-height: 100vh; margin-left: 0; }
@media (min-width: 768px) { .admin-main { margin-left: 25%; } }
@media (min-width: 992px) { .admin-main { margin-left: 16.666667%; } }
</style>
