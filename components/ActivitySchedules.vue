<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import {
  getActivityOverrideFields,
  isProtectedRechargeActivity,
  isActivityAlwaysOpen,
  isActivityForceClosed,
} from '~/utils/activity-schedule-overrides'

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
  exclusiveGroup: boolean
  giftType?: number
  subType?: number
  groupName?: string
  id: number
  name: string
  configId: string
  configTitle: string
  fields: Record<string, string>
  durationDays?: number
  imageUrl?: string
  bannerGroupKey?: string
  canOpenForever: boolean
}

type ActivityKind = 'all' | 'permanent' | 'scheduled' | 'theme-boss'

const route = useRoute()
const activityKind = ref<ActivityKind>('all')
const activeGroupKey = computed(() => typeof route.params.group === 'string' ? route.params.group : '')
watch(() => route.query.kind, (kind) => {
  activityKind.value = kind === 'permanent'
    || kind === 'scheduled'
    || kind === 'theme-boss'
    ? kind
    : 'all'
}, { immediate: true })

function groupKey(activity: ScheduleRow) {
  if (activity.giftType === 44) return 'gift-44'
  if (activity.giftType === 11 && activity.bannerGroupKey) {
    return `banner-${activity.bannerGroupKey}`
  }
  if (activity.giftType) {
    const categoryBannerKey = activities.value.find(item => item.giftType === activity.giftType)?.bannerGroupKey
    if (categoryBannerKey) return `banner-${categoryBannerKey}`
  }
  if (activity.bannerGroupKey) return `banner-${activity.bannerGroupKey}`
  return activity.giftType ? `gift-${activity.giftType}` : `config-${activity.configId}`
}
function isInGroup(activity: ScheduleRow, key: string) {
  if (groupKey(activity) === key) return true
  const legacyGiftType = /^gift-(\d+)$/.exec(key)
  return Boolean(legacyGiftType && activity.giftType === Number(legacyGiftType[1]))
}
function groupName(rows: ScheduleRow[]) {
  if (rows.length && rows.every(activity => activity.giftType === 11)) {
    return [...new Set(rows.map(activity => activity.name))].join(' / ')
  }
  return [...new Set(rows.map(activity => activity.groupName || activity.configTitle))].join(' / ')
}
function isPermanentActivity(activity: ScheduleRow) {
  return isProtectedRechargeActivity(activity.configId, activity.id)
    || isActivityAlwaysOpen(activity.configId, activity.fields)
}
function matchesActivityKind(activity: ScheduleRow) {
  if (activityKind.value === 'permanent') return isPermanentActivity(activity)
  if (activityKind.value === 'scheduled') return !isPermanentActivity(activity)
  if (activityKind.value === 'theme-boss') return activity.giftType === 11
  return true
}
function activityGroupRoute(key: string) {
  return {
    path: `/activities/${key}`,
    query: activityKind.value === 'all' ? {} : { kind: activityKind.value },
  }
}
function activityListRoute() {
  return {
    path: '/activities',
    query: activityKind.value === 'all' ? {} : { kind: activityKind.value },
  }
}
const allConfigsId = 'all'
const configs = ref<ScheduleConfig[]>([])
const activities = ref<ScheduleRow[]>([])
const drafts = ref<Record<string, Record<string, string>>>({})
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
  .filter(matchesActivityKind)
  .filter((activity) => !activeGroupKey.value || isInGroup(activity, activeGroupKey.value))
  .filter((activity) => selectedConfigId.value === allConfigsId || activity.configId === selectedConfigId.value)
  .filter((activity) => {
    const query = search.value.trim().toLocaleLowerCase()
    return !query || `${activity.id} ${activity.name} ${Object.values(activity.fields).join(' ')}`
      .toLocaleLowerCase()
      .includes(query)
  }))
const groups = computed(() => {
  const grouped = new Map<string, { key: string; name: string; giftTypes: number[]; rows: ScheduleRow[]; imageUrl?: string }>()
  for (const activity of configRows.value) {
    const key = groupKey(activity)
    let group = grouped.get(key)
    if (!group) {
      group = { key, name: '', giftTypes: [], rows: [], imageUrl: activity.imageUrl }
      grouped.set(key, group)
    }
    group.rows.push(activity)
    group.name = groupName(group.rows)
    if (activity.giftType && !group.giftTypes.includes(activity.giftType)) group.giftTypes.push(activity.giftType)
  }
  return [...grouped.values()]
})
const currentGroupName = computed(() => {
  const rows = activities.value.filter(activity => isInGroup(activity, activeGroupKey.value))
  return rows.length ? groupName(rows) : undefined
})
const resultCount = computed(() => activeGroupKey.value ? configRows.value.length : groups.value.length)
const pageCount = computed(() => Math.max(1, Math.ceil(resultCount.value / pageSize)))
const visibleRows = computed(() => configRows.value.slice((page.value - 1) * pageSize, page.value * pageSize))
const visibleGroups = computed(() => groups.value.slice((page.value - 1) * pageSize, page.value * pageSize))

watch([selectedConfigId, search, activeGroupKey, activityKind], () => {
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
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'โหลดตารางเวลากิจกรรมไม่สำเร็จ'
  } finally {
    loading.value = false
  }
}

function rowKey(activity: ScheduleRow) {
  return `${activity.configId}:${activity.id}`
}

function isGroupEnabled(group: { rows: ScheduleRow[] }) {
  return group.rows.length > 0 && group.rows.some(activity => isActivityEnabled(activity))
}

function isSingleThemeBossGroup(group: { giftTypes: number[]; rows: ScheduleRow[] }) {
  return group.giftTypes.length === 1 && group.giftTypes[0] === 11 && group.rows.length === 1
}

async function setGroupActivity(group: { key: string; name: string; giftTypes: number[]; rows: ScheduleRow[] }, active: boolean, event: Event) {
  const checkbox = event.target
  if (!(checkbox instanceof HTMLInputElement)) return
  if (savingKey.value) return
  if (
    active
    && group.rows.some(row => row.exclusiveGroup)
    && group.key !== 'gift-44'
    && !isSingleThemeBossGroup(group)
  ) {
    errorMessage.value = 'กิจกรรมนี้เปิดได้ครั้งละรอบ กรุณาเลือกชุดในหน้าจัดการกิจกรรม'
    checkbox.checked = isGroupEnabled(group)
    return
  }
  if (!active && !window.confirm(`ยืนยันปิด "${group.name}" ทันทีหรือไม่?`)) {
    checkbox.checked = isGroupEnabled(group)
    return
  }

  const key = group.key
  errorMessage.value = ''
  successMessage.value = ''
  let openedCount = 0

  try {
    savingKey.value = key
    const rows = active && group.key === 'gift-44'
      ? activities.value.filter(activity => activity.configId === 'recharge-tabs' && activity.id === 130)
      : group.rows
    for (const activity of rows) {
      if (!active && isProtectedRechargeActivity(activity.configId, activity.id)) {
        throw new Error(`กิจกรรม ID ${activity.id} ถูกล็อกไว้ ห้ามปิดระบบ`)
      }
      if (isDirty(activity)) {
        throw new Error(`กรุณาบันทึกตารางเวลาของ "${activity.name}" ที่แก้ไขค้างไว้ก่อน`)
      }

      let fields: Record<string, string>
      if (active && activity.configId === 'recharge-tabs' && activity.durationDays) {
        const result = await $fetch<{
          configured: boolean
          durationDays?: number
          fields?: Record<string, string>
        }>('/api/activities/open', {
          method: 'POST',
          body: { configId: activity.configId, id: activity.id },
        })
        if (!result.configured || !result.fields || !result.durationDays) {
          throw new Error(`"${activity.name}" ยังไม่มีระยะเวลาเปิดที่กำหนดไว้`)
        }
        fields = result.fields
        activity.durationDays = result.durationDays
      } else {
        fields = getActivityOverrideFields(activity.configId, active, new Date())
        await $fetch('/api/activities/schedule', {
          method: 'POST',
          body: { configId: activity.configId, id: activity.id, fields },
        })
      }

      activity.fields = { ...activity.fields, ...fields }
      drafts.value[rowKey(activity)] = { ...activity.fields }
      openedCount++
    }
    if (group.key === 'gift-44') await loadSchedules()
    successMessage.value = active
      ? `เปิด "${group.name}" ทันทีแล้ว (${openedCount} ชุดกิจกรรม)`
      : `ปิด "${group.name}" แล้ว (${openedCount} ชุดกิจกรรม)`
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'เปิดกิจกรรมไม่สำเร็จ'
    checkbox.checked = isGroupEnabled(group)
  } finally {
    savingKey.value = ''
  }
}

async function setActivityAlwaysOpen(activity: ScheduleRow, active: boolean, event: Event) {
  const checkbox = event.target
  if (!(checkbox instanceof HTMLInputElement)) return

  const key = rowKey(activity)
  if (!active && isProtectedRechargeActivity(activity.configId, activity.id)) {
    errorMessage.value = `กิจกรรม ID ${activity.id} ถูกล็อกไว้ ห้ามปิดระบบ`
    checkbox.checked = isActivityEnabled(activity)
    return
  }
  if (isDirty(activity) || savingKey.value) {
    errorMessage.value = 'กรุณาบันทึกตารางเวลาที่แก้ไขค้างไว้ก่อนเปลี่ยนสถานะกิจกรรม'
    checkbox.checked = isActivityEnabled(activity)
    return
  }

  const currentlyOpen = isActivityEnabled(activity)
  if (!active && !window.confirm(`ยืนยันปิดกิจกรรม "${activity.name}" ทันทีหรือไม่?`)) {
    checkbox.checked = currentlyOpen
    return
  }

  savingKey.value = key
  errorMessage.value = ''
  successMessage.value = ''
  try {
    let fields: Record<string, string>
    if (active && activity.configId === 'recharge-tabs' && activity.durationDays) {
      const result = await $fetch<{
        configured: boolean
        durationDays?: number
        fields?: Record<string, string>
      }>('/api/activities/open', {
        method: 'POST',
        body: { configId: activity.configId, id: activity.id },
      })
      if (result.configured) {
        if (!result.fields || !result.durationDays) {
          throw new Error('ข้อมูลระยะเวลาเปิดกิจกรรมจาก AdminAPI ไม่ครบ')
        }
        fields = result.fields
        activity.durationDays = result.durationDays
      } else {
        throw new Error('แพ็กนี้ไม่มีระยะเวลาเปิดที่กำหนดไว้ จึงไม่สามารถเปิดจากสวิตช์นี้ได้ เพื่อป้องกันการตั้งวันสิ้นสุดเป็น 9999')
      }
    } else {
      fields = getActivityOverrideFields(activity.configId, active, new Date())
      await $fetch('/api/activities/schedule', {
        method: 'POST',
        body: { configId: activity.configId, id: activity.id, fields },
      })
    }
    activity.fields = { ...activity.fields, ...fields }
    drafts.value[key] = { ...activity.fields }
    if (activity.giftType === 44) await loadSchedules()
    successMessage.value = active
      ? activity.durationDays
        ? `${activity.name}: ตั้งเปิด ${activity.durationDays} วัน เริ่ม ${activity.fields.ShowStart || ''} ถึง ${activity.fields.ShowEnd || ''}`
        : `${activity.name}: เปิดตลอดแล้ว`
      : `${activity.name}: ปิดกิจกรรมแล้ว`
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'เปลี่ยนสถานะกิจกรรมไม่สำเร็จ'
    checkbox.checked = currentlyOpen
  } finally {
    savingKey.value = ''
  }
}

function isAlwaysOpen(activity: ScheduleRow) {
  return isActivityAlwaysOpen(activity.configId, activity.fields)
}

function isActivityEnabled(activity: ScheduleRow) {
  if (isProtectedRechargeActivity(activity.configId, activity.id)) return true

  if (
    activity.configId === 'recharge-tabs'
    && !activity.durationDays
    && !isActivityForceClosed(activity.configId, activity.fields)
    && !activity.fields.ShowStart
    && !activity.fields.ShowEnd
    && Boolean(activity.fields.ShowWeekStart)
    && !activity.fields.ShowWeekEnd
  ) {
    return true
  }

  if (
    activity.configId === 'recharge-tabs'
    && activity.durationDays
    && !isActivityForceClosed(activity.configId, activity.fields)
  ) {
    const start = parseScheduleDate(activity.fields.ShowStart || '')
    const end = parseScheduleDate(activity.fields.ShowEnd || '')
    const now = new Date()
    return Boolean(start && end && end > start && now < end)
  }
  return isAlwaysOpen(activity)
}

function activityToggleLabel(activity: ScheduleRow) {
  if (isProtectedRechargeActivity(activity.configId, activity.id)) return 'เปิดอยู่ (ห้ามปิด)'

  if (isActivityEnabled(activity)) {
    const start = parseScheduleDate(activity.fields.ShowStart || '')
    if (start && new Date() < start) return `ตั้งเปิด (${activity.durationDays} วัน)`
    if (activity.durationDays) return `เปิดอยู่ (${activity.durationDays} วัน)`
    return isPermanentActivity(activity) ? 'เปิดตลอดอยู่' : 'เปิดตามตาราง'
  }
  if (isForceClosed(activity)) return 'ปิดแล้ว'
  return activity.durationDays ? `เปิด ${activity.durationDays} วัน` : 'เปิด'
}

function isForceClosed(activity: ScheduleRow) {
  return isActivityForceClosed(activity.configId, activity.fields)
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
    if (activity.configId === 'recharge-tabs' && ('ShowStart' in fields || 'ShowEnd' in fields)) {
      const durationDays = getConfiguredDurationDays(activity.fields.ShowStart, activity.fields.ShowEnd)
      if (durationDays) activity.durationDays = durationDays
    }
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

function getConfiguredDurationDays(startValue?: string, endValue?: string) {
  const start = startValue ? parseScheduleDate(startValue) : null
  const end = endValue ? parseScheduleDate(endValue) : null
  if (!start || !end || start.getFullYear() >= 9999 || end.getFullYear() >= 9999 || end <= start) return undefined

  const startDay = Date.UTC(start.getFullYear(), start.getMonth(), start.getDate())
  const endDay = Date.UTC(end.getFullYear(), end.getMonth(), end.getDate())
  const dateDifference = (endDay - startDay) / 86_400_000
  const endsAtMidnight = end.getHours() === 0 && end.getMinutes() === 0 && end.getSeconds() === 0
  const durationDays = dateDifference + (endsAtMidnight ? 0 : 1)
  return Number.isSafeInteger(durationDays) && durationDays > 0 ? durationDays : undefined
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
        <NuxtLink v-if="activeGroupKey" :to="activityListRoute()" class="d-inline-block mb-2">← กิจกรรมทั้งหมด</NuxtLink>
        <h1 class="h3 mb-1">{{ activeGroupKey ? (currentGroupName || 'ไม่พบกิจกรรม') : 'กิจกรรมทั้งหมด' }}</h1>
        <p class="text-body-secondary mb-0">{{ activeGroupKey ? 'เลือกชุดกิจกรรมเพื่อจัดการเวลาเปิด–ปิด' : 'เลือกกิจกรรมเพื่อจัดการชุดและรอบทั้งหมด' }}</p>
      </div>
      <button class="btn btn-outline-secondary" type="button" :disabled="loading || savingKey !== ''" @click="loadSchedules">
        {{ loading ? 'กำลังโหลด...' : 'โหลดข้อมูลใหม่' }}
      </button>
    </div>

    <div v-if="errorMessage" class="alert alert-danger" role="alert">{{ errorMessage }}</div>
    <div v-if="successMessage" class="alert alert-success" role="status">{{ successMessage }}</div>

    <div class="row g-2 mb-3">
      <div class="col-12 col-md-3">
        <label class="form-label" for="activity-kind">หมวดเวลาเปิด</label>
        <select id="activity-kind" v-model="activityKind" class="form-select" :disabled="loading">
          <option value="all">กิจกรรมทั้งหมด</option>
          <option value="permanent">กิจกรรมถาวร</option>
          <option value="scheduled">กิจกรรมตามกำหนดเวลา</option>
          <option v-if="!activeGroupKey" value="theme-boss">บอสธีม</option>
        </select>
      </div>
      <div class="col-12 col-md-3">
        <label class="form-label" for="activity-config">ประเภทข้อมูลกิจกรรม</label>
        <select id="activity-config" v-model="selectedConfigId" class="form-select" :disabled="loading">
          <option :value="allConfigsId">ทั้งหมด</option>
          <option v-for="config in configs" :key="config.id" :value="config.id">
            {{ config.title }}
          </option>
        </select>
      </div>
      <div class="col-12 col-md-3">
        <label class="form-label" for="activity-search">ค้นหาชื่อหรือ ID</label>
        <input id="activity-search" v-model="search" class="form-control" type="search" placeholder="เช่น เรือพาย, เรือมังกร, 33">
      </div>
    </div>

    <p v-if="selectedConfig" class="small text-body-secondary">{{ selectedConfig.description }}</p>
    <div v-if="!loading && configRows.length" class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-2">
      <span class="small text-body-secondary">พบ {{ resultCount }} {{ activeGroupKey ? 'ชุดกิจกรรม' : 'กิจกรรม' }}</span>
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
    <div v-else-if="!activeGroupKey" class="row g-3">
      <div v-for="group in visibleGroups" :key="group.key" class="col-12 col-md-6 col-xl-4">
        <article class="card h-100 activity-group-card">
          <NuxtLink :to="activityGroupRoute(group.key)" class="text-decoration-none text-reset">
            <img v-if="group.imageUrl" :src="group.imageUrl" :alt="group.name" class="card-img-top activity-card-image" loading="lazy">
            <div class="card-body">
              <h2 class="h5">{{ group.name }}</h2>
              <p v-if="group.rows.some(row => row.exclusiveGroup)" class="small text-warning mb-2">เปิดได้ครั้งละรอบ — เลือกชุดในหน้าจัดการกิจกรรม</p>
              <p v-if="group.rows.some(row => isProtectedRechargeActivity(row.configId, row.id))" class="small text-warning mb-2">กลุ่มนี้มีกิจกรรมที่ล็อกให้เปิดตลอด</p>
              <p class="text-body-secondary mb-2">{{ group.rows.length }} ชุดกิจกรรม<span v-if="group.giftTypes.length"> · GiftType {{ group.giftTypes.join(', ') }}</span></p>
            </div>
          </NuxtLink>
          <div
            v-if="!group.rows.some(row => row.exclusiveGroup) || group.key === 'gift-44' || isSingleThemeBossGroup(group)"
            class="activity-group-toggle form-check form-switch mb-0"
          >
            <input
              :id="`group-active-${group.key}`"
              class="form-check-input"
              type="checkbox"
              role="switch"
              :checked="isGroupEnabled(group)"
              :disabled="savingKey !== '' || group.rows.some(row => isProtectedRechargeActivity(row.configId, row.id))"
              @change="setGroupActivity(group, ($event.target as HTMLInputElement).checked, $event)"
            >
            <label class="visually-hidden" :for="`group-active-${group.key}`">เปิดหรือปิดกิจกรรม {{ group.name }}</label>
          </div>
          <div class="card-body flex-grow-0 pt-0 mt-auto d-flex justify-content-end">
            <NuxtLink :to="activityGroupRoute(group.key)" class="btn btn-primary">จัดการกิจกรรม →</NuxtLink>
          </div>
        </article>
      </div>
    </div>
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
              <p v-if="activity.exclusiveGroup && activity.giftType !== 44" class="small mb-1">เปิดได้ครั้งละรอบ ระบบจะปฏิเสธช่วงเวลาที่ซ้อนกับชุดอื่น</p>
              <p v-if="activity.giftType === 44" class="small mb-1">{{ activity.id === 130 ? 'ชุดเปิดทันที — เมื่อเปิดจะอัปเดตเวลา และปิดชุดที่มีช่วงเวลาซ้อนกัน' : 'ชุดตั้งเวลา — กำหนดวันเริ่มและวันจบด้านล่าง' }}</p>
              <div class="small text-body-secondary">{{ activity.configTitle }} · ID {{ activity.id }}<span v-if="activity.subType !== undefined"> · SubType {{ activity.subType }}</span></div>
            </div>
            <div v-if="activity.canOpenForever && !(activity.giftType === 44 && activity.id !== 130)" class="form-check form-switch mb-0">
              <input
                :id="`activity-active-${rowKey(activity)}`"
                class="form-check-input"
                type="checkbox"
                role="switch"
                :checked="isActivityEnabled(activity)"
                :disabled="savingKey !== '' || isProtectedRechargeActivity(activity.configId, activity.id)"
                @change="setActivityAlwaysOpen(activity, ($event.target as HTMLInputElement).checked, $event)"
              >
              <label class="form-check-label" :for="`activity-active-${rowKey(activity)}`">
                {{ activityToggleLabel(activity) }}
              </label>
            </div>
            <span v-else class="badge" :class="formatClass(activity)">{{ scheduleStatus(activity) }}</span>
          </div>
          <div class="card-body">
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

    <nav v-if="!loading && configRows.length && pageCount > 1" class="d-flex justify-content-center mt-3" aria-label="การแบ่งหน้ารายการกิจกรรมด้านล่าง">
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
  </section>
</template>

<style scoped>
.activity-card-image {
  width: 100%;
  height: auto;
  object-fit: contain;
  background-color: var(--bs-tertiary-bg);
}

.activity-group-card {
  position: relative;
}

.activity-group-toggle {
  position: absolute;
  top: 0.75rem;
  right: 0.75rem;
  z-index: 2;
}
</style>
