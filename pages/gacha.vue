<script setup lang="ts">
import {
  getGachaScheduleFollowers,
  isGachaScheduleFollower,
} from '~/utils/gacha-schedule-links'

interface GachaPool {
  id: number
  type: string
  name: string
  beginTime: string
  endTime: string
  active: boolean
  imageUrl?: string
}

const pools = ref<GachaPool[]>([])
const endTimes = ref<Record<number, string>>({})
const savingPoolId = ref<number | null>(null)
const loading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
let scheduleGeneration = 0

function toInputDateTime(value: string) {
  const match = /^(\d{4})-(\d{1,2})-(\d{1,2})[ T](\d{1,2}):(\d{1,2})(?::\d{1,2})?$/.exec(value)
  if (!match) return ''
  const [, year, month, day, hour, minute] = match
  return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}T${hour.padStart(2, '0')}:${minute.padStart(2, '0')}`
}

function defaultEndTime() {
  const endDate = new Date()
  endDate.setDate(endDate.getDate() + 30)
  endDate.setMinutes(0, 0, 0)
  const pad = (part: number) => String(part).padStart(2, '0')
  return `${endDate.getFullYear()}-${pad(endDate.getMonth() + 1)}-${pad(endDate.getDate())}T${pad(endDate.getHours())}:${pad(endDate.getMinutes())}`
}

function setPools(value: GachaPool[], preserveDrafts = false) {
  const visiblePools = value.filter(pool => !isGachaScheduleFollower(pool.id))
  pools.value = visiblePools
  endTimes.value = Object.fromEntries(visiblePools.map((pool) => {
    const configuredEndTime = toInputDateTime(pool.endTime)
    return [
      pool.id,
      preserveDrafts && endTimes.value[pool.id]
        ? endTimes.value[pool.id]
        : configuredEndTime && new Date(configuredEndTime) > new Date()
        ? configuredEndTime
        : defaultEndTime(),
    ]
  }))
}

async function loadSchedule() {
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''
  try {
    setPools(await $fetch<GachaPool[]>('/api/gacha/rate-up'))
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'โหลดข้อมูลตู้กาชาไม่สำเร็จ'
  } finally {
    loading.value = false
  }
}

async function changeSchedule(pool: GachaPool, action: 'open' | 'close' | 'sync') {
  if (action === 'close') {
    const linkedPoolNotice = getGachaScheduleFollowers(pool.id).length
      ? ' ตู้ร่างปกติ ID 4 และกิจกรรมเงินครามจะปิดตามด้วย'
      : ''
    if (!window.confirm(`ยืนยันปิดตู้ "${pool.name}" (ID ${pool.id}) ทันทีหรือไม่?${linkedPoolNotice}`)) return false
  }

  scheduleGeneration += 1
  savingPoolId.value = pool.id
  errorMessage.value = ''
  successMessage.value = ''
  try {
    const result = await $fetch<GachaPool & { message: string }>('/api/gacha/rate-up', {
      method: 'POST',
      body: {
        poolId: pool.id,
        action,
        ...(action === 'open' ? { endTime: endTimes.value[pool.id] } : {}),
      },
    })
    const followerIds = getGachaScheduleFollowers(result.id)
    pools.value = pools.value.map((item: GachaPool) => {
      if (item.id === result.id) return result
      return followerIds.includes(item.id)
        ? { ...item, beginTime: result.beginTime, endTime: result.endTime, active: result.active }
        : item
    })
    successMessage.value = `${result.name}: ${result.message}`
    return true
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'บันทึกการตั้งค่าตู้กาชาไม่สำเร็จ'
    return false
  } finally {
    savingPoolId.value = null
  }
}

async function togglePool(pool: GachaPool, event: Event) {
  if (isGachaScheduleFollower(pool.id)) return
  const checkbox = event.target
  if (!(checkbox instanceof HTMLInputElement)) return

  const action = checkbox.checked ? 'open' : 'close'
  if (action === 'open' && !endTimes.value[pool.id]) {
    errorMessage.value = 'กรุณากำหนดเวลาปิดตู้ก่อนเปิด'
    checkbox.checked = false
    return
  }
  if (!await changeSchedule(pool, action)) {
    checkbox.checked = pool.active
  }
}

let scheduleRefresh: ReturnType<typeof setInterval> | undefined
async function refreshScheduleSilently() {
  if (loading.value || savingPoolId.value !== null) return
  const generation = scheduleGeneration
  try {
    const updated = await $fetch<GachaPool[]>('/api/gacha/rate-up')
    if (generation === scheduleGeneration && savingPoolId.value === null) setPools(updated, true)
  } catch {
    // Keep the current controls and drafts on a transient connection failure.
  }
}
onMounted(() => {
  loadSchedule()
  scheduleRefresh = setInterval(refreshScheduleSilently, 10000)
})
onBeforeUnmount(() => {
  if (scheduleRefresh) clearInterval(scheduleRefresh)
})
</script>

<template>
  <section class="container-fluid">
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
      <div>
        <h1 class="h3 mb-1">จัดการตู้กาชาเรทอัพ</h1>
        <p class="text-body-secondary mb-0">แสดงเฉพาะตู้หลัก ตู้ที่ผูกให้เปิด–ปิดตามจะไม่แสดงซ้ำ · จัดการตัวละครและเรทได้จากหน้าย่อยของแต่ละตู้</p>
      </div>
      <button class="btn btn-outline-secondary" type="button" :disabled="loading || savingPoolId !== null" @click="loadSchedule">
        รีเฟรช
      </button>
    </div>

    <div v-if="errorMessage" class="alert alert-danger" role="alert">
      {{ errorMessage }}
    </div>
    <div v-if="successMessage" class="alert alert-success" role="status">
      {{ successMessage }}
    </div>

    <p v-if="loading" class="mb-0" role="status">กำลังโหลดข้อมูล...</p>
    <div v-else-if="pools.length" class="row g-3">
      <div v-for="pool in pools" :key="pool.id" class="col-12 col-xl-6">
        <article class="card h-100">
          <img
            v-if="pool.imageUrl"
            :src="pool.imageUrl"
            :alt="`ภาพตู้ ${pool.name}`"
            class="card-img-top gacha-pool-image"
            loading="lazy"
          >
          <div class="card-body">
            <div class="d-flex flex-wrap justify-content-between align-items-start gap-2 mb-3">
              <div>
                <h2 class="h5 mb-1">{{ pool.name }}</h2>
                <div class="small text-body-secondary">ID {{ pool.id }} · Type {{ pool.type }}</div>
              </div>
              <div class="form-check form-switch">
                <input
                  :id="`gacha-active-${pool.id}`"
                  class="form-check-input"
                  type="checkbox"
                  role="switch"
                  :checked="pool.active"
                  :disabled="savingPoolId !== null || isGachaScheduleFollower(pool.id)"
                  @change="togglePool(pool, $event)"
                >
                <label class="form-check-label" :for="`gacha-active-${pool.id}`">
                  {{ pool.id === 24
                    ? (pool.active ? 'ตู้หลักเปิดอยู่' : 'เปิดตู้ร่างเทพหลักทันที')
                    : pool.active ? 'เปิดอยู่' : 'เปิดตู้ทันที' }}
                </label>
              </div>
            </div>

            <div v-if="getGachaScheduleFollowers(pool.id).length" class="alert alert-info py-2">
              <p class="small mb-2">
                ตู้ร่างเทพ ID {{ pool.id }} เป็นตัวควบคุมหลัก: ตู้ร่างปกติ ID 4 และกิจกรรมเงินคราม ID 18, 19, 126 จะเปิด–ปิดตามกัน
              </p>
              <button
                class="btn btn-sm btn-outline-primary"
                type="button"
                :disabled="savingPoolId !== null"
                @click="changeSchedule(pool, 'sync')"
              >
                ซิงก์ตู้ร่างปกติและกิจกรรมตามสถานะตู้หลัก
              </button>
            </div>

            <dl class="small mb-3 gacha-pool-schedule">
              <div>
                <dt>เวลาเริ่ม</dt>
                <dd>{{ pool.beginTime || 'ไม่ได้กำหนด' }}</dd>
              </div>
              <div>
                <dt>เวลาปิด</dt>
                <dd>{{ pool.endTime || 'ไม่ได้กำหนด' }}</dd>
              </div>
            </dl>

            <div class="border-top pt-3">
              <NuxtLink
                v-if="pool.id === 10000"
                class="btn btn-sm btn-outline-primary me-2 mb-2"
                to="/gacha-custom-config"
              >
                ตั้งค่ากติกาและน้ำหนักเรท
              </NuxtLink>
              <NuxtLink
                class="btn btn-sm btn-outline-primary"
                :to="{ path: '/page/gacha-characters', query: { drawType: pool.type } }"
              >
                จัดการตัวละครและเรท
              </NuxtLink>
            </div>

            <div v-if="!pool.active && !isGachaScheduleFollower(pool.id)" class="row align-items-end g-2">
              <div class="col">
                <label class="form-label" :for="`gacha-end-time-${pool.id}`">กำหนดเวลาปิดหลังเปิด</label>
                <input
                  :id="`gacha-end-time-${pool.id}`"
                  v-model="endTimes[pool.id]"
                  class="form-control"
                  type="datetime-local"
                  :disabled="savingPoolId !== null"
                  required
                >
                <div class="form-text">ค่าเริ่มต้นปิดในอีก 30 วัน (ปรับเวลาได้) และเมื่อเปิดแล้วตู้จะเริ่มทำงานทันที</div>
              </div>
            </div>
          </div>
        </article>
      </div>
    </div>
    <div v-else-if="!loading" class="alert alert-info">
      ไม่พบรายการตู้กาชาใน DrawTime.xml
    </div>
  </section>
</template>

<style scoped>
.gacha-pool-schedule > div {
  display: flex;
  gap: 0.5rem;
}

.gacha-pool-schedule dt,
.gacha-pool-schedule dd {
  margin: 0;
}

.gacha-pool-schedule > div + div {
  margin-top: 0.25rem;
}

.gacha-rate-input {
  min-width: 6rem;
  width: 7rem;
}

.gacha-pool-image {
  aspect-ratio: 16 / 9;
  object-fit: cover;
  background-color: var(--bs-tertiary-bg);
}
</style>
