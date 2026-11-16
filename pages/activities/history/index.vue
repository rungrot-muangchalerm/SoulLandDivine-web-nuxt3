<script setup lang="ts">
type GardenHistoryItem = {
  instanceId: string
  period: number
  state?: string
  activityRowId?: number | null
  archivedAt?: string | null
  firstSeen: string
  lastChanged: string
  players: number
  totalScore: number
  topScore: number
  ranks: number
  emails: number
}
type LegacyItem = {
  period: number
  state?: string
  activityRowId?: number | null
  archivedAt?: string | null
  players: number
  totalScore: number
  topScore: number
  nonEmptySeeds: number
  claimedRewards: number
}

const { data, pending, error, refresh } = await useFetch<{
  instances: GardenHistoryItem[]
  legacy: LegacyItem[]
}>('/api/activities/history/garden', { server: false })
const number = (value: number) => new Intl.NumberFormat('th-TH').format(value)
</script>

<template>
  <main class="container-fluid py-4 px-3 px-lg-5">
    <header class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
      <div>
        <NuxtLink to="/activities" class="small text-decoration-none">กลับไปหน้าจัดการกิจกรรม</NuxtLink>
        <h1 class="h3 mt-2 mb-1">ประวัติกิจกรรม Garden</h1>
        <p class="text-secondary mb-0">แต่ละรอบใช้ Instance ID ของตัวเอง เก็บคะแนนและรางวัลโดยไม่รวมกับรอบใหม่</p>
      </div>
      <button class="btn btn-outline-secondary" :disabled="pending" @click="refresh()">รีเฟรชข้อมูล</button>
    </header>

    <p v-if="pending" class="text-secondary">กำลังโหลดข้อมูลประวัติ…</p>
    <div v-else-if="error" class="alert alert-warning" role="alert">
      อ่านประวัติไม่สำเร็จ โปรดตรวจสอบสิทธิ์ Admin และการเชื่อมต่อฐานข้อมูลเกม
    </div>
    <template v-else>
      <section class="card mb-4">
        <div class="card-header">
          <h2 class="h5 mb-0">รอบที่มี Instance ID</h2>
        </div>
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0">
            <thead>
              <tr>
                <th>Period</th>
                <th>Instance ID</th>
                <th>สถานะ</th>
                <th>พบข้อมูลครั้งแรก</th>
                <th>แก้ไขล่าสุด</th>
                <th class="text-end">ผู้เล่น</th>
                <th class="text-end">คะแนนรวม</th>
                <th class="text-end">อันดับบันทึก</th>
                <th class="text-end">เมลรางวัล</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in data?.instances || []" :key="item.instanceId">
                <td>{{ item.period }}</td>
                <td><NuxtLink :to="`/activities/history/${item.instanceId}`" class="font-monospace small">{{ item.instanceId }}</NuxtLink></td>
                <td>{{ item.state === 'archived' ? 'เก็บประวัติแล้ว' : item.state === 'closing' ? 'กำลังปิดรอบ' : 'กำลังดำเนินการ' }}</td>
                <td>{{ item.firstSeen || '—' }}</td>
                <td>{{ item.lastChanged || '—' }}</td>
                <td class="text-end">{{ number(item.players) }}</td>
                <td class="text-end">{{ number(item.totalScore) }}</td>
                <td class="text-end">{{ number(item.ranks) }}</td>
                <td class="text-end">{{ number(item.emails) }}</td>
              </tr>
              <tr v-if="!data?.instances.length"><td colspan="9" class="text-center text-secondary py-4">ยังไม่มีรอบใหม่ที่บันทึกด้วย Instance ID</td></tr>
            </tbody>
          </table>
        </div>
      </section>

      <section class="card">
        <div class="card-header">
          <h2 class="h5 mb-0">ข้อมูลเก่า (Legacy — ไม่ทราบรอบที่แน่นอน)</h2>
        </div>
        <div class="card-body pb-0">
          <p class="text-secondary small">
            ข้อมูลในตารางเดิมไม่มี Instance ID จึงไม่อ้างว่าเป็นของรอบใดโดยเฉพาะ และจะไม่ถูกย้ายหรือเคลียร์อัตโนมัติ
          </p>
        </div>
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0">
            <thead><tr><th>Period เดิม</th><th class="text-end">ผู้เล่น</th><th class="text-end">คะแนนรวม</th><th class="text-end">ผู้เล่นมีต้นไม้</th><th class="text-end">ผู้เล่นเคยรับรางวัล</th><th>รายละเอียด</th></tr></thead>
            <tbody>
              <tr v-for="item in data?.legacy || []" :key="item.period">
                <td>{{ item.period }}</td>
                <td class="text-end">{{ number(item.players) }}</td>
                <td class="text-end">{{ number(item.totalScore) }}</td>
                <td class="text-end">{{ number(item.nonEmptySeeds) }}</td>
                <td class="text-end">{{ number(item.claimedRewards) }}</td>
                <td><NuxtLink :to="`/activities/history/legacy-${item.period}`">ดูข้อมูลที่เก็บไว้</NuxtLink></td>
              </tr>
              <tr v-if="!data?.legacy.length"><td colspan="6" class="text-center text-secondary py-3">ไม่มีข้อมูลเก่า</td></tr>
            </tbody>
          </table>
        </div>
      </section>
    </template>
  </main>
</template>
