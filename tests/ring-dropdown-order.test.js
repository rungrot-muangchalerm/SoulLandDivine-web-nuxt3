import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import { sortDungeonRings } from '../utils/code-card.ts'

const rings = JSON.parse(readFileSync(new URL('../data/code-card-catalog.json', import.meta.url))).rings

test('dungeon rings always appear in HuntingBase dungeon order even if API order is shuffled', () => {
  const shuffled = [...rings].reverse()
  const sorted = sortDungeonRings(shuffled)
  assert.equal(sorted.length, rings.length)
  assert.deepEqual(sorted.filter(r => r.isDungeonRing).map(r => r.huntingBaseId), Array.from({ length: 30 }, (_, i) => i + 1))
  assert.ok(sorted.slice(30).every(r => !r.isDungeonRing))
  assert.equal(sorted[0].id, '111006')
  assert.equal(sorted[29].id, '111011')
  assert.deepEqual(shuffled.map(r => r.id), [...rings].reverse().map(r => r.id), 'source list is not mutated')
})

test('non-dungeon rings sort after dungeon rings with stable fallback ordering', () => {
  const sample = [
    { id: '111999', name: 'special', huntingBaseId: 1, isDungeonRing: false },
    { id: '111025', name: 'dungeon 2', huntingBaseId: 2, isDungeonRing: true },
    { id: '111006', name: 'dungeon 1', huntingBaseId: 1, isDungeonRing: true },
    { id: '111998', name: 'other', huntingBaseId: 1, isDungeonRing: false },
  ]
  assert.deepEqual(sortDungeonRings(sample).map(r => r.id), ['111006', '111025', '111998', '111999'])
})

test('editor dropdown uses the ordered list with search filtering', () => {
  const editor = readFileSync(new URL('../pages/code-cards/templates.vue', import.meta.url), 'utf8')
  assert.match(editor, /const sortedRingOptions = computed\(\(\) => sortDungeonRings\(catalog\.value\?\.rings \?\? \[\]\)\)/)
  assert.match(editor, /v-for="x in options\(recommendedRingOptions\)"/)
  assert.match(editor, /sortedRingOptions\.value\.filter\(ring => recommended\.has\(ring\.id\)\)/)
})