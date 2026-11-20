import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8')
const catalog = JSON.parse(read('data/code-card-catalog.json'))

test('SSR heroes have game-sourced recommended rings and every recommendation exists in catalog', () => {
  const ringIds = new Set(catalog.rings.map(r => r.id))
  for (const hero of catalog.heroes) {
    if (hero.quality === 2) assert.ok(hero.recommendedRingIds?.length > 0, 'SSR hero ' + hero.id)
    assert.ok(Array.isArray(hero.recommendedRingIds), 'hero ' + hero.id)
    assert.equal(new Set(hero.recommendedRingIds).size, hero.recommendedRingIds.length)
    for (const id of hero.recommendedRingIds) assert.ok(ringIds.has(id), 'missing ring ' + id)
  }
  assert.deepEqual(catalog.heroes.find(x => x.id === '21').recommendedRingIds.slice(0, 3), ['111004', '111003', '111017'])
  assert.deepEqual(catalog.heroes.find(x => x.id === '23').recommendedRingIds.slice(0, 3), ['111025', '111024', '111004'])
  assert.deepEqual(catalog.heroes.find(x => x.id === '21023').recommendedRingIds.slice(0, 3), ['111025', '111024', '111004'])
})

test('generator uses RecommondSoulRing from original client HeroCardClient XML by hero id', () => {
  const generator = read('scripts/build-code-card-catalog.py')
  assert.match(generator, /RecommondSoulRing/)
  assert.match(generator, /recommendedRingIds/)
  assert.match(generator, /client_heroes/)
})

test('template selection restricts each ring to selected hero recommendations and repairs existing stale selections', () => {
  const editor = read('pages/code-cards/templates.vue')
  assert.match(editor, /selectedHero\.value\?\.recommendedRingIds/)
  assert.match(editor, /recommendedRingOptions/)
  assert.match(editor, /function reconcileRecommendedRings/)
  assert.match(editor, /reconcileRecommendedRings\(\)/)
  assert.match(editor, /v-for="x in options\(recommendedRingOptions\)"/)
  assert.doesNotMatch(editor, /v-for="x in options\(sortedRingOptions\)"/)
})

test('template dropdown labels omit raw ids and SSR hero names have [SSR] label', () => {
  const editor = read('pages/code-cards/templates.vue')
  assert.doesNotMatch(editor, /\{\{ x\.name \}\} · \{\{ x\.id \}\}/)
  assert.match(editor, /\[SSR\]/)
  assert.match(editor, /heroOptionLabel\(x\)/)
})
