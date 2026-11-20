<script setup lang="ts">
import { computed, ref } from 'vue'
import type { CardDefinition } from '~/utils/code-card'
import { ARCHIVE_PAGE_SIZE } from '~/utils/code-card-archive'

type Asset = { id: string; name: string; iconUrl: string; portraitUrl?: string; backgroundUrl?: string; frameUrl?: string; star?: number; elementIds?: string[] }
type Catalog = { heroes: Asset[]; weapons: Asset[]; equipment: Asset[]; rings: Asset[]; ringElements?: Asset[]; ringFrames?: Array<{ minYear: number; maxYear: number; frameUrl: string }> }
type Issued = { id: string; code: string; status: string; definition: CardDefinition; previewDefinition?: CardDefinition; redeemedUid?: number; redeemedAt?: string }
type ArchivePage = { page: number; total: number; cards: Issued[] }

const { data: catalog, error: catalogError } = await useFetch<Catalog>('/api/code-cards/catalog')
const currentPage = ref(1)
const { data: archive, status, error: archiveError, refresh: reloadArchive } = await useFetch<ArchivePage>('/api/code-cards/archive', {
  query: { page: currentPage },
})
const PAGE_SIZE = ARCHIVE_PAGE_SIZE
const pageCount = computed(() => Math.max(1, Math.ceil((archive.value?.total ?? 0) / PAGE_SIZE)))
const visibleCards = computed(() => archive.value?.cards ?? [])
const busy = computed(() => status.value === 'pending')
const failure = computed(() => archiveError.value?.data?.statusMessage || archiveError.value?.message || '')

function exportCsv() {
  if (!visibleCards.value.length) return
  const quote = (value: unknown) => '"' + String(value ?? '').replaceAll('"','""') + '"'
  const rows = [['code','status','redeemed_uid','redeemed_at'], ...visibleCards.value.map(c => [c.code,c.status,c.redeemedUid,c.redeemedAt])]
  const blob = new Blob(['\uFEFF' + rows.map(r => r.map(quote).join(',')).join('\r\n')], { type:'text/csv;charset=utf-8' })
  const url=URL.createObjectURL(blob)
  const a=document.createElement('a'); a.href=url; a.download='code-cards-page-'+currentPage.value+'.csv'; a.click()
  setTimeout(() => URL.revokeObjectURL(url), 0)
}
</script>
<template>
  <div class="cards-page">
    <header class="page-heading"><div><div class="eyebrow">CHARACTER COLLECTION</div><h1>คลังบัตรและโค้ด</h1><p>ดูบัตรที่เจนแล้วเป็นแผง และดาวน์โหลด PNG แยกแต่ละใบ</p></div></header>
    <nav class="card-tabs" aria-label="เมนูบัตร"><NuxtLink to="/code-cards">เจนโค้ด</NuxtLink><NuxtLink to="/code-cards/templates">สร้างแม่แบบ</NuxtLink><NuxtLink to="/code-cards/archive" aria-current="page">คลังบัตรโค้ด</NuxtLink></nav>
    <div v-if="catalogError" role="alert" class="alert alert-danger">โหลดข้อมูลเกมไม่สำเร็จ</div>
    <div v-if="failure" role="alert" class="alert alert-danger">{{ failure }}</div>
    <section class="history-panel">
      <div class="panel-heading"><h2>บัตรทั้งหมดที่เจนไว้</h2><button class="btn btn-sm btn-outline-light" :disabled="busy" @click="reloadArchive">รีเฟรชสถานะ</button></div>
      <div v-if="archive?.total" class="issued-actions"><button class="btn btn-outline-light btn-sm" :disabled="busy || !visibleCards.length" @click="exportCsv">ส่งออก CSV หน้านี้</button><span>ทั้งหมด {{ archive.total }} ใบ · หน้า {{ currentPage }} / {{ pageCount }}</span></div>
    </section>
    <p v-if="archive?.total" class="archive-preview-note">ภาพจากแม่แบบปัจจุบันจะอัปเดตเมื่อแก้แม่แบบและรีเฟรชคลังบัตร · รางวัลคงตามข้อมูลตอนเจน</p>
    <div v-if="catalog && visibleCards.length" class="card-gallery">
      <CodeCardArchiveItem v-for="card in visibleCards" :key="card.id" :card="card" :catalog="catalog" />
    </div>
    <p v-else-if="!busy && !failure && !archive?.total" class="empty-state">ยังไม่มีบัตรที่เจนไว้</p>
    <nav v-if="pageCount > 1" class="gallery-pagination" aria-label="หน้าคลังบัตร">
      <button type="button" class="btn btn-outline-light btn-sm" :disabled="busy || currentPage <= 1" @click="currentPage--">ก่อนหน้า</button>
      <span>หน้า {{ currentPage }} / {{ pageCount }}</span>
      <button type="button" class="btn btn-outline-light btn-sm" :disabled="busy || currentPage >= pageCount" @click="currentPage++">ถัดไป</button>
    </nav>
  </div>
</template>
<style scoped>
.cards-page { color:#e6edf4; min-width:0; width:100%; max-width:100%; container-type:inline-size; }
.page-heading,.panel-heading { display:flex; justify-content:space-between; align-items:center; gap:16px; flex-wrap:wrap; margin-bottom:18px; min-width:0; }
.page-heading > div { min-width:0; }
h1 { font-size:clamp(1.4rem,3vw,1.8rem); line-height:1.3; margin:8px 0; overflow-wrap:anywhere; }
h2 { font-size:1.12rem; line-height:1.4; margin:0; }
p { color:#9dafc0; margin:0; }
.eyebrow { letter-spacing:.16em; color:#d0b77a; font-size:.76rem; }
.card-tabs { display:flex; gap:8px; flex-wrap:nowrap; overflow-x:auto; max-width:100%; padding:2px 0 10px; margin-bottom:14px; scrollbar-width:thin; overscroll-behavior-x:contain; }
.card-tabs a { flex:0 0 auto; white-space:nowrap; padding:10px 14px; border:1px solid #435668; color:#d7e3ed; border-radius:9px; text-decoration:none; min-height:44px; display:inline-flex; align-items:center; }
.card-tabs a[aria-current="page"] { background:#403820; border-color:#b89948; color:#f8db93; }
.card-tabs a:focus-visible { outline:2px solid #9cd9ff; outline-offset:2px; }
.history-panel { background:#132131; border:1px solid #34465a; border-radius:14px; padding:17px 20px; margin-bottom:20px; min-width:0; }
.panel-heading { margin-bottom:0; }
.panel-heading .btn { min-height:44px; }
.issued-actions { display:flex; align-items:center; gap:12px 16px; flex-wrap:wrap; margin-top:13px; font-size:.85rem; color:#aebccd; min-width:0; }
.issued-actions span { overflow-wrap:anywhere; }
.issued-actions .btn { min-height:44px; }
.archive-preview-note { font-size:.82rem; margin:0 0 14px; color:#aebccd; }
.card-gallery { display:grid; grid-template-columns:repeat(auto-fit,minmax(min(100%,320px),1fr)); gap:clamp(12px,2vw,18px); align-items:start; min-width:0; }
.gallery-pagination { display:flex; justify-content:center; align-items:center; gap:12px; min-width:0; padding:24px 0; color:#cad8e4; }
.gallery-pagination span { text-align:center; min-width:0; }
.gallery-pagination .btn { min-height:44px; white-space:nowrap; }
.empty-state { text-align:center; padding:45px 15px; background:#152638; border:1px dashed #41566b; border-radius:12px; }
@container (max-width:560px) {
  .panel-heading { flex-direction:column; align-items:stretch; gap:12px; }
  .panel-heading .btn { width:100%; }
  .issued-actions { flex-direction:column; align-items:stretch; gap:10px; }
  .issued-actions .btn { width:100%; }
  .gallery-pagination { display:grid; grid-template-columns:minmax(0,1fr) auto minmax(0,1fr); gap:8px; }
  .gallery-pagination .btn { width:100%; padding-inline:8px; }
}
@media (max-width:480px) {
  .history-panel { padding:14px; border-radius:12px; margin-bottom:14px; }
  .card-tabs { gap:6px; }
  .card-tabs a { padding-inline:12px; font-size:.9rem; }
  .gallery-pagination { padding:18px 0; font-size:.9rem; }
}
</style>
