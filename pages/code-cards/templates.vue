<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { createCardRequestId } from '~/utils/code-card-request-id'
import { CARD_TALENTS, matchesHeroEquipmentJob, normalizeCardEquipmentStars, cloneCardDefinition, sortDungeonRings, type CardDefinition } from '~/utils/code-card'
type Asset = { id: string; name: string; iconUrl: string; portraitUrl?: string; rewardType: string; effect?: string; slot?: string; job?: number | null; star?: number; quality?: number | null; elementIds?: string[]; description?: string }
type Catalog = { heroes: Asset[]; weapons: Asset[]; equipment: Asset[]; rings: Asset[]; ringElements: Asset[]; boneAffixes: Asset[]; ringFrames?: Array<{ minYear: number; maxYear: number; frameUrl: string }> }
type Template = { id: string; name: string; definition: CardDefinition }
type Issued = { id: string; code: string; status: string; definition: CardDefinition; redeemedUid?: number; redeemedAt?: string }
const { data: catalog, error: catalogError } = await useFetch<Catalog>('/api/code-cards/catalog')
const { data: templates, refresh: reloadTemplates } = await useFetch<Template[]>('/api/code-cards/templates')
const { data: batches, refresh: reloadBatches } = await useFetch<Array<{ id: string; name: string; quantity: number; used: number; created_at: string }>>('/api/code-cards/batches')
function blank(): CardDefinition { return { name: '', heroId: '', talent: '', talentValue: 0, boneAffixes: [], equipment: Array.from({ length: 5 }, () => ({ id: '', stars: 0, level: 0 })), rings: Array.from({ length: 10 }, () => ({ id: '', year: 0 })) } }
const draft = ref<CardDefinition>(blank())
const templateId = ref('')
const batchId = ref('')
const quantity = ref(1)
let pendingGeneration: { requestId: string; templateId: string; quantity: number } | undefined
const issued = ref<Issued[]>([])
const selectedCodeId = ref('')
const selected = computed(() => issued.value.find(x => x.id === selectedCodeId.value))
const previewCard = computed(() => catalog.value ? normalizeCardEquipmentStars(draft.value, catalog.value.equipment) : draft.value)
const busy = ref(false)
const message = ref('')
const failure = ref('')
const search = ref('')
const affixText = ref(draft.value.boneAffixes.join('\n'))
const autoSaveStatus = ref('')
const lastSavedTemplate = ref<{ id: string; json: string } | null>(null)
const definitionJson = computed(() => JSON.stringify(previewCard.value))
let autoSaveTimer: ReturnType<typeof setTimeout> | undefined
let saveQueue: Promise<void> = Promise.resolve()
function queueAutosave(id: string, json: string) {
  saveQueue = saveQueue.catch(() => {}).then(async () => {
    if (templateId.value !== id || definitionJson.value !== json) return
    autoSaveStatus.value = 'กำลังบันทึกการเปลี่ยนแปลง…'
    try {
      await $fetch('/api/code-cards/templates', { method: 'POST', body: { id, definition: JSON.parse(json) } })
      if (templateId.value !== id) return
      lastSavedTemplate.value = { id, json }
      await reloadTemplates()
      autoSaveStatus.value = definitionJson.value === json ? 'บันทึกการเปลี่ยนแปลงแล้ว' : 'มีการแก้ไขเพิ่มเติม'
    } catch (error: any) {
      if (templateId.value === id) {
        autoSaveStatus.value = 'บันทึกอัตโนมัติไม่สำเร็จ กรุณากดบันทึกแม่แบบอีกครั้ง'
        failure.value = error?.data?.statusMessage || error?.message || 'ไม่สามารถอัปเดตแม่แบบได้'
      }
    }
  })
}
watch(definitionJson, json => {
  pendingGeneration = undefined
  if (autoSaveTimer) clearTimeout(autoSaveTimer)
  const id = templateId.value
  if (!id || lastSavedTemplate.value?.id !== id || lastSavedTemplate.value.json === json) return
  if (!draft.value.name.trim()) {
    autoSaveStatus.value = 'ต้องระบุชื่อแม่แบบก่อนบันทึก'
    return
  }
  autoSaveStatus.value = 'มีการเปลี่ยนแปลงที่ยังไม่ได้บันทึก'
  autoSaveTimer = setTimeout(() => { void queueAutosave(id, json) }, 700)
}, { flush: 'post' })
watch(affixText, value => { draft.value.boneAffixes = value.split('\n').map(x => x.trim()).filter(Boolean) })
function options(items: Asset[]) { const q = search.value.toLowerCase().trim(); return q ? items.filter(x => `${x.name} ${x.id}`.toLowerCase().includes(q)) : items }
const ssrHeroOptions = computed(() => {
  const heroes = catalog.value?.heroes ?? []
  const matching = heroes.filter(x => x.quality === 2 || x.id === draft.value.heroId)
  return options(matching)
})
const selectedHero = computed(() => catalog.value?.heroes.find(x => x.id === draft.value.heroId))
const sortedRingOptions = computed(() => sortDungeonRings(catalog.value?.rings ?? []))
function equipmentOptions(index: number) {
  if (index === 0) return options(catalog.value!.weapons)
  const heroJob = selectedHero.value?.job
  return options(catalog.value!.equipment.filter(x => x.slot === ['neck', 'ring', 'wrist', 'boots'][index - 1] && matchesHeroEquipmentJob(heroJob, x.job)))
}
function reconcileEquipment() {
  if (!catalog.value) return
  let cleared = 0
  for (let index = 1; index < 5; index++) {
    const slot = draft.value.equipment[index]
    if (!slot?.id) continue
    const item = catalog.value.equipment.find(x => x.id === slot.id && x.slot === ['neck', 'ring', 'wrist', 'boots'][index - 1])
    if (!item || !matchesHeroEquipmentJob(selectedHero.value?.job, item.job)) {
      draft.value.equipment[index] = { id: '', stars: 0, level: 0 }
      cleared++
    }
  }
  if (cleared) message.value = 'ล้างอุปกรณ์ที่ไม่ตรง Job ของตัวละคร ' + cleared + ' ช่อง กรุณาเลือกใหม่'
}
watch(() => draft.value.heroId, () => { selectedCodeId.value = ''; reconcileEquipment() })
async function chooseTemplate() {
  if (autoSaveTimer) clearTimeout(autoSaveTimer)
  await saveQueue
  const previous = lastSavedTemplate.value
  const previousJson = definitionJson.value
  if (previous && previous.json !== previousJson && draft.value.name.trim()) {
    try {
      await $fetch('/api/code-cards/templates', { method: 'POST', body: { id: previous.id, definition: JSON.parse(previousJson) } })
      await reloadTemplates()
    } catch (error: any) {
      templateId.value = previous.id
      failure.value = error?.data?.statusMessage || error?.message || 'บันทึกแม่แบบก่อนเปลี่ยนไม่สำเร็จ'
      return
    }
  }
  const value = templates.value?.find(x => x.id === templateId.value)
  draft.value = value ? cloneCardDefinition(value.definition) : blank()
  affixText.value = draft.value.boneAffixes.join('\n')
  selectedCodeId.value = ''; message.value = ''; failure.value = ''; autoSaveStatus.value = ''
  reconcileEquipment()
  lastSavedTemplate.value = value ? { id: value.id, json: definitionJson.value } : null
}
async function task(fn: () => Promise<void>) {
  if (busy.value) return
  busy.value = true; failure.value = ''; message.value = ''
  try { await fn() } catch (error: any) { failure.value = error?.data?.statusMessage || error?.message || 'ดำเนินการไม่สำเร็จ' } finally { busy.value = false }
}
async function save() {
  if (autoSaveTimer) clearTimeout(autoSaveTimer)
  await saveQueue
  const json = definitionJson.value
  const result = await $fetch<{ id: string }>('/api/code-cards/templates', { method: 'POST', body: { id: templateId.value || undefined, definition: JSON.parse(json) } })
  templateId.value = result.id
  lastSavedTemplate.value = { id: result.id, json }
  await reloadTemplates()
  autoSaveStatus.value = 'บันทึกแม่แบบแล้ว'
}
async function generate() {
  await task(async () => {
    await save()
    if (!pendingGeneration || pendingGeneration.templateId !== templateId.value || pendingGeneration.quantity !== quantity.value) pendingGeneration = { requestId: createCardRequestId(), templateId: templateId.value, quantity: quantity.value }
    const result = await $fetch<{ batchId: string }>('/api/code-cards/batches', { method: 'POST', body: pendingGeneration })
    batchId.value = result.batchId; await loadBatch(); await reloadBatches(); pendingGeneration = undefined
    message.value = `เจนสำเร็จ ${issued.value.length} ใบ แต่ละโค้ดใช้ได้ครั้งเดียว`
  })
}
async function loadBatch() {
  issued.value = batchId.value ? await $fetch<Issued[]>('/api/code-cards/cards', { query: { batchId: batchId.value } }) : []
  selectedCodeId.value = issued.value[0]?.id || ''
}
function exportCsv() {
  const quote = (value: unknown) => `"${String(value ?? '').replaceAll('"', '""')}"`
  const rows = [['code', 'status', 'redeemed_uid', 'redeemed_at'], ...issued.value.map(x => [x.code, x.status, x.redeemedUid, x.redeemedAt])]
  const url = URL.createObjectURL(new Blob(['\uFEFF' + rows.map(x => x.map(quote).join(',')).join('\r\n')], { type: 'text/csv;charset=utf-8' }))
  const a = document.createElement('a'); a.href = url; a.download = `codes-${batchId.value}.csv`; a.click(); URL.revokeObjectURL(url)
}
function ringElementOptions(ring: { id: string; year: number }) {
  if (!catalog.value || ring.year < 100000) return []
  const item = catalog.value.rings.find(x => x.id === ring.id)
  return catalog.value.ringElements.filter(element => item?.elementIds?.includes(element.id))
}
function selectRingElement(ring: CardDefinition['rings'][number], elementId: string) {
  if (!ringElementOptions(ring).some(element => element.id === elementId)) return
  ring.elementId = ring.elementId === elementId ? '' : elementId
  selectedCodeId.value = ''
}
function reconcileRingElements() {
  for (const ring of draft.value.rings) {
    if (ring.elementId && !ringElementOptions(ring).some(x => x.id === ring.elementId)) ring.elementId = ''
  }
}
watch(() => draft.value.rings.map(r => [r.id, r.year].join(':')).join('|'), reconcileRingElements)

const slots = ['อาวุธลับ', 'สร้อย', 'แหวน', 'ปลอกแขน', 'รองเท้า']
</script>

<template>
  <div class="cards-page">
    <header class="page-heading"><div><div class="eyebrow">CHARACTER COLLECTION</div><h1>สร้างแม่แบบบัตร</h1><p>จัดตัวละครและไอเทม ก่อนบันทึกเป็นแม่แบบ</p></div></header>
    <nav class="card-tabs" aria-label="เมนูบัตร"><NuxtLink to="/code-cards">เจนโค้ด</NuxtLink><NuxtLink to="/code-cards/templates" aria-current="page">สร้างแม่แบบ</NuxtLink><NuxtLink to="/code-cards/archive">คลังบัตรโค้ด</NuxtLink></nav>
    <div v-if="catalogError" role="alert" class="alert alert-danger">โหลดข้อมูลเกมไม่สำเร็จ</div>
    <div v-if="failure" role="alert" class="alert alert-danger">{{ failure }}</div>
    <div v-if="message" role="status" class="alert alert-success">{{ message }}</div>
    <div v-if="catalog" class="editor-layout">
      <section class="config-panel">
        <h2>สร้างและแก้ไขแม่แบบ</h2>
        <label>แม่แบบ<select v-model="templateId" class="form-select" @change="chooseTemplate"><option value="">สร้างแม่แบบใหม่</option><option v-for="t in templates" :key="t.id" :value="t.id">{{ t.name }}</option></select></label>
        <label>ชื่อแม่แบบ<input v-model="draft.name" maxlength="100" class="form-control" @input="selectedCodeId = ''"></label>
        <label>ค้นหาตัวละคร / ไอเทม<input v-model="search" class="form-control" placeholder="ชื่อ หรือ ID"></label>
        <label>ตัวละคร 1 ตัว<select v-model="draft.heroId" class="form-select" @change="selectedCodeId = ''"><option value="">เลือกตัวละคร</option><option v-for="x in ssrHeroOptions" :key="x.id" :value="x.id">{{ x.name }} · {{ x.id }}</option></select></label><p v-if="selectedHero && !selectedHero.job" role="alert" class="config-note">ยังไม่พบประเภทอาชีพ (Job) ที่ยืนยันได้ของตัวละครนี้ จึงไม่แสดงอุปกรณ์ที่สวมใส่ได้ เพื่อป้องกันการจัดบัตรผิดประเภท</p>
        <div class="two-cols"><label>พรสวรรค์<select v-model="draft.talent" class="form-select" @change="selectedCodeId = ''"><option value="">เลือกพรสวรรค์</option><option v-for="(name, key) in CARD_TALENTS" :key="key" :value="key">{{ name }}</option></select></label><label>แต้ม<input  :value="draft.talentValue || ''" type="number" @input="draft.talentValue = Number(($event.target as HTMLInputElement).value); selectedCodeId = ''" min="0" max="35" class="form-control"></label></div>
        <details open><summary>อาวุธลับและอุปกรณ์ · 5 ชิ้น</summary><div v-for="(slot, i) in draft.equipment" :key="i" class="slot-editor"><label>{{ slots[i] }}<select v-model="slot.id" class="form-select" @change="selectedCodeId = ''"><option value="">เลือก{{ slots[i] }}</option><option v-for="x in equipmentOptions(i)" :key="x.id" :value="x.id">{{ x.name }} · {{ x.id }}</option></select></label><p v-if="i > 0 && slot.id" class="config-note">ดาวตามรหัสอุปกรณ์: {{ catalog.equipment.find(x => x.id === slot.id)?.star ?? 0 }} ดาว</p><label>ระดับเสริมบนบัตร<input  :value="slot.level || ''" type="number" @input="slot.level = Number(($event.target as HTMLInputElement).value); selectedCodeId = ''" min="0" max="100" class="form-control"></label></div></details>
        <details><summary>ออฟกระดูก</summary><label>เพิ่มจากข้อมูลเกม<select class="form-select" @change="affixText += (affixText ? '\n' : '') + ($event.target as HTMLSelectElement).value; selectedCodeId = ''"><option value="">เลือกออฟ</option><option v-for="x in catalog.boneAffixes" :key="x.id" :value="x.effect || x.name">{{ x.name }}</option></select></label><label>ข้อความบนบัตร (สูงสุด 6 บรรทัด)<textarea v-model="affixText" rows="8" maxlength="1200" class="form-control bone-affix-notes" @input="selectedCodeId = ''" /></label></details>
        <details open><summary>วงแหวนวิญญาณ · 10 วง</summary>
          <div v-for="(ring, i) in draft.rings" :key="i" class="ring-entry">
            <div class="ring-editor">
              <label>วง {{ i + 1 }}<select v-model="ring.id" class="form-select" @change="selectedCodeId = ''"><option value="">เลือกสัตว์วิญญาณ</option><option v-for="x in options(sortedRingOptions)" :key="x.id" :value="x.id">{{ x.name }}</option></select></label>
              <label>อายุ (ปี)<input  :value="ring.year || ''" type="number" @input="ring.year = Number(($event.target as HTMLInputElement).value); selectedCodeId = ''" min="1" max="1000000" class="form-control"></label>
            </div>
            <div v-if="ringElementOptions(ring).length" class="ring-elements">

              <div class="ring-element-list">
                <button v-for="element in ringElementOptions(ring)" :key="element.id" type="button" class="ring-element" :class="{ 'ring-element-active': ring.elementId === element.id }" :title="element.description || element.name" :aria-label="element.name" :aria-pressed="ring.elementId === element.id" @click="selectRingElement(ring, element.id)">
                  <img :src="element.iconUrl" alt="" width="32" height="32" loading="lazy">
                </button>
              </div>
            </div>
          </div>

        </details>
        <p class="config-note">พรสวรรค์ ออฟกระดูก ดาว และระดับเสริมเป็นข้อมูลบิลด์บนบัตร รางวัลที่แลกได้คือตัวละคร 1 ตัว อาวุธลับ อุปกรณ์ 4 ชิ้น และวงแหวน 10 วงตามอายุที่เลือก ไม่ปรับสเตตัสตัวละครเดิมอัตโนมัติ</p>
        <p v-if="autoSaveStatus" class="config-note" role="status">{{ autoSaveStatus }}</p>
        <button class="btn btn-outline-light w-100" :disabled="busy" @click="task(async () => { await save(); message = 'บันทึกแม่แบบแล้ว' })">บันทึกแม่แบบ</button>
      </section>
      <section class="preview-panel"><CodeCardPreview download-overlay :definition="previewCard" :catalog="catalog" /></section>
    </div>
  </div>
</template>
<style scoped>
.bone-affix-notes { min-height: 190px; resize: vertical; font-size: 1rem !important; line-height: 1.55; }
.cards-page { color: #e6edf4; } .page-heading,.preview-heading { display:flex; align-items:center; justify-content:space-between; gap:16px; margin-bottom:20px; } h1 { font-size:1.8rem; margin:8px 0; } h2 { font-size:1.12rem; margin:0 0 12px; } p { color:#9dafc0; margin:0; } .eyebrow { letter-spacing:.16em; color:#d0b77a; font-size:.8rem; } .editor-layout { display:grid; grid-template-columns:330px minmax(0,1fr); gap:24px; align-items:start; } .config-panel,.generate-panel,.history-panel { background:#132131; border:1px solid #34465a; border-radius:14px; padding:20px; } .config-panel { max-height:calc(100vh - 160px); overflow:auto; } label { display:block; font-size:.88rem; color:#c3d0de; margin-bottom:12px; } label .form-control,label .form-select { margin-top:6px; font-size:.88rem; } .two-cols { display:grid; grid-template-columns:1fr 1fr; gap:12px; } details { border-top:1px solid #34465a; padding-top:14px; margin-top:12px; } summary { cursor:pointer; margin-bottom:14px; font-size:.95rem; color:#e5ce9c; } .slot-editor { margin-bottom:14px; } .ring-entry { margin-bottom:16px; border-bottom:1px solid #2b4356; padding-bottom:12px; } .ring-elements { margin:0 0 8px; } .ring-elements-label { display:block; color:#b4c9d9; font-size:.76rem; margin-bottom:6px; } .ring-element-list { display:flex; gap:8px; flex-wrap:wrap; } .ring-element { display:flex; align-items:center; gap:4px; font-size:.78rem; color:#d9dce7; background:#102435; padding:4px 5px; border:1px solid #385066; border-radius:7px; } .ring-element img { object-fit:contain; } .ring-element { cursor:pointer; } .ring-element-active { border-color:#f5cb68; background:#42341a; box-shadow:0 0 0 2px #f5cb68; } .ring-element:focus-visible { outline:2px solid #9ddaff; outline-offset:3px; } .ring-editor { display:grid; grid-template-columns:minmax(0,1fr) 92px; gap:10px; } .config-note { font-size:.85rem; line-height:1.65; margin:16px 0; } .preview-panel { min-width:0; padding-bottom:1rem; } .generate-panel { display:flex; gap:20px; align-items:center; margin:24px 0; flex-wrap:wrap; } .generate-panel>div { flex:1; } .generate-panel label { width:90px; margin:0; } .generate-panel h2 { margin-bottom:5px; } .generate-panel p { font-size:.9rem; } .issued-actions { display:flex; align-items:center; gap:16px; margin:16px 0; font-size:.85rem; color:#9dafc0; } .code-table { overflow:auto; max-height:400px; } .code-button { border:0; background:transparent; color:#efd29a; font-family:monospace; white-space:nowrap; padding:8px 0; text-align:left; } .code-button:focus-visible { outline:2px solid #66d2dd; } .empty-state { padding:24px 0; } th { font-size:.9rem; } @media(max-width:1200px) { .editor-layout { grid-template-columns:280px minmax(0,1fr); gap:16px; } } @media(max-width:900px) { .editor-layout { grid-template-columns:1fr; } .config-panel { max-height:none; order:2; } .preview-panel { order:1; } .page-heading { flex-wrap:wrap; } }
.card-tabs { display:flex; gap:10px; flex-wrap:wrap; margin:0 0 18px; } .card-tabs a { padding:10px 16px; border:1px solid #435668; color:#d7e3ed; border-radius:9px; text-decoration:none; } .card-tabs a[aria-current="page"] { background:#403820; border-color:#b89948; color:#f8db93; }
</style>
