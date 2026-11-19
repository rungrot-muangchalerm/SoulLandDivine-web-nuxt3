<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import type { CardDefinition } from '~/utils/code-card'
type Asset = { id: string; name: string; iconUrl: string; portraitUrl?: string; backgroundUrl?: string; frameUrl?: string; star?: number; elementIds?: string[] }
type Catalog = { heroes: Asset[]; weapons: Asset[]; equipment: Asset[]; rings: Asset[]; ringElements?: Asset[]; ringFrames?: Array<{ minYear: number; maxYear: number; frameUrl: string }> }
type Batch = { id: string; name: string; quantity: number; used: number; created_at: string }
type Issued = { id: string; code: string; status: string; definition: CardDefinition; redeemedUid?: number; redeemedAt?: string }
const route = useRoute()
const { data: catalog, error: catalogError } = await useFetch<Catalog>('/api/code-cards/catalog')
const { data: batches, refresh: reloadBatches } = await useFetch<Batch[]>('/api/code-cards/batches')
const batchId = ref(typeof route.query.batchId === 'string' ? route.query.batchId : '')
const issued = ref<Issued[]>([])
const PAGE_SIZE = 12
const currentPage = ref(1)
const pageCount = computed(() => Math.max(1, Math.ceil(issued.value.length / PAGE_SIZE)))
const visibleCards = computed(() => issued.value.slice((currentPage.value - 1) * PAGE_SIZE, currentPage.value * PAGE_SIZE))
const busy = ref(false)
const failure = ref('')
async function loadBatch() {
  if (busy.value) return
  busy.value = true; failure.value = ''
  try {
    issued.value = batchId.value ? await $fetch<Issued[]>('/api/code-cards/cards', { query: { batchId: batchId.value } }) : []
    currentPage.value = 1
  } catch (error: any) {
    issued.value = []; currentPage.value = 1
    failure.value = error?.data?.statusMessage || error?.message || 'โหลดคลังบัตรไม่สำเร็จ'
  } finally { busy.value = false }
}
watch(() => route.query.batchId, value => { if (typeof value === 'string' && value !== batchId.value) { batchId.value = value; void loadBatch() } })
if (batchId.value) await loadBatch()
function exportCsv() {
  if (!issued.value.length) return
  const quote = (value: unknown) => '"' + String(value ?? '').replaceAll('"','""') + '"'
  const rows = [['code','status','redeemed_uid','redeemed_at'], ...issued.value.map(c => [c.code,c.status,c.redeemedUid,c.redeemedAt])]
  const blob = new Blob(['\uFEFF' + rows.map(r => r.map(quote).join(',')).join('\r\n')], { type:'text/csv;charset=utf-8' })
  const url=URL.createObjectURL(blob)
  const a=document.createElement('a'); a.href=url; a.download='code-cards-'+batchId.value+'.csv'; a.click()
  setTimeout(() => URL.revokeObjectURL(url), 0)
}
async function refresh() { await reloadBatches(); await loadBatch() }
</script>
<template>
  <div class="cards-page">
    <header class="page-heading"><div><div class="eyebrow">CHARACTER COLLECTION</div><h1>คลังบัตรและโค้ด</h1><p>ดูบัตรที่เจนแล้วเป็นแผง และดาวน์โหลด PNG แยกแต่ละใบ</p></div></header>
    <nav class="card-tabs" aria-label="เมนูบัตร"><NuxtLink to="/code-cards">เจนโค้ด</NuxtLink><NuxtLink to="/code-cards/templates">สร้างแม่แบบ</NuxtLink><NuxtLink to="/code-cards/archive" aria-current="page">คลังบัตรโค้ด</NuxtLink></nav>
    <div v-if="catalogError" role="alert" class="alert alert-danger">โหลดข้อมูลเกมไม่สำเร็จ</div>
    <div v-if="failure" role="alert" class="alert alert-danger">{{ failure }}</div>
    <section class="history-panel">
      <div class="panel-heading"><h2>ชุดโค้ดที่เจนไว้</h2><button class="btn btn-sm btn-outline-light" :disabled="busy" @click="refresh">รีเฟรชสถานะ</button></div>
      <label>เลือกชุดบัตร<select v-model="batchId" class="form-select" :disabled="busy" @change="loadBatch"><option value="">— เลือกชุดบัตร —</option><option v-for="b in batches" :key="b.id" :value="b.id">{{ b.name }} · {{ b.quantity }} ใบ · ใช้แล้ว {{ b.used }} · {{ new Date(b.created_at).toLocaleString('th-TH') }}</option></select></label>
      <div v-if="issued.length" class="issued-actions"><button class="btn btn-outline-light btn-sm" @click="exportCsv">ส่งออก CSV</button><span>{{ issued.length }} ใบ · หน้า {{ currentPage }} / {{ pageCount }}</span></div>
    </section>
    <div v-if="catalog && visibleCards.length" class="card-gallery">
      <CodeCardArchiveItem v-for="card in visibleCards" :key="card.id" :card="card" :catalog="catalog" />
    </div>
    <p v-else-if="!busy && !issued.length" class="empty-state">เลือกชุดบัตรที่เจนไว้เพื่อดูคลังบัตร</p>
    <nav v-if="issued.length > PAGE_SIZE" class="gallery-pagination" aria-label="หน้าคลังบัตร">
      <button type="button" class="btn btn-outline-light btn-sm" :disabled="currentPage <= 1" @click="currentPage--">ก่อนหน้า</button>
      <span>หน้า {{ currentPage }} / {{ pageCount }}</span>
      <button type="button" class="btn btn-outline-light btn-sm" :disabled="currentPage >= pageCount" @click="currentPage++">ถัดไป</button>
    </nav>
  </div>
</template>
<style scoped>
.cards-page { color:#e6edf4; }
.page-heading,.panel-heading { display:flex; justify-content:space-between; align-items:center; gap:16px; flex-wrap:wrap; margin-bottom:18px; }
h1 { font-size:1.8rem; margin:8px 0; }
h2 { font-size:1.12rem; margin:0; }
p { color:#9dafc0; margin:0; }
.eyebrow { letter-spacing:.16em; color:#d0b77a; font-size:.8rem; }
.card-tabs { display:flex; gap:10px; flex-wrap:wrap; margin-bottom:18px; }
.card-tabs a { padding:10px 16px; border:1px solid #435668; color:#d7e3ed; border-radius:9px; text-decoration:none; }
.card-tabs a[aria-current="page"] { background:#403820; border-color:#b89948; color:#f8db93; }
.history-panel { background:#132131; border:1px solid #34465a; border-radius:14px; padding:17px 20px; margin-bottom:20px; }
label { display:block; color:#c3d0de; font-size:.9rem; }
.form-select { margin-top:8px; }
.issued-actions { display:flex; align-items:center; gap:16px; margin:13px 0 0; font-size:.85rem; color:#aebccd; }
.card-gallery { display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:18px; align-items:start; }
.gallery-pagination { display:flex; justify-content:center; align-items:center; gap:18px; padding:24px 0; color:#cad8e4; }
.empty-state { text-align:center; padding:55px 15px; background:#152638; border:1px dashed #41566b; border-radius:12px; }
@media (max-width:1150px) { .card-gallery { grid-template-columns:repeat(2,minmax(0,1fr)); } }
@media (max-width:700px) { .card-gallery { grid-template-columns:minmax(0,1fr); } .history-panel { padding:14px; } }
</style>
