<script setup lang="ts">
import { ref, watch, onMounted, onBeforeUnmount } from 'vue'
import type { CardDefinition } from '~/utils/code-card'
import { CARD_TALENTS, cloneCardDefinition } from '~/utils/code-card'
type Asset = { id: string; name: string; iconUrl: string; portraitUrl?: string; backgroundUrl?: string; frameUrl?: string; star?: number; elementIds?: string[] }
const props = defineProps<{ definition: CardDefinition; code?: string; catalog: { heroes: Asset[]; equipment: Asset[]; weapons: Asset[]; rings: Asset[]; ringElements?: Asset[]; ringFrames?: Array<{ minYear: number; maxYear: number; frameUrl: string }> } }>()
const canvas = ref<HTMLCanvasElement>()
let revision = 0
const asset = (list: Asset[], id: string) => list.find(x => x.id === id)
const imageCache = new Map<string, Promise<HTMLImageElement | null>>()
function load(url?: string) {
  if (!url) return Promise.resolve(null)
  if (!imageCache.has(url)) imageCache.set(url, new Promise(resolve => { const img = new Image(); img.onload = () => resolve(img); img.onerror = () => resolve(null); img.src = url }))
  return imageCache.get(url)!
}
async function draw() {
  const current = ++revision
  const c = canvas.value
  if (!c) return
  const card: CardDefinition = cloneCardDefinition(props.definition)
  const hero = asset(props.catalog.heroes, card.heroId)
  const equips = card.equipment.map((x, i) => asset(i ? props.catalog.equipment : props.catalog.weapons, x.id))
  const rings = card.rings.map(x => asset(props.catalog.rings, x.id))
  const ringElements = card.rings.map((ring, i) => ring.year >= 100000 && ring.elementId && rings[i]?.elementIds?.includes(ring.elementId) ? (props.catalog.ringElements || []).filter(element => element.id === ring.elementId) : [])
  const [portrait, equipmentImages, ringImages, ringElementImages] = await Promise.all([
    load(hero?.portraitUrl || hero?.iconUrl),
    Promise.all(equips.map(x => load(x?.iconUrl))),
    Promise.all(rings.map(async (x, i) => ({
      icon: await load(x?.iconUrl),
      bg: await load(x?.backgroundUrl),
      frame: await load(props.catalog.ringFrames?.find(f => card.rings[i].year >= f.minYear && card.rings[i].year <= f.maxYear)?.frameUrl || x?.frameUrl)
    }))),
    Promise.all(ringElements.map(elements => Promise.all(elements.map(element => load(element.iconUrl)))))
  ])
  if (current !== revision) return
  const ctx = c.getContext('2d')!
  ctx.clearRect(0, 0, 1400, 880)
  const bg = ctx.createLinearGradient(0, 0, 1400, 880); bg.addColorStop(0, '#172b3e'); bg.addColorStop(.6, '#0b1725'); bg.addColorStop(1, '#1d3040')
  ctx.fillStyle = bg; ctx.fillRect(0, 0, 1400, 880)
  const box = (x: number, y: number, w: number, h: number, color = '#bfa772', fill = '#0c1a29') => { ctx.fillStyle = fill; ctx.fillRect(x, y, w, h); ctx.strokeStyle = color; ctx.lineWidth = 2; ctx.strokeRect(x, y, w, h) }
  const text = (value: string, x: number, y: number, size = 24, color = '#e8e3d6', align: CanvasTextAlign = 'left', maxWidth?: number) => { ctx.font = `${size >= 30 ? 600 : 400} ${size}px Tahoma, sans-serif`; ctx.fillStyle = color; ctx.textAlign = align; ctx.fillText(value, x, y, maxWidth) }
  const fit = (img: HTMLImageElement | null, x: number, y: number, w: number, h: number) => { if (!img) return; const scale = Math.min(w / img.width, h / img.height); ctx.drawImage(img, x + (w - img.width * scale) / 2, y + (h - img.height * scale) / 2, img.width * scale, img.height * scale) }
  ctx.strokeStyle = '#bfa772'; ctx.lineWidth = 2; ctx.strokeRect(16, 16, 1368, 848); ctx.strokeStyle = '#425567'; ctx.strokeRect(25, 25, 1350, 830)
  box(46, 48, 395, 544, '#52697c', '#102235')
  fit(portrait, 54, 56, 379, 528)
  if (!portrait) text('เลือกตัวละคร', 243, 310, 28, '#91a7ba', 'center')
  text(hero?.name || card.name, 243, 636, 35, '#edce8c', 'center', 390)
  for (let i = 0; i < 5; i++) {
    const x = 490 + i * 169
    box(x, 48, 139, 137, i === 0 ? '#6ecae3' : '#c3a05b')
    fit(equipmentImages[i], x + 9, 53, 121, 116)
    if (!equipmentImages[i]) text(i === 0 ? 'อาวุธลับ' : `อุปกรณ์ ${i}`, x + 69, 123, 18, '#93a8bb', 'center')
    if (card.equipment[i].id && card.equipment[i].level > 0) text(`+${card.equipment[i].level}`, x + 125, 75, 22, '#93dcf1', 'right')
    text('★'.repeat(i === 0 ? 0 : (equips[i]?.star ?? 0)), x + 69, 180, 20, '#edca75', 'center')
  }
  if (card.talent) text(CARD_TALENTS[card.talent], 490, 254, 26)
  ctx.fillStyle = '#253c50'; ctx.fillRect(630, 230, 605, 20)
  const bar = ctx.createLinearGradient(630, 0, 1235, 0); bar.addColorStop(0, '#287fa4'); bar.addColorStop(1, '#64e8c0'); ctx.fillStyle = bar; ctx.fillRect(630, 230, 605 * Math.min(1, card.talentValue / 35), 20)
  if (card.talentValue > 0) text(String(card.talentValue), 1310, 255, 32, '#8ce8d0', 'right')
  text('ออฟกระดูก', 490, 313, 25, '#d5bd88')
  card.boneAffixes.slice(0, 6).forEach((line, i) => text(`• ${line}`, 498, 349 + i * 32, 22, '#c1cdd7', 'left', 797))
  if (card.boneAffixes.length > 6) text(`อีก ${card.boneAffixes.length - 6} ออฟ`, 1305, 515, 17, '#9cafbc', 'right')
  box(490, 535, 815, 100, '#50697b', '#091421')
  text(props.code || 'XXXX-XXXX-XXXX', 898, 579, 32, '#f1d696', 'center', 780)
  text(props.code ? 'โค้ดใช้ได้ครั้งเดียว' : 'ตัวอย่างก่อนเจนโค้ด', 898, 613, 18, '#9cb2c5', 'center')
  ctx.strokeStyle = '#3c5265'; ctx.beginPath(); ctx.moveTo(46, 682); ctx.lineTo(1353, 682); ctx.stroke()
  for (let i = 0; i < 10; i++) {
    const x = 49 + i * 130
    const center = x + 56
    ctx.save(); ctx.beginPath(); ctx.arc(center, 748, 48, 0, Math.PI * 2); ctx.clip()
    ctx.fillStyle = '#172f44'; ctx.fillRect(x + 8, 700, 96, 96)
    fit(ringImages[i].bg, x + 8, 700, 96, 96); fit(ringImages[i].icon, x + 8, 700, 96, 96); ctx.restore()
    ctx.beginPath(); ctx.arc(center, 748, 49, 0, Math.PI * 2); ctx.strokeStyle = card.rings[i].year >= 100000 ? '#f1a5b4' : '#a68cd4'; ctx.lineWidth = 3; ctx.stroke()
    fit(ringImages[i].frame, x + 1, 693, 110, 110)
    // Eligible elemental symbols from the Unity Client; not assigned rewards.
    const elementIconSize = 50
    ringElementImages[i].slice(0, 1).forEach(img => fit(img, center - elementIconSize / 2, 640, elementIconSize, elementIconSize))
    text(rings[i]?.name || `วง ${i + 1}`, center, 822, 15, '#dce1e8', 'center', 122)
    if (card.rings[i].id && card.rings[i].year > 0) text(`${card.rings[i].year.toLocaleString()} ปี`, center, 845, 14, '#b9a4c5', 'center')
  }
}
watch(() => [props.definition, props.code, props.catalog], () => { void draw() }, { deep: true })
onMounted(async () => { await document.fonts.ready; await draw() })
onBeforeUnmount(() => { revision++ })
async function download() {
  await draw()
  const a = document.createElement('a'); a.download = `${props.definition.name}-${props.code || 'preview'}.png`; a.href = canvas.value!.toDataURL('image/png'); a.click()
}
defineExpose({ download })
</script>
<template>
  <canvas ref="canvas" width="1400" height="880" class="code-card-canvas" role="img" :aria-label="`${definition.name} ${CARD_TALENTS[definition.talent]} ${definition.talentValue} อุปกรณ์ 5 ชิ้น วงแหวน 10 วง ${code || 'ตัวอย่าง'}`" />
</template>
<style scoped>
.code-card-canvas { width: 100%; height: auto; display: block; border-radius: 14px; box-shadow: 0 20px 55px #0005; }
@media print { .code-card-canvas { border-radius: 0; box-shadow: none; max-height: 95vh; object-fit: contain; } }
</style>
