<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import type { CardDefinition } from '~/utils/code-card'
type Asset = { id: string; name: string; iconUrl: string; portraitUrl?: string; backgroundUrl?: string; frameUrl?: string }
type Catalog = { heroes: Asset[]; weapons: Asset[]; equipment: Asset[]; rings: Asset[]; ringFrames?: Array<{ minYear: number; maxYear: number; frameUrl: string }> }
type Template = { id: string; name: string; definition: CardDefinition }
const { data: catalog, error: catalogError } = await useFetch<Catalog>('/api/code-cards/catalog')
const { data: templates, refresh: reloadTemplates } = await useFetch<Template[]>('/api/code-cards/templates')
const templateId = ref('')
const quantity = ref(1)
const selected = computed(() => templates.value?.find(x => x.id === templateId.value))
const definition = computed(() => selected.value?.definition)
const preview = ref<{ download: () => Promise<void> }>()
const busy = ref(false)
const message = ref('')
const failure = ref('')
const generatedBatch = ref('')
let pending: { requestId: string; templateId: string; quantity: number } | undefined
watch([templateId, quantity], () => { pending = undefined; generatedBatch.value = ''; message.value = '' })
async function generate() {
  if (busy.value || !selected.value) return
  if (!Number.isSafeInteger(quantity.value) || quantity.value < 1 || quantity.value > 200) { failure.value = 'เจนได้ครั้งละ 1–200 ใบ'; return }
  busy.value = true; failure.value = ''; message.value = ''
  try {
    if (!pending || pending.templateId !== templateId.value || pending.quantity !== quantity.value) pending = { requestId: crypto.randomUUID(), templateId: templateId.value, quantity: quantity.value }
    const result = await $fetch<{ batchId: string }>('/api/code-cards/batches', { method: 'POST', body: pending })
    generatedBatch.value = result.batchId
    pending = undefined
    message.value = 'สร้างโค้ด ' + quantity.value + ' ใบสำเร็จแล้ว'
  } catch (error: any) {
    failure.value = error?.data?.statusMessage || error?.message || 'เจนโค้ดไม่สำเร็จ'
  } finally { busy.value = false }
}
</script>
<template>
  <div class="cards-page">
    <header class="page-heading"><div><div class="eyebrow">CHARACTER COLLECTION</div><h1>เจนโค้ดตัวละคร</h1><p>เลือกแม่แบบที่บันทึกไว้ แล้วสร้างโค้ดใช้ได้ครั้งเดียว</p></div><button class="btn btn-outline-light" :disabled="!definition || busy" @click="preview?.download()">ดาวน์โหลดตัวอย่าง PNG</button></header>
    <nav class="card-tabs" aria-label="เมนูบัตร"><NuxtLink to="/code-cards" aria-current="page">เจนโค้ด</NuxtLink><NuxtLink to="/code-cards/templates">สร้างแม่แบบ</NuxtLink><NuxtLink to="/code-cards/archive">คลังบัตรโค้ด</NuxtLink></nav>
    <div v-if="catalogError" role="alert" class="alert alert-danger">โหลดข้อมูลเกมไม่สำเร็จ</div>
    <div v-if="failure" role="alert" class="alert alert-danger">{{ failure }}</div>
    <div v-if="message" role="status" class="alert alert-success">{{ message }} <NuxtLink v-if="generatedBatch" :to="{ path: '/code-cards/archive', query: { batchId: generatedBatch } }">เปิดชุดบัตรในคลัง</NuxtLink></div>
    <div class="editor-layout">
      <section class="config-panel">
        <div class="panel-heading"><h2>เจนจากแม่แบบ</h2><button class="btn btn-sm btn-outline-light" :disabled="busy" @click="reloadTemplates()">รีเฟรชแม่แบบ</button></div>
        <label>เลือกแม่แบบ<select v-model="templateId" class="form-select" :disabled="busy"><option value="">— เลือกแม่แบบที่บันทึกแล้ว —</option><option v-for="item in templates" :key="item.id" :value="item.id">{{ item.name }}</option></select></label>
        <p v-if="!templates?.length" class="hint">ยังไม่มีแม่แบบที่บันทึกไว้ <NuxtLink to="/code-cards/templates">ไปสร้างแม่แบบ</NuxtLink></p>
        <p v-else-if="!selected" class="hint">เลือกแม่แบบเพื่อดูตัวอย่างและเจนโค้ด</p>
        <template v-if="selected">
          <p class="hint">แม่แบบ: {{ selected.name }}</p>
          <label>จำนวนบัตร (1–200)<input v-model.number="quantity" class="form-control" type="number" min="1" max="200" :disabled="busy"></label>
          <p class="hint">ระบบเก็บ Snapshot ของแต่ละชุดบัตร การแก้แม่แบบภายหลังไม่เปลี่ยนรางวัลของโค้ดที่เจนไปแล้ว</p>
          <button class="btn btn-warning w-100" :disabled="busy" @click="generate">{{ busy ? 'กำลังเจน…' : 'เจนโค้ดจากแม่แบบ' }}</button>
        </template>
        <NuxtLink class="editor-link" to="/code-cards/templates">สร้างหรือแก้ไขแม่แบบ</NuxtLink>
        <NuxtLink class="editor-link" to="/code-cards/archive">เปิดคลังบัตรโค้ด</NuxtLink>
      </section>
      <section class="preview-panel"><CodeCardPreview v-if="catalog && definition" ref="preview" :definition="definition" :catalog="catalog"/><div v-else class="empty-preview">เลือกแม่แบบทางซ้ายเพื่อแสดงบัตรตัวอย่าง</div></section>
    </div>
  </div>
</template>
<style scoped>
.cards-page { color:#e6edf4; } .page-heading,.panel-heading { display:flex;justify-content:space-between;align-items:center;gap:16px;flex-wrap:wrap;margin-bottom:20px; } h1 {font-size:1.8rem;margin:8px 0;} h2 {font-size:1.12rem;margin:0;} p {margin:0;} .eyebrow {letter-spacing:.16em;color:#d0b77a;font-size:.8rem;} .editor-layout {display:grid;grid-template-columns:330px minmax(0,1fr);gap:24px;align-items:start;} .config-panel {background:#132131;border:1px solid #34465a;border-radius:14px;padding:20px;} label {display:block;color:#c3d0de;margin:18px 0;font-size:.9rem;} label .form-select,label .form-control {margin-top:8px;} .hint {color:#acbbca;line-height:1.6;margin:14px 0;font-size:.9rem;} .editor-link {display:block;margin:16px 0 0;color:#f0d290;} .preview-panel {min-width:0;} .empty-preview {border:1px dashed #526579;border-radius:14px;min-height:320px;display:grid;place-items:center;color:#a9bdcc;} .card-tabs {display:flex;gap:10px;flex-wrap:wrap;margin:0 0 18px;} .card-tabs a {padding:10px 16px;border:1px solid #435668;color:#d7e3ed;border-radius:9px;text-decoration:none;} .card-tabs a[aria-current="page"] {background:#403820;border-color:#b89948;color:#f8db93;} @media(max-width:900px){.editor-layout {grid-template-columns:1fr;}.page-heading{flex-wrap:wrap;}}
</style>
