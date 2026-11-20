import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import { normalizeArchivePage } from '../utils/code-card-archive.ts'

test('archive loads cards from all batches without a batch selector', () => {
  const archive = readFileSync(new URL('../pages/code-cards/archive.vue', import.meta.url), 'utf8')
  assert.match(archive, /\/api\/code-cards\/archive/)
  assert.doesNotMatch(archive, /<select/)
  assert.doesNotMatch(archive, /เลือกชุดบัตร/)
  assert.match(archive, /<CodeCardArchiveItem/)
  assert.match(archive, /v-for="card in visibleCards"/)
  assert.match(archive, /currentPage\+\+/)
  assert.match(archive, /currentPage--/)
})

test('archive endpoint checks admin and uses bounded server pagination over ALL cards', () => {
  const route = readFileSync(new URL('../server/api/code-cards/archive.get.ts', import.meta.url), 'utf8')
  assert.match(route, /await cardAdmin\(event\)/)
  assert.match(route, /FROM character_card_codes c JOIN character_card_batches b/)
  assert.match(route, /ORDER BY b\.created_at DESC, c\.id DESC LIMIT \? OFFSET \?/)
  assert.match(route, /decryptCardCode/)
  assert.match(route, /normalizeArchivePage/)
  assert.doesNotMatch(route, /WHERE batch_id=\?/)
})

test('archive page validation bounds malformed numbers and large offsets', () => {
  assert.equal(normalizeArchivePage(undefined), 1)
  assert.equal(normalizeArchivePage(''), 1)
  assert.equal(normalizeArchivePage('-1'), 1)
  assert.equal(normalizeArchivePage('1.5'), 1)
  assert.equal(normalizeArchivePage('abc'), 1)
  assert.equal(normalizeArchivePage('2'), 2)
  assert.equal(normalizeArchivePage('999999999999'), 1)
})