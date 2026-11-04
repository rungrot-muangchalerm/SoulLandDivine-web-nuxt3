<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'

interface ScheduleField {
  key: string
  label: string
  format: string
}

interface ScheduleConfig {
  id: string
  title: string
  description: string
  fields: ScheduleField[]
}

interface ScheduleRow {
  id: number
  name: string
  configId: string
  configTitle: string
  fields: Record<string, string>
  imageUrl?: string
  canOpenImmediately: boolean
}

const allConfigsId = 'all'
const configs = ref<ScheduleConfig[]>([])
const activities = ref<ScheduleRow[]>([])
const drafts = ref<Record<string, Record<string, string>>>({})
const quickOpenEndTimes = ref<Record<string, string>>({})
const selectedConfigId = ref(allConfigsId)
const search = ref('')
const page = ref(1)
const pageSize = 25
const loading = ref(false)
const savingKey = ref('')
const errorMessage = ref('')
const successMessage = ref('')

const selectedConfig = computed(() => configs.value.find((config) => config.id === selectedConfigId.value))
const configRows = computed(() => activities.value
  .filter((activity) => selectedConfigId.value === allConfigsId || activity.configId === selectedConfigId.value)
  .filter((activity) => {
    const query = search.value.trim().toLocaleLowerCase()
    return !query || `${activity.id} ${activity.name} ${Object.values(activity.fields).join(' ')}`
      .toLocaleLowerCase()
      .includes(query)
  }))
const pageCount = computed(() => Math.max(1, Math.ceil(configRows.value.length / pageSize)))
const visibleRows = computed(() => configRows.value.slice((page.value - 1) * pageSize, page.value * pageSize))

watch([selectedConfigId, search], () => {
  page.value = 1
})

async function loadSchedules() {
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''
  try {
    const result = await $fetch<{ configs: ScheduleConfig[]; activities: ScheduleRow[] }>('/api/activities')
    configs.value = result.configs
    activities.value = result.activities
    if (selectedConfigId.value !== allConfigsId && !configs.value.some((config) => config.id === selectedConfigId.value)) {
      selectedConfigId.value = allConfigsId
    }
    drafts.value = Object.fromEntries(result.activities.map((item) => [
      `${item.configId}:${item.id}`,
      { ...item.fields },
    ]))
    quickOpenEndTimes.value = Object.fromEntries(result.activities
      .filter((item) => item.canOpenImmediately)
      .map((item) => [`${item.configId}:${item.id}`, defaultQuickOpenEndTime()]))
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'โหลดตารางเวลากิจกรรมไม่สำเร็จ'
  } finally {
    loading.value = false
  }
}

function rowKey(activity: ScheduleRow) {
  return `${activity.configId}:${activity.id}`
}

function defaultQuickOpenEndTime() {
  const end = new Date()
  end.setDate(end.getDate() + 1)
  end.setMinutes(0, 0, 0)
  const pad = (part: number) => String(part).padStart(2, '0')
  return `${end.getFullYear()}-${pad(end.getMonth() + 1)}-${pad(end.getDate())}T${pad(end.getHours())}:${pad(end.getMinutes())}`
}

function formatScheduleDateTime(date: Date) {
  const pad = (part: number) => String(part).padStart(2, '0')
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
}

function formatInputDateTime(value: string) {
  const match = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})$/.exec(value)
  return match ? `${match[1]}-${match[2]}-${match[3]} ${match[4]}:${match[5]}:00` : ''
}

async function setThemePassActive(activity: ScheduleRow, active: boolean, event: Event) {
  const checkbox = event.target
  if (!(checkbox instanceof HTMLInputElement)) return

  const key = rowKey(activity)
  if (isDirty(activity) || savingKey.value) {
    errorMessage.value = 'กรุณาบันทึกตารางเวลาที่แก้ไขค้างไว้ก่อนเปิดทันที'
    checkbox.checked = isThemePassActive(activity)
    return
  }

  const now = new Date()
  const nowText = formatScheduleDateTime(now)
  let fields: Record<string, string> = {
    ShowEnd: nowText,
  }
  if (active) {
    const endTime = formatInputDateTime(quickOpenEndTimes.value[key] || '')
    const endDate = endTime ? parseScheduleDate(endTime) : null
    if (!endDate || endDate <= now) {
      errorMessage.value = 'กรุณากำหนดเวลาปิดให้เป็นอนาคต'
      checkbox.checked = false
      return
    }
    fields = {
      ShowStart: nowText,
      ShowEnd: endTime,
    }
    if ('OpenStart' in activity.fields) fields.OpenStart = '-1'
    if ('ShowWeekStart' in activity.fields) fields.ShowWeekStart = ''
    if ('ShowWeekEnd' in activity.fields) fields.ShowWeekEnd = ''
    if ('TabShowEnd' in activity.fields) fields.TabShowEnd = endTime
  } else {
    if (!window.confirm(`ยืนยันปิดกิจกรรม "${activity.name}" ทันทีหรือไม่?`)) {
      checkbox.checked = true
      return
    }
    if ('TabShowEnd' in activity.fields) fields.TabShowEnd = nowText
  }

  savingKey.value = key
  errorMessage.value = ''
  successMessage.value = ''
  try {
    await $fetch('/api/activities/schedule', {
      method: 'POST',
      body: { configId: activity.configId, id: activity.id, fields },
    })
    activity.fields = { ...activity.fields, ...fields }
    drafts.value[key] = { ...activity.fields }
    successMessage.value = active
      ? `${activity.name}: เปิดทันทีและจะปิด ${fields.ShowEnd}`
      : `${activity.name}: ปิดกิจกรรมแล้ว`
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'เปิดกิจกรรมทันทีไม่สำเร็จ'
    checkbox.checked = isThemePassActive(activity)
  } finally {
    savingKey.value = ''
  }
}

function isThemePassActive(activity: ScheduleRow) {
  if (!activity.canOpenImmediately) return false
  const start = parseScheduleDate(activity.fields.ShowStart || '')
  const end = parseScheduleDate(activity.fields.ShowEnd || '')
  const now = new Date()
  return Boolean(start && end && now > start && now < end)
}

function isDirty(activity: ScheduleRow) {
  const draft = drafts.value[rowKey(activity)]
  return Boolean(draft && Object.keys(activity.fields).some((field) => draft[field] !== activity.fields[field]))
}

function changedFields(activity: ScheduleRow): Record<string, string> {
  const draft = drafts.value[rowKey(activity)]
  if (!draft) return {}
  const changes: Record<string, string> = {}
  for (const [field, value] of Object.entries(draft)) {
    if (value !== activity.fields[field]) changes[field] = value
  }
  return changes
}

async function saveSchedule(activity: ScheduleRow) {
  const fields = changedFields(activity)
  if (Object.keys(fields).length === 0 || savingKey.value) return

  savingKey.value = rowKey(activity)
  errorMessage.value = ''
  successMessage.value = ''
  try {
    await $fetch('/api/activities/schedule', {
      method: 'POST',
      body: { configId: activity.configId, id: activity.id, fields },
    })
    activity.fields = { ...activity.fields, ...fields }
    successMessage.value = `${activity.name}: บันทึกตารางเวลาแล้ว`
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'บันทึกตารางเวลาไม่สำเร็จ'
  } finally {
    savingKey.value = ''
  }
}

function scheduleStatus(activity: ScheduleRow) {
  const fields = activity.fields
  const start = fields.ShowStart || fields.OpenStart || fields.StartDate || fields.ActivityStart
  const end = fields.ShowEnd || fields.OpenEnd || fields.EndDate || fields.ActivityEnd
  const startDate = start ? parseScheduleDate(start) : null
  const endDate = end ? parseScheduleDate(end) : null
  if (startDate && endDate) {
    const now = new Date()
    if (fields.StartTime) {
      const [hour, minute, second] = fields.StartTime.split(':').map(Number)
      startDate.setHours(hour, minute, second, 0)
    }
    if (fields.EndTime) {
      const [hour, minute, second] = fields.EndTime.split(':').map(Number)
      endDate.setHours(hour, minute, second, 0)
    }
    if (now < startDate) return 'ยังไม่เริ่ม'
    if (now > endDate) return 'หมดเวลา'
    return 'อยู่ในช่วงเวลา'
  }
  if ('OpenStart' in fields || 'OpenEnd' in fields) return 'ขึ้นกับวันเปิดเซิร์ฟเวอร์'
  if ('BeginTime' in fields || 'EndTime' in fields || 'ShowWeekStart' in fields) return 'ตารางตามวัน/สัปดาห์'
  if ('OpenTime' in fields) return activity.configId === 'hunting-unlocks' ? 'ปลดล็อกตามเวลา' : 'เวลาเปิดแบบนับจากวัน'
  return 'กำหนดเวลา'
}

function parseScheduleDate(value: string) {
  const match = /^(\d{4})-(\d{1,2})-(\d{1,2})[ T](\d{1,2}):(\d{2}):(\d{2})$/.exec(value)
  if (!match) return null
  const [, yearText, monthText, dayText, hourText, minuteText, secondText] = match
  const [year, month, day, hour, minute, second] = [yearText, monthText, dayText, hourText, minuteText, secondText].map(Number)
  const date = new Date(year, month - 1, day, hour, minute, second)
  if (
    date.getFullYear() !== year
    || date.getMonth() !== month - 1
    || date.getDate() !== day
    || date.getHours() !== hour
    || date.getMinutes() !== minute
    || date.getSeconds() !== second
  ) {
    return null
  }
  return date
}

function formatClass(activity: ScheduleRow) {
  const status = scheduleStatus(activity)
  if (status === 'อยู่ในช่วงเวลา') return 'text-bg-success'
  if (status === 'หมดเวลา') return 'text-bg-secondary'
  if (status === 'ยังไม่เริ่ม') return 'text-bg-warning'
  return 'text-bg-info'
}

onMounted(loadSchedules)
</script>

<template>
  <section class="container-fluid">
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
      <div>
        <h1 class="h3 mb-1">จัดการกิจกรรม</h1>
        <p class="text-body-secondary mb-0">จัดการตารางเวลาจาก XML เกม รวมถึงกิจกรรมเรือมังกรและเรือพาย</p>
      </div>
      <button class="btn btn-outline-secondary" type="button" :disabled="loading || savingKey !== ''" @click="loadSchedules">
        {{ loading ? 'กำลังโหลด...' : 'โหลดข้อมูลใหม่' }}
      </button>
    </div>

    <div class="alert alert-warning">
      แต่ละกิจกรรมใช้เงื่อนไขเวลาไม่เหมือนกัน (วันปฏิทิน, วันเปิดเซิร์ฟเวอร์ หรือรอบสัปดาห์) หน้านี้แก้เฉพาะฟิลด์ตารางเวลาที่มีอยู่ใน XML และไม่เปลี่ยนรางวัลหรือเงื่อนไขกิจกรรม
      <br>
      การบันทึกแก้ XML config; เกมอาจต้องโหลด config ใหม่หรือรีสตาร์ตจึงจะเห็นผล
    </div>
    <div class="alert alert-info">
      ตรวจใน config และ source ที่มีแล้วพบกิจกรรมเรือมังกร/เรือพาย แต่ยังไม่พบรายการที่ระบุเป็นกิจกรรมรถไฟ จึงไม่สร้างรายการขึ้นมาเอง
    </div>

    <div v-if="errorMessage" class="alert alert-danger" role="alert">{{ errorMessage }}</div>
    <div v-if="successMessage" class="alert alert-success" role="status">{{ successMessage }}</div>

    <div class="row g-2 mb-3">
      <div class="col-12 col-md-5">
        <label class="form-label" for="activity-config">ประเภทข้อมูลกิจกรรม</label>
        <select id="activity-config" v-model="selectedConfigId" class="form-select" :disabled="loading">
          <option :value="allConfigsId">ทั้งหมด</option>
          <option v-for="config in configs" :key="config.id" :value="config.id">
            {{ config.title }}
          </option>
        </select>
      </div>
      <div class="col-12 col-md-7">
        <label class="form-label" for="activity-search">ค้นหาชื่อหรือ ID</label>
        <input id="activity-search" v-model="search" class="form-control" type="search" placeholder="เช่น เรือพาย, เรือมังกร, 33">
      </div>
    </div>

    <p v-if="selectedConfig" class="small text-body-secondary">{{ selectedConfig.description }}</p>
    <div v-if="!loading && configRows.length" class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-2">
      <span class="small text-body-secondary">พบ {{ configRows.length }} รายการ</span>
      <nav v-if="pageCount > 1" aria-label="หน้ารายการกิจกรรม">
        <ul class="pagination pagination-sm mb-0">
          <li class="page-item" :class="{ disabled: page <= 1 }">
            <button class="page-link" type="button" :disabled="page <= 1" @click="page--">ก่อนหน้า</button>
          </li>
          <li class="page-item disabled"><span class="page-link">{{ page }} / {{ pageCount }}</span></li>
          <li class="page-item" :class="{ disabled: page >= pageCount }">
            <button class="page-link" type="button" :disabled="page >= pageCount" @click="page++">ถัดไป</button>
          </li>
        </ul>
      </nav>
    </div>

    <div v-if="loading" class="alert alert-info">กำลังโหลดตารางเวลากิจกรรม...</div>
    <div v-else-if="!configRows.length" class="alert alert-secondary">ไม่พบกิจกรรมในหมวดนี้ หรือไม่ตรงกับคำค้นหา</div>
    <div v-else class="row g-3">
      <div v-for="activity in visibleRows" :key="rowKey(activity)" class="col-12 col-xl-6">
        <article class="card h-100">
          <img
            v-if="activity.imageUrl"
            :src="activity.imageUrl"
            :alt="`ภาพกิจกรรม ${activity.name}`"
            class="card-img-top activity-card-image"
            loading="lazy"
          >
          <div class="card-header d-flex flex-wrap align-items-center justify-content-between gap-2">
            <div>
              <h2 class="h6 mb-1">{{ activity.name }}</h2>
              <div class="small text-body-secondary">{{ activity.configTitle }} · ID {{ activity.id }}</div>
            </div>
            <div v-if="activity.canOpenImmediately" class="form-check form-switch mb-0">
              <input
                :id="`activity-active-${rowKey(activity)}`"
                class="form-check-input"
                type="checkbox"
                role="switch"
                :checked="isThemePassActive(activity)"
                :disabled="savingKey !== ''"
                @change="setThemePassActive(activity, ($event.target as HTMLInputElement).checked, $event)"
              >
              <label class="form-check-label" :for="`activity-active-${rowKey(activity)}`">
                {{ isThemePassActive(activity) ? 'เปิดอยู่' : 'เปิดทันที' }}
              </label>
            </div>
            <span v-else class="badge" :class="formatClass(activity)">{{ scheduleStatus(activity) }}</span>
          </div>
          <div class="card-body">
            <div v-if="activity.canOpenImmediately && !isThemePassActive(activity)" class="row align-items-end g-2 mb-3">
              <div class="col">
                <label class="form-label small" :for="`activity-open-end-${rowKey(activity)}`">กำหนดเวลาปิดหลังเปิดทันที</label>
                <input
                  :id="`activity-open-end-${rowKey(activity)}`"
                  v-model="quickOpenEndTimes[rowKey(activity)]"
                  class="form-control form-control-sm"
                  type="datetime-local"
                  :disabled="savingKey !== ''"
                  required
                >
              </div>
              <div class="form-text">เปิดสวิตช์เพื่อเริ่มบัตรธีมทันที และยกเลิกเงื่อนไขวัน/สัปดาห์เดิมของรายการนี้</div>
            </div>
            <div class="row g-2">
              <div
                v-for="field in configs.find((config) => config.id === activity.configId)?.fields.filter((item) => item.key in activity.fields)"
                :key="field.key"
                class="col-12"
              >
                <label class="form-label small mb-1" :for="`activity-${activity.configId}-${activity.id}-${field.key}`">
                  {{ field.label }}
                </label>
                <input
                  :id="`activity-${activity.configId}-${activity.id}-${field.key}`"
                  v-model="drafts[rowKey(activity)][field.key]"
                  class="form-control form-control-sm"
                  type="text"
                  maxlength="128"
                  :disabled="savingKey !== ''"
                  :aria-describedby="`activity-format-${activity.configId}-${field.key}`"
                >
                <div :id="`activity-format-${activity.configId}-${field.key}`" class="form-text">{{ field.format }}</div>
              </div>
            </div>
            <div class="d-flex justify-content-end mt-3">
              <button
                class="btn btn-sm btn-primary"
                type="button"
                :disabled="!isDirty(activity) || savingKey !== ''"
                @click="saveSchedule(activity)"
              >
                {{ savingKey === rowKey(activity) ? 'กำลังบันทึก...' : 'บันทึกตารางเวลา' }}
              </button>
            </div>
          </div>
        </article>
      </div>
    </div>
  </section>
</template>

<style scoped>
.activity-card-image {
  aspect-ratio: 16 / 9;
  object-fit: cover;
  background-color: var(--bs-tertiary-bg);
}
</style>
