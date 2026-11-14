<script setup lang="ts">
import {
  getGachaScheduleCloseNotice,
  getGachaScheduleDescription,
  getGachaScheduleFollowers,
  getGachaScheduleActivities,
  isGachaScheduleFollower,
  isGachaSchedulePoolHidden,
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
const allPools = ref<GachaPool[]>([])
interface LinkedActivity { id: number; name: string; imageUrl?: string; configId: string; bannerGroupKey?: string; giftType?: number }
const activities = ref<LinkedActivity[]>([])
const previewError = ref('')
const failedImages = reactive<Record<string, boolean>>({})
function followersFor(poolId: number) {
  return getGachaScheduleFollowers(poolId).map(id => allPools.value.find((pool: GachaPool) => pool.id === id) || { id, name: `ตู้ ${id}`, type: '', imageUrl: undefined })
}
function activitiesFor(poolId: number) {
  return getGachaScheduleActivities(poolId).map(id => activities.value.find((activity: LinkedActivity) => activity.configId === 'recharge-tabs' && activity.id === id)
    || { id, name: `กิจกรรม ${id}`, configId: 'recharge-tabs', imageUrl: undefined, bannerGroupKey: undefined, giftType: undefined })
}
function activityRoute(activity: LinkedActivity) {
  return activity.bannerGroupKey ? `/activities/banner-${activity.bannerGroupKey}`
    : activity.giftType ? `/activities/gift-${activity.giftType}` : '/activities'
}
const endTimes = useState<Record<number, string>>('gacha-end-time-drafts', () => ({}))
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
  allPools.value = value
  const visiblePools = value.filter(pool => !isGachaScheduleFollower(pool.id) && !isGachaSchedulePoolHidden(pool.id))
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
    const [schedule, linked] = await Promise.all([
      $fetch<GachaPool[]>('/api/gacha/rate-up'),
      $fetch<{ activities: LinkedActivity[] }>('/api/activities').catch(() => null),
    ])
    setPools(schedule, true)
    if (linked) activities.value = linked.activities
    previewError.value = linked ? '' : 'โหลดภาพกิจกรรมไม่สำเร็จ กดรีเฟรชเพื่อลองใหม่'
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'โหลดข้อมูลตู้กาชาไม่สำเร็จ'
  } finally {
    loading.value = false
  }
}

async function changeSchedule(pool: GachaPool, action: 'open' | 'close' | 'sync') {
  if (action === 'close') {
    const linkedPoolNotice = getGachaScheduleCloseNotice(pool.id)
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
    <p v-if="previewError" class="small text-warning" role="status">{{ previewError }}</p>
    <div v-if="successMessage" class="alert alert-success" role="status">
      {{ successMessage }}
    </div>

    <p v-if="loading" class="mb-0" role="status">กำลังโหลดข้อมูล...</p>
    <div v-else-if="pools.length" class="row g-3">
      <div v-for="pool in pools" :key="pool.id" class="col-12 col-xl-6 gacha-pool-column">
                      <div class="gacha-date-range" :title="`${pool.beginTime || '—'} → ${pool.endTime || '—'} (เวลาไทย)`">
                {{ pool.beginTime || '—' }} <span aria-hidden="true">→</span> {{ pool.endTime || '—' }}
              </div>
        <article class="card gacha-image-card">
          <div class="gacha-cover">
          <img
            v-if="pool.imageUrl && !failedImages[`main-${pool.id}`]"
            :src="pool.imageUrl"
            :alt="`ภาพตู้ ${pool.name}`"
            class="card-img-top gacha-pool-image"
            loading="lazy"
            @error="failedImages[`main-${pool.id}`] = true"
          >
            <div v-if="!pool.imageUrl || failedImages[`main-${pool.id}`]" class="gacha-cover-placeholder" aria-hidden="true"></div>
            <div class="gacha-cover-header">

              <div class="gacha-cover-control form-switch">
                <input
                  :id="`gacha-active-${pool.id}`"
                  class="form-check-input m-0"
                  type="checkbox"
                  role="switch"
                  :aria-label="`${pool.active ? 'ปิด' : 'เปิด'}ตู้ ${pool.name}`"
                  :title="pool.active ? 'ปิดตู้' : 'เปิดตู้'"
                  :checked="pool.active"
                  :disabled="savingPoolId !== null || isGachaScheduleFollower(pool.id)"
                  @change="togglePool(pool, $event)"
                >
              </div>
            </div>
          <div class="card-body gacha-overlay-content">
            <div class="d-flex flex-wrap justify-content-between align-items-start gap-2 mb-2">
              <div>
                <h2 class="h5 mb-1">{{ pool.name }}</h2>
                <div class="small text-body-secondary">ID {{ pool.id }} · Type {{ pool.type }}</div>
              </div>

            </div>

            <div class="gacha-linked-section mb-2">
              <div class="gacha-linked-previews">
                <div class="linked-group" aria-label="ตู้ตาม">

                  <div class="d-flex flex-wrap gap-2">
                    <div v-if="!getGachaScheduleFollowers(pool.id).length" class="linked-thumb linked-pool linked-empty" role="img" aria-label="ยังไม่มีตู้ตาม" title="ยังไม่มีตู้ตาม"><span aria-hidden="true">＋</span></div>
                    <NuxtLink v-for="follower in followersFor(pool.id)" :key="follower.id" class="linked-thumb linked-pool" :to="{ path: '/page/gacha-characters', query: { drawType: follower.type } }" :title="`${follower.name} · ID ${follower.id} · เปิด–ปิดตามตู้หลัก`">
                      <img v-if="follower.imageUrl && !failedImages[`pool-${follower.id}`]" :src="follower.imageUrl" :alt="follower.name" loading="lazy" @error="failedImages[`pool-${follower.id}`] = true">
                      <span v-else class="thumb-placeholder" aria-hidden="true">◇</span>

                    </NuxtLink>
                  </div>
                </div>
                <div class="linked-group" aria-label="กิจกรรมพ่วง">

                  <div class="d-flex flex-wrap gap-2">
                    <div v-if="!getGachaScheduleActivities(pool.id).length" class="linked-thumb linked-activity linked-empty" role="img" aria-label="ยังไม่มีกิจกรรมพ่วง" title="ยังไม่มีกิจกรรมพ่วง"><span aria-hidden="true">＋</span></div>
                    <NuxtLink v-for="activity in activitiesFor(pool.id)" :key="activity.id" class="linked-thumb linked-activity" :to="activityRoute(activity)" :title="`${activity.name} · ID ${activity.id}`">
                      <img v-if="activity.imageUrl && !failedImages[`activity-${activity.id}`]" :src="activity.imageUrl" :alt="activity.name" loading="lazy" @error="failedImages[`activity-${activity.id}`] = true">
                      <span v-else class="thumb-placeholder" aria-hidden="true">◇</span>

                    </NuxtLink>
                  </div>
                </div>
              </div>
              <button
                v-if="getGachaScheduleDescription(pool.id)"
                class="btn btn-sm btn-outline-primary mt-2"
                title="ซิงก์ตู้และกิจกรรมที่ผูกตามสถานะตู้หลัก"
                aria-label="ซิงก์ตู้และกิจกรรมที่ผูกตามสถานะตู้หลัก"
                type="button"
                :disabled="savingPoolId !== null"
                @click="changeSchedule(pool, 'sync')"
              >
                <span aria-hidden="true">↻</span>
              </button>
            </div>

            <div class="border-top pt-2 mb-2">
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

            <NuxtLink v-if="!pool.active" class="gacha-schedule-settings small align-self-start" :to="`/gacha-schedule/${pool.id}`">ตั้งเวลาปิด ↗</NuxtLink>
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

.gacha-pool-column { display: flex; flex-direction: column; }
.gacha-image-card { flex: 1; overflow: hidden; border-color: rgb(240 191 61 / 25%); background: #10151e; }
.gacha-cover { position: relative; isolation: isolate; display: flex; flex-direction: column; min-height: 540px; height: 100%; overflow: hidden; border-radius: inherit; color: #fff; }
.gacha-cover::after { content: ''; position: absolute; inset: 0; z-index: -1; pointer-events: none; background: linear-gradient(180deg, rgb(5 9 16 / 12%) 0%, rgb(5 9 16 / 15%) 22%, rgb(5 9 16 / 70%) 48%, rgb(5 9 16 / 96%) 100%); }
.gacha-cover .gacha-pool-image { position: absolute; inset: 0; z-index: -2; display: block; width: 100%; height: 100%; object-fit: cover; object-position: center top; }
.gacha-cover-placeholder { position: absolute; inset: 0; z-index: -2; background: radial-gradient(ellipse at top right, #48415d, #10151e 75%); }
.gacha-cover-header { display: flex; justify-content: flex-end; align-items: center; gap: 0.5rem; margin: 0.75rem; }
.gacha-date-range { min-width: 0; margin: 0 0.2rem 0.4rem; font-size: 0.72rem; font-variant-numeric: tabular-nums; text-shadow: 0 1px 4px #000, 0 0 8px #000; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.gacha-date-range span { margin: 0 0.35rem; color: #f0bf3d; }
.gacha-cover-control { flex: 0 0 auto; display: flex; align-items: center; }
.gacha-cover-control .form-check-input { width: 2.2rem; height: 1.2rem; border-radius: 1rem; cursor: pointer; }
.gacha-schedule-settings { color: #e5cf8f; }
.gacha-overlay-content { display: flex; flex-direction: column; justify-content: flex-end; flex: 1; padding: 7rem 1rem 1rem; min-width: 0; text-shadow: 0 1px 3px rgb(0 0 0 / 60%); }
.gacha-overlay-content .text-body-secondary, .gacha-overlay-content .form-text { color: #c6cdd7 !important; }
.gacha-overlay-content .border-top { border-color: rgb(255 255 255 / 22%) !important; }
.gacha-overlay-content .form-control { background-color: rgb(10 16 25 / 85%); color: #fff; border-color: rgb(255 255 255 / 30%); }
.gacha-overlay-content .btn { background-color: rgb(10 16 25 / 75%); text-shadow: none; }
.gacha-overlay-content .btn:hover { background-color: rgb(62 53 25 / 95%); }
@media (max-width: 575.98px) { .gacha-cover { min-height: 520px; } .gacha-overlay-content { padding: 5rem 0.85rem 0.85rem; } }
.gacha-cover-control .form-check { margin-bottom: 0; }
.gacha-cover-control .form-check-label { cursor: pointer; font-weight: 600; }
.gacha-linked-previews { display: flex; flex-wrap: wrap; align-items: flex-start; gap: 0.75rem; }
.linked-thumb { position: relative; display: block; flex: 0 0 auto; overflow: hidden; border: 1px solid var(--bs-border-color); border-radius: 0.5rem; background: rgb(10 16 25 / 80%); color: #fff; text-decoration: none; }
.linked-thumb:hover { border-color: var(--bs-primary); }
.linked-thumb:focus-visible { outline: 2px solid var(--bs-primary); outline-offset: 3px; }
.linked-pool { width: 80px; height: 80px; }
.linked-activity { width: 144px; height: 64px; }
.linked-thumb img { width: 100%; height: 100%; object-fit: cover; }
.linked-activity img { object-fit: contain; }
.linked-empty { display: grid; place-items: center; border-style: dashed; color: var(--bs-secondary-color); font-size: 1.35rem; }
.thumb-caption { position: absolute; right: 0; bottom: 0; padding: 0.05rem 0.3rem; border-radius: 0.3rem 0 0 0; background: rgb(0 0 0 / 80%); color: #fff; font-size: 0.65rem; }
.thumb-placeholder { display: grid; place-items: center; height: 100%; padding: 0.35rem; font-size: 0.7rem; text-align: center; }

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
