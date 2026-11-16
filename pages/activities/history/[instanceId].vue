<script setup lang="ts">
interface PlayerProgress {
  uid: number
  period: number
  score: number
  seedInfo: string
  scoreReward: string
  updatedAt?: string
}
interface GardenRank {
  groupId: number
  uid: number
  ranking: number
  score: number
  emailId: number | null
  emailDispatchedAt: string | null
}
interface GardenHistoryDetail {
  instanceId: string
  period: number
  legacy: boolean
  attribution: string
  lifecycle: {
    activityRowId: number
    state: string
    startsAt: string
    endsAt: string
    closedAt: string | null
    archivedAt: string | null
  } | null
  progress: PlayerProgress[]
  ranks: GardenRank[]
}
const route = useRoute()
const instanceId = computed(() => String(route.params.instanceId || ''))
const { data, pending, error, refresh } = await useFetch<GardenHistoryDetail>(
  () => `/api/activities/history/garden/${encodeURIComponent(instanceId.value)}`,
  { server: false },
)
const number = (value: number) => new Intl.NumberFormat('th-TH').format(value)
</script>

<template>
  <main class="container-fluid py-4 px-3 px-lg-5">
    <header class="d-flex flex-wrap align-items-center justify-content-between gap-3 mb-4">
      <div>
        <NuxtLink to="/activities/history" class="text-decoration-none small">กลับไปประวัติกิจกรรม</NuxtLink>
        <h1 class="h3 mt-2 mb-1">ประวัติ Garden — Period {{ data?.period || '—' }}</h1>
        <p class="font-monospace small text-secondary mb-0">{{ instanceId }}</p>
      </div>
      <button class="btn btn-outline-secondary" :disabled="pending" @click="refresh()">รีเฟรช</button>
    </header>

    <p v-if="pending" class="text-secondary">กำลังโหลดรายละเอียด…</p>
    <div v-else-if="error" class="alert alert-warning">อ่านประวัติไม่สำเร็จ กรุณาตรวจสอบสิทธิ์และการเชื่อมต่อฐานข้อมูล</div>
    <template v-else-if="data">
      <div v-if="data.legacy" class="alert alert-warning">
        นี่คือข้อมูลเก่า (Legacy) ที่ไม่มี Instance ID ไม่สามารถยืนยันได้ว่าเป็นข้อมูลของการจัดกิจกรรมรอบใด จึงเก็บแยกไว้
      </div>
      <div v-else class="card card-body mb-4">
        <p class="mb-1"><strong>สถานะรอบ:</strong> {{ data.lifecycle?.state || 'ยังไม่มีข้อมูลปิดรอบ' }}</p>
        <p class="mb-1"><strong>เริ่ม:</strong> {{ data.lifecycle?.startsAt || '—' }} <strong class="ms-3">สิ้นสุด:</strong> {{ data.lifecycle?.endsAt || '—' }}</p>
        <p class="mb-0"><strong>เก็บประวัติ:</strong> {{ data.lifecycle?.archivedAt || 'ยังไม่บันทึกสถานะ Archive' }}</p>
      </div>

      <section class="card mb-4">
        <div class="card-header"><h2 class="h5 mb-0">ข้อมูลผู้เล่น ({{ number(data.progress.length) }} รายการที่แสดง)</h2></div>
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0">
            <thead><tr><th>UID</th><th class="text-end">คะแนน</th><th>ต้นไม้ / Stage</th><th>รางวัลคะแนนที่รับ</th><th>แก้ไขล่าสุด</th></tr></thead>
            <tbody>
              <tr v-for="item in data.progress" :key="item.uid">
                <td>{{ item.uid }}</td>
                <td class="text-end">{{ number(item.score) }}</td>
                <td class="small text-break">{{ item.seedInfo || '—' }}</td>
                <td class="small">{{ item.scoreReward || '—' }}</td>
                <td class="small">{{ item.updatedAt || '—' }}</td>
              </tr>
              <tr v-if="!data.progress.length"><td colspan="5" class="text-center text-secondary py-3">ยังไม่มีความคืบหน้าในรอบนี้</td></tr>
            </tbody>
          </table>
        </div>
      </section>

      <section v-if="!data.legacy" class="card">
        <div class="card-header"><h2 class="h5 mb-0">ประวัติอันดับและการส่งรางวัล</h2></div>
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0">
            <thead><tr><th>กลุ่ม</th><th>อันดับ</th><th>UID</th><th class="text-end">คะแนน</th><th>Email ID</th><th>ส่งรางวัลเมื่อ</th></tr></thead>
            <tbody>
              <tr v-for="item in data.ranks" :key="`${item.groupId}-${item.uid}`">
                <td>{{ item.groupId }}</td><td>{{ item.ranking }}</td><td>{{ item.uid }}</td>
                <td class="text-end">{{ number(item.score) }}</td>
                <td>{{ item.emailId || '—' }}</td><td>{{ item.emailDispatchedAt || 'ยังไม่ยืนยัน' }}</td>
              </tr>
              <tr v-if="!data.ranks.length"><td colspan="6" class="text-center text-secondary py-3">ยังไม่มีผลอันดับที่บันทึกในฐานข้อมูล</td></tr>
            </tbody>
          </table>
        </div>
      </section>
    </template>
  </main>
</template>
