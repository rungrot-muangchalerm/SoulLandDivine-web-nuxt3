import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync, existsSync } from 'node:fs'
const read = name => readFileSync(new URL('../' + name, import.meta.url), 'utf8')
test('three distinct routes separate issuance, editing and archival', () => {
  const generator=read('pages/code-cards/index.vue')
  const editor=read('pages/code-cards/templates.vue')
  const archive=read('pages/code-cards/archive.vue')
  assert.match(generator, /\/api\/code-cards\/batches/)
  assert.doesNotMatch(generator, /\/api\/code-cards\/templates['"],?\s*\{\s*method:\s*['"]POST/)
  assert.match(editor, /async function save\(/)
  assert.doesNotMatch(editor, /class="generate-panel"/)
  assert.match(archive, /\/api\/code-cards\/cards/)
  assert.match(archive, /exportCsv/)
})
test('sidebar navigation and card layout keep original right-aligned code area', () => {
  const menu=read('components/AdminSidebarMenu.vue')
  for(const path of ['/code-cards','/code-cards/templates','/code-cards/archive']) assert.ok(menu.includes("path: '"+path+"'"))
  const preview=read('components/CodeCardPreview.vue')
  assert.ok(preview.includes('box(490, 535, 815, 100'))
  assert.ok(preview.includes("text(props.code || 'XXXX-XXXX-XXXX', 898, 579"))
})

test('code-card pages are sibling routes and not a nested parent layout', () => {
  assert.equal(existsSync(new URL('../pages/code-cards.vue', import.meta.url)), false)
  for (const page of ['index', 'templates', 'archive']) {
    assert.equal(existsSync(new URL(`../pages/code-cards/${page}.vue`, import.meta.url)), true)
  }
})
test('template editor filters all four wearables by hero Job and repairs incompatible selections', () => {
  const source = read('pages/code-cards/templates.vue')
  assert.match(source, /matchesHeroEquipmentJob\(heroJob, x\.job\)/)
  assert.match(source, /watch\(\(\) => draft\.value\.heroId/)
  assert.match(source, /function reconcileEquipment\(/)
  assert.match(source, /reconcileEquipment\(\)/)
  const api = read('server/utils/code-cards.ts')
  assert.match(api, /matchesHeroEquipmentJob\(hero\.job, equipment\.job\)/)
})

test('template editor never asks for equipment star and canvas derives it from item metadata', () => {
  const editor = read('pages/code-cards/templates.vue')
  assert.doesNotMatch(editor, /v-model\\.number="slot\\.stars"/)
  assert.match(editor, /normalizeCardEquipmentStars/)
  const preview = read('components/CodeCardPreview.vue')
  assert.match(preview, /star/)
  assert.doesNotMatch(preview, /repeat\(card\.equipment\[i\]\.stars\)/)
  const server = read('server/utils/code-cards.ts')
  assert.match(server, /normalizeCardEquipmentStars/)
})

test('ring element symbols come from client SoulRingElement_Text and are displayed by ring without implying redeemed effects', () => {
  const catalog = JSON.parse(read('data/code-card-catalog.json'))
  assert.equal(catalog.ringElements.length, 19)
  assert.ok(catalog.ringElements.every(x => x.id && x.name && x.iconUrl))
  const example = catalog.rings.find(x => x.id === '111001')
  assert.deepEqual(example.elementIds, ['6','7','13'])
  const editor = read('pages/code-cards/templates.vue')
  assert.match(editor, /ringElementOptions\(ring\)/)
  assert.match(editor, /element\.iconUrl/)
  const preview = read('components/CodeCardPreview.vue')
  assert.match(preview, /ringElementImages/)
})

test('ring element choices show only original icons without visible captions', () => {
  const editor = read('pages/code-cards/templates.vue')
  assert.match(editor, /:src="element.iconUrl"/)
  assert.doesNotMatch(editor, /<span>{{ element.name }}<\/span>/)
  assert.doesNotMatch(editor, /class="ring-elements-label"/)
  assert.doesNotMatch(editor, /<p class="config-note">ไอคอนแสดงออฟธาตุ/)
})

test('each soul ring symbol is an icon-only selectable button with persistent active state', () => {
  const editor = read('pages/code-cards/templates.vue')
  assert.match(editor, /<button[^>]*v-for="element in ringElementOptions\(ring\)"/)
  assert.match(editor, /@click="selectRingElement\(ring, element.id\)"/)
  assert.match(editor, /:aria-pressed="ring.elementId === element.id"/)
  assert.doesNotMatch(editor, /<span>{{ element.name }}<\/span>/)
  assert.doesNotMatch(editor, /class="ring-elements-label"/)
  assert.doesNotMatch(editor, /<p class="config-note">ไอคอนแสดงออฟธาตุ/)
  assert.match(editor, /function reconcileRingElements/)
  const preview = read('components/CodeCardPreview.vue')
  assert.match(preview, /ring\.elementId/)
  const api = read('server/utils/code-cards.ts')
  assert.match(api, /elementIds\?\.includes\(ring\.elementId\)/)
})

test('card composition centers enlarged selected element over each ring and raises code box', () => {
  const preview = read('components/CodeCardPreview.vue')
  assert.match(preview, /const elementIconSize = 50/)
  assert.match(preview, /fit\(img, center - elementIconSize \/ 2, 640, elementIconSize, elementIconSize\)/)
  assert.match(preview, /box\(490, 535, 815, 100/)
  assert.match(preview, /898, 579, 32/)
  assert.match(preview, /898, 613, 18/)
  assert.doesNotMatch(preview, /center - 32 \+ j \* 24/)
  const editor=read('pages/code-cards/templates.vue')
  assert.match(editor, /\.preview-panel\s*\{[^}]*padding-bottom:\s*1rem/)
})

test('ring dropdown follows HuntingBase dungeon acquisition order before other rings', () => {
  const catalog = JSON.parse(read('data/code-card-catalog.json'))
  assert.equal(catalog.rings.length, 50)
  assert.deepEqual(catalog.rings.slice(0, 5).map(r => r.id), [
    '111006', '111025', '111024', '111004', '111014'
  ])
  const primary = catalog.rings.filter(x => x.isDungeonRing)
  assert.equal(primary.length, 30)
  assert.deepEqual(primary.map(r => r.huntingBaseId), Array.from({length: 30}, (_, i) => i + 1))
  assert.deepEqual(catalog.rings.slice(30).map(r => r.huntingBaseId),
    catalog.rings.slice(30).map(r => r.huntingBaseId).toSorted((a,b) => a - b))
  assert.ok(catalog.rings.slice(30).every(r => !r.isDungeonRing))
})
test('ring options display the localized ring name without raw item IDs', () => {
  const source = read('pages/code-cards/templates.vue')
  const ringEditor = source.split('<details open><summary>วงแหวนวิญญาณ')[1].split('</details>')[0]
  assert.match(ringEditor, /v-for="x in options\(sortedRingOptions\)"/)
  assert.match(ringEditor, /{{ x\.name }}<\/option>/)
  assert.doesNotMatch(ringEditor, /{{ x\.id }}/)
})

test('archive is a paged responsive card gallery, not a full-width single preview table', () => {
  const source = read('pages/code-cards/archive.vue')
  assert.match(source, /class="card-gallery"/)
  assert.match(source, /v-for="card in visibleCards"/)
  assert.match(source, /<CodeCardArchiveItem/)
  assert.match(source, /const PAGE_SIZE = 12/)
  assert.match(source, /issued\.value\.slice\(/)
  assert.doesNotMatch(source, /class="code-table"/)
  assert.doesNotMatch(source, /class="preview-panel"/)
  assert.match(source, /grid-template-columns:\s*repeat\(3/)
  assert.match(source, /@click="exportCsv"/)
})
test('each archived code uses its own real canvas and per-card PNG download', () => {
  const source = read('components/CodeCardArchiveItem.vue')
  assert.match(source, /<CodeCardPreview/)
  assert.match(source, /:definition="card.definition"/)
  assert.match(source, /:code="card.code"/)
  assert.match(source, /@click="downloadCard"/)
  assert.match(source, /preview\.value\?\.download\(\)/)
  assert.match(source, /card\.status === 'used'/)
})

test('template hero selector offers only game-defined SSR (Quality 2), preserving existing saved selections', () => {
  const catalog = JSON.parse(read('data/code-card-catalog.json'))
  assert.equal(catalog.heroes.find(h => h.id === '23')?.quality, 2)
  assert.equal(catalog.heroes.find(h => h.id === '21023')?.quality, 2)
  assert.equal(catalog.heroes.find(h => h.id === '93')?.quality, null)
  assert.ok(catalog.heroes.some(h => h.quality !== 2))
  const source = read('pages/code-cards/templates.vue')
  assert.match(source, /const ssrHeroOptions = computed\(/)
  assert.match(source, /x\.quality === 2/)
  assert.match(source, /v-for="x in ssrHeroOptions"/)
  assert.match(source, /x\.id === draft\.value\.heroId/)
})

test('portrait catalog uses regular character art, never god-awakened alternate art', () => {
  const catalog = JSON.parse(read('data/code-card-catalog.json'))
  const hero = id => catalog.heroes.find(h => h.id === id)
  assert.ok(hero('23')?.portraitUrl?.endsWith('/God_daimubai.png'))
  assert.ok(hero('21023')?.portraitUrl?.endsWith('/God_daimubai.png'))
  assert.ok(hero('22023')?.portraitUrl?.endsWith('/God_daimubai.png'))
  assert.ok(hero('22021')?.portraitUrl?.endsWith('/God_tangsan.png'))
  assert.ok(hero('22029')?.portraitUrl?.endsWith('/God_bosaixi.png'))
  assert.ok(catalog.heroes.every(h => !/_haishen|_zhanshen|_tianshishen|_shishen/.test(h.portraitUrl ?? '')))
  const generator = read('scripts/build-code-card-catalog.py')
  assert.match(generator, /normal_portraits_by_name/)
  assert.doesNotMatch(generator, /portrait=copy\(CLIENT\/'Resources\/UI\/Texture\/HeroGodCard'\/\(god\.get/)
})
