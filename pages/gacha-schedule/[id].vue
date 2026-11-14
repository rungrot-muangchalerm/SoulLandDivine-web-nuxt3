<script setup lang="ts">
import { isGachaScheduleFollower, isGachaSchedulePoolHidden } from '~/utils/gacha-schedule-links'

interface Pool { id: number; name: string; endTime: string; active: boolean }
const route = useRoute()
const drafts = useState<Record<number, string>>('gacha-end-time-drafts', () => ({}))
const pool = ref<Pool | null>(null)
const endTime = ref('')
const error = ref('')
const loading = ref(true)
function futureDefault() {
  const now = new Date(Date.now() + 30 * 86400000 + 7 * 3600000)
  return now.toISOString().slice(0, 13) + ':00'
}
onMounted(async () => {
  try {
    const id = Number(route.params.id)
    if (!Number.isSafeInteger(id) || id <= 0 || isGachaScheduleFollower(id) || isGachaSchedulePoolHidden(id)) throw new Error('กรุณาเลือกตู้หลัก')
    const pools = await $fetch<Pool[]>('/api/gacha/rate-up')
    pool.value = pools.find((p: Pool) => p.id === id) || null
    if (!pool.value) throw new Error('ไม่พบตู้กาชา')
    const configured = pool.value.endTime.replace(' ', 'T').slice(0, 16)
    endTime.value = drafts.value[id] || (/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/.test(configured) && new Date(configured + ':00+07:00').getTime() > Date.now() ? configured : futureDefault())
  } catch (e: any) { error.value = e?.data?.statusMessage || e.message || 'โหลดข้อมูลไม่สำเร็จ' }
  finally { loading.value = false }
})
async function save() {
  error.value = ''
  if (!pool.value) return
  if (!/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/.test(endTime.value) || new Date(endTime.value + ':00+07:00').getTime() <= Date.now()) {
    error.value = 'กรุณากำหนดเวลาปิดหลังเวลาปัจจุบัน'; return
  }
  drafts.value[pool.value.id] = endTime.value
  await navigateTo('/gacha')
}
</script>

<template>
  <section style="max-width: 640px">
    <NuxtLink to="/gacha" class="d-inline-block mb-3">← กลับหน้าตู้กาชา</NuxtLink>
    <h1 class="h3">ตั้งเวลาปิด{{ pool ? ` · ${pool.name}` : '' }}</h1>
    <p v-if="loading" role="status">กำลังโหลด...</p>
    <div v-if="error" class="alert alert-danger" role="alert">{{ error }}</div>
    <form v-if="pool && !pool.active" class="card card-body" @submit.prevent="save">
      <label for="end-time" class="form-label">กำหนดเวลาปิดหลังเปิด (เวลาไทย)</label>
      <input id="end-time" v-model="endTime" type="datetime-local" class="form-control" required>
      <p class="form-text">เก็บเวลาไว้สำหรับการเปิดครั้งถัดไปในหน้านี้ กลับไปกดสวิตช์ที่การ์ดเพื่อเปิดตู้ การบันทึกนี้ยังไม่เปิดตู้หรือเปลี่ยนเวลาในเซิร์ฟเวอร์</p>
      <button type="submit" class="btn btn-primary align-self-start">บันทึกแล้วกลับ</button>
    </form>
    <p v-else-if="pool" class="alert alert-info">ตู้นี้เปิดอยู่แล้ว หน้านี้ใช้ตั้งเวลาสำหรับตู้ที่ปิดอยู่</p>
  </section>
</template>
