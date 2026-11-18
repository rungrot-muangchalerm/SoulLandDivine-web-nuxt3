<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import {
  getActivityOverrideFields,
  getControlledRechargeActivityMessage,
  getBossLinkedRechargeActivityNotice,
  getBossLinkedRechargeActivities,
  getBossLinkedRechargeParentId,
  getSuperSalesLinkedShreklandActivities,
  getSuperSalesLinkedShreklandParentId,
  getSuperSalesLinkedShreklandActivityNotice,
  isBossLinkedRechargeActivity,
  isSuperSalesLinkedShreklandActivity,
  isControlledRechargeActivity,
  isProtectedRechargeActivity,
  isActivityAlwaysOpen,
  isActivityForceClosed,
} from '~/utils/activity-schedule-overrides'
import { isVisibleInActivityManagement } from '~/utils/activity-schedule-visibility.mjs'
import { sortActivitiesById } from '~/utils/activity-id-sort.mjs'

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
  giftType?: number
  giftTypeLabel?: string
  subType?: number
  id: number
  name: string
  configId: string
  configTitle: string
  fields: Record<string, string>
  durationDays?: number
  imageUrl?: string
  canOpenForever: boolean
}



const props = defineProps<{ activityId?: number }>()
const isDetailView = computed(() => props.activityId !== undefined)

const route = useRoute()
const { activityKind, selectedConfigId, configs, loading } = useActivityListFilters()
watch(() => route.query.kind, (kind) => {
  activityKind.value = kind === 'permanent'
    || kind === 'scheduled'
    ? kind
    : 'all'
}, { immediate: true })

function isPermanentActivity(activity: ScheduleRow) {
  return isProtectedRechargeActivity(activity.configId, activity.id)
    || isActivityAlwaysOpen(activity.configId, activity.fields)
}
function matchesActivityKind(activity: ScheduleRow) {
  if (activityKind.value === 'permanent') return isPermanentActivity(activity)
  if (activityKind.value === 'scheduled') return !isPermanentActivity(activity)
  return true
}
const allConfigsId = 'all'

const activities = ref<ScheduleRow[]>([])
const linkedActivities = ref<ScheduleRow[]>([])
const drafts = ref<Record<string, Record<string, string>>>({})



const savingKey = ref('')
const errorMessage = ref('')
const successMessage = ref('')

const selectedConfig = computed(() => configs.value.find((config) => config.id === selectedConfigId.value))
const selectedActivity = computed(() => isDetailView.value
  ? activities.value.find((activity) => activity.id === props.activityId)
    ?? linkedActivities.value.find((activity) => isBossLinkedRechargeActivity(activity.configId, activity.id)
      && activity.id === props.activityId)
    ?? linkedActivities.value.find((activity) => isSuperSalesLinkedShreklandActivity(activity.configId, activity.id)
      && activity.id === props.activityId)
  : undefined)
const selectedActivityConfig = computed(() => selectedActivity.value
  ? configs.value.find((config) => config.id === selectedActivity.value?.configId)
  : undefined)
const configRows = computed(() => sortActivitiesById(activities.value
  .filter(matchesActivityKind)
  .filter((activity) => selectedConfigId.value === allConfigsId || activity.configId === selectedConfigId.value)
))
const resultCount = computed(() => configRows.value.length)

function bossFollowersFor(activity: ScheduleRow) {
  return [
    ...getBossLinkedRechargeActivities('recharge-tabs', activity.id, linkedActivities.value),
    ...getSuperSalesLinkedShreklandActivities('recharge-tabs', activity.id, linkedActivities.value),
  ]
}

async function loadSchedules() {
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''
  try {
    const result = await $fetch<{ configs: ScheduleConfig[]; activities: ScheduleRow[] }>('/api/activities')
    const managedActivities = result.activities.filter(
      activity => isVisibleInActivityManagement(activity)
        && !isControlledRechargeActivity(activity.configId, activity.id),
    )
    linkedActivities.value = result.activities
    configs.value = result.configs
    activities.value = managedActivities
    if (selectedConfigId.value !== allConfigsId && !configs.value.some((config) => config.id === selectedConfigId.value)) {
      selectedConfigId.value = allConfigsId
    }
    drafts.value = Object.fromEntries(managedActivities.map((item) => [
      `${item.configId}:${item.id}`,
      { ...item.fields },
    ]))
    // The linked children are hidden from the list but remain available
    // as read-only detail pages. Initialize their input drafts safely.
    for (const child of result.activities.filter((activity) => isBossLinkedRechargeActivity(activity.configId, activity.id) || isSuperSalesLinkedShreklandActivity(activity.configId, activity.id))) {
      drafts.value[rowKey(child)] = { ...child.fields }
    }
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'โหลดตารางเวลากิจกรรมไม่สำเร็จ'
  } finally {
    loading.value = false
  }
}

function rowKey(activity: ScheduleRow) {
  return `${activity.configId}:${activity.id}`
}

async function setActivityAlwaysOpen(activity: ScheduleRow, active: boolean, event: Event) {
  const checkbox = event.target
  if (!(checkbox instanceof HTMLInputElement)) return

  const key = rowKey(activity)
  if (isControlledRechargeActivity(activity.configId, activity.id)) {
    errorMessage.value = getControlledRechargeActivityMessage(activity.configId, activity.id) ?? 'กิจกรรมนี้ถูกควบคุมตามตู้กาชาที่เกี่ยวข้อง'
    checkbox.checked = isActivityEnabled(activity)
    return
  }
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
    successMessage.value = active
      ? activity.durationDays
        ? `${activity.name}: เปิดทันที ${activity.durationDays} วัน เริ่ม ${activity.fields.ShowStart || ''} ถึง ${activity.fields.ShowEnd || ''}`
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
  if (isControlledRechargeActivity(activity.configId, activity.id)) {
    errorMessage.value = getControlledRechargeActivityMessage(activity.configId, activity.id) ?? 'กิจกรรมนี้ถูกควบคุมตามตู้กาชาที่เกี่ยวข้อง'
    return
  }
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
  if (isControlledRechargeActivity(activity.configId, activity.id)) {
    const startDate = parseScheduleDate(fields.ShowStart || '')
    const endDate = parseScheduleDate(fields.ShowEnd || '')
    if (!startDate || !endDate) return 'หมดเวลา'
    const now = new Date()
    if (now < startDate) return 'ยังไม่เริ่ม'
    if (now > endDate) return 'หมดเวลา'
    return 'อยู่ในช่วงเวลา'
  }

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
        <NuxtLink v-if="isDetailView" to="/activities" class="small text-decoration-none d-inline-flex align-items-center gap-1 mb-2">
          <i class="fa-solid fa-arrow-left" aria-hidden="true" />
          กลับไปหน้ากิจกรรม
        </NuxtLink>
        <h1 class="h3 mb-1">{{ isDetailView ? (selectedActivity?.name || 'รายละเอียดกิจกรรม') : 'กิจกรรมทั้งหมด' }}</h1>
        <p v-if="isDetailView && selectedActivity" class="text-body-secondary mb-0">
          {{ selectedActivity.configTitle }} · ID {{ selectedActivity.id }}<span v-if="selectedActivity.subType !== undefined"> · SubType {{ selectedActivity.subType }}</span>
        </p>
        <p v-else-if="!isDetailView" class="text-body-secondary mb-0">
          จัดการแต่ละกิจกรรมแยกกัน · เปิด/ปิดด่วนจากการ์ด และตั้งเวลาในหน้ารายละเอียด
        </p>
      </div>
    </div>

    <div v-if="errorMessage" class="alert alert-danger" role="alert">{{ errorMessage }}</div>
    <div v-if="successMessage" class="alert alert-success" role="status">{{ successMessage }}</div>

    <template v-if="!isDetailView">
      <p v-if="selectedConfig" class="small text-body-secondary">{{ selectedConfig.description }}</p>
      <p v-if="!loading && configRows.length" class="small text-body-secondary mb-2">
        พบ {{ resultCount }} กิจกรรม
      </p>
    </template>

    <div v-if="loading" class="alert alert-info">กำลังโหลดตารางเวลากิจกรรม...</div>
    <div v-else-if="isDetailView && !selectedActivity" class="alert alert-secondary" role="status">
      ไม่พบกิจกรรม ID {{ props.activityId }} หรือกิจกรรมนี้ถูกควบคุมผ่านหน้าตู้กาชา
    </div>

    <div v-else-if="isDetailView && selectedActivity" class="row">
      <div class="col-12">
        <article class="card">
          <div v-if="selectedActivity.imageUrl" class="activity-detail-image-wrap">
            <img
              :src="selectedActivity.imageUrl"
              :alt="'ภาพกิจกรรม ' + selectedActivity.name"
              class="activity-detail-image"
            >
          </div>
          <div class="card-body">
            <div class="d-flex flex-wrap align-items-center gap-2 mb-3">
              <span class="badge" :class="formatClass(selectedActivity)">{{ scheduleStatus(selectedActivity) }}</span>
              <span v-if="selectedActivity.giftType !== undefined" class="badge text-bg-secondary">
                GiftType {{ selectedActivity.giftType }}
              </span>
              <span v-if="selectedActivity.giftTypeLabel" class="small text-body-secondary">
                {{ selectedActivity.giftTypeLabel }}
              </span>
            </div>

            <NuxtLink
              v-if="getBossLinkedRechargeParentId(selectedActivity.configId, selectedActivity.id) !== undefined"
              :to="'/activities/' + getBossLinkedRechargeParentId(selectedActivity.configId, selectedActivity.id)"
              class="btn btn-outline-primary btn-sm mb-3"
            >
              กลับไปจัดการบอสธีมหลัก ID {{ getBossLinkedRechargeParentId(selectedActivity.configId, selectedActivity.id) }}
            </NuxtLink>
            <NuxtLink
              v-if="getSuperSalesLinkedShreklandParentId(selectedActivity.configId, selectedActivity.id) !== undefined"
              :to="'/activities/' + getSuperSalesLinkedShreklandParentId(selectedActivity.configId, selectedActivity.id)"
              class="btn btn-outline-primary btn-sm mb-3"
            >
              กลับไปจัดการ Super Sales หลัก ID {{ getSuperSalesLinkedShreklandParentId(selectedActivity.configId, selectedActivity.id) }}
            </NuxtLink>
            <div v-if="getSuperSalesLinkedShreklandActivityNotice(selectedActivity.configId, selectedActivity.id)" class="alert alert-info py-2 small">
              {{ getSuperSalesLinkedShreklandActivityNotice(selectedActivity.configId, selectedActivity.id) }}
            </div>
            <div v-if="getBossLinkedRechargeActivityNotice(selectedActivity.configId, selectedActivity.id)" class="alert alert-info py-2 small">
              {{ getBossLinkedRechargeActivityNotice(selectedActivity.configId, selectedActivity.id) }}
            </div>
            <div class="row g-3">
              <div
                v-for="field in selectedActivityConfig?.fields.filter((item) => item.key in selectedActivity.fields)"
                :key="field.key"
                class="col-12 col-lg-6"
              >
                <label class="form-label small mb-1" :for="'activity-' + selectedActivity.configId + '-' + selectedActivity.id + '-' + field.key">
                  {{ field.label }}
                </label>
                <input
                  :id="'activity-' + selectedActivity.configId + '-' + selectedActivity.id + '-' + field.key"
                  v-model="drafts[rowKey(selectedActivity)][field.key]"
                  class="form-control"
                  type="text"
                  maxlength="128"
                  :disabled="savingKey !== '' || isControlledRechargeActivity(selectedActivity.configId, selectedActivity.id)"
                  :aria-describedby="'activity-format-' + selectedActivity.configId + '-' + field.key"
                >
                <div :id="'activity-format-' + selectedActivity.configId + '-' + field.key" class="form-text">
                  {{ field.format }}
                </div>
              </div>
            </div>

            <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mt-4">
              <NuxtLink to="/activities" class="btn btn-outline-secondary">ยกเลิก</NuxtLink>
              <button
                class="btn btn-primary"
                type="button"
                :disabled="!isDirty(selectedActivity) || savingKey !== '' || isControlledRechargeActivity(selectedActivity.configId, selectedActivity.id)"
                @click="saveSchedule(selectedActivity)"
              >
                {{ savingKey === rowKey(selectedActivity) ? 'กำลังบันทึก...' : 'บันทึกตารางเวลา' }}
              </button>
            </div>
          </div>
          <ActivityLinkedPreviews :activities="bossFollowersFor(selectedActivity)" />
        </article>
      </div>
    </div>

    <div v-else-if="!configRows.length" class="alert alert-secondary">
      ไม่พบกิจกรรมที่ตรงกับตัวกรอง
    </div>

    <div v-else-if="!isDetailView" class="row g-3">
      <div v-for="activity in configRows" :key="rowKey(activity)" class="col-12 col-xl-6">
        <article class="card h-100 activity-card">
          <div class="activity-card-media" :class="{ 'activity-card-media--empty': !activity.imageUrl }">
            <img
              v-if="activity.imageUrl"
              :src="activity.imageUrl"
              :alt="'ภาพกิจกรรม ' + activity.name"
              class="activity-card-image"
              loading="lazy"
            >
            <div class="activity-card-overlay">
              <div class="activity-card-overlay-top">
                <div
                  v-if="activity.canOpenForever && !isControlledRechargeActivity(activity.configId, activity.id)"
                  class="form-check form-switch activity-card-toggle mb-0"
                >
                  <input
                    :id="'activity-active-' + rowKey(activity)"
                    class="form-check-input"
                    type="checkbox"
                    role="switch"
                    :checked="isActivityEnabled(activity)"
                    :disabled="savingKey !== '' || isProtectedRechargeActivity(activity.configId, activity.id)"
                    @change="setActivityAlwaysOpen(activity, ($event.target as HTMLInputElement).checked, $event)"
                  >
                  <label class="form-check-label" :for="'activity-active-' + rowKey(activity)">
                    {{ activityToggleLabel(activity) }}
                  </label>
                </div>
                <span v-else class="badge" :class="formatClass(activity)">{{ scheduleStatus(activity) }}</span>
              </div>

              <div class="activity-card-overlay-bottom">
                <div class="activity-card-meta">
                  <h2 class="activity-card-title mb-1">{{ activity.name }}</h2>
                  <div class="activity-card-detail">
                    {{ activity.configTitle }} · ID {{ activity.id }}<span v-if="activity.subType !== undefined"> · SubType {{ activity.subType }}</span>
                  </div>
                  <div v-if="getBossLinkedRechargeActivityNotice(activity.configId, activity.id)" class="small activity-card-detail">
                    {{ getBossLinkedRechargeActivityNotice(activity.configId, activity.id) }}
                  </div>
                  <div v-if="activity.giftType !== undefined" class="d-flex flex-wrap align-items-center gap-1 mt-1">
                    <span class="badge text-bg-light text-dark">GiftType {{ activity.giftType }}</span>
                    <span v-if="activity.giftTypeLabel" class="activity-card-detail">{{ activity.giftTypeLabel }}</span>
                  </div>
                </div>
                <NuxtLink :to="'/activities/' + activity.id" class="btn btn-sm btn-light activity-card-manage">
                  จัดการ
                </NuxtLink>
              </div>
            </div>
          </div>
          <ActivityLinkedPreviews :activities="bossFollowersFor(activity)" />
        </article>
      </div>
    </div>
  </section>
</template>

<style scoped>
.activity-card-media {
  position: relative;
  overflow: hidden;
  border-radius: var(--bs-card-inner-border-radius);
  background-color: var(--bs-tertiary-bg);
}

.activity-card-image {
  display: block;
  width: 100%;
  height: auto;
  object-fit: contain;
  background-color: var(--bs-tertiary-bg);
}

.activity-card-media--empty {
  min-height: 180px;
}

.activity-card-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  gap: .5rem;
  padding: .75rem;
  color: #fff;
  background: linear-gradient(180deg, rgba(0, 0, 0, .62) 0%, rgba(0, 0, 0, .08) 38%, rgba(0, 0, 0, .76) 100%);
}

.activity-card-overlay-top {
  display: flex;
  justify-content: flex-end;
  align-items: flex-start;
}

.activity-card-toggle {
  padding: .25rem .55rem;
  border-radius: .5rem;
  color: #fff;
  background: rgba(0, 0, 0, .72);
}

.activity-card-toggle .form-check-input {
  float: none;
  margin-left: 0;
  margin-right: .35rem;
}

.activity-card-toggle .form-check-label {
  font-size: .8rem;
}

.activity-card-overlay-bottom {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: .75rem;
  min-width: 0;
}

.activity-card-meta {
  min-width: 0;
  flex: 1;
  text-shadow: 0 1px 3px rgba(0, 0, 0, .9);
}

.activity-card-title {
  display: -webkit-box;
  overflow: hidden;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  font-size: .95rem;
  font-weight: 700;
}

.activity-card-detail {
  color: rgba(255, 255, 255, .92);
  font-size: .75rem;
}

.activity-card-manage {
  flex: 0 0 auto;
}

.activity-detail-image-wrap {
  background-color: var(--bs-tertiary-bg);
}

.activity-detail-image {
  display: block;
  width: 100%;
  height: auto;
  object-fit: contain;
}
</style>