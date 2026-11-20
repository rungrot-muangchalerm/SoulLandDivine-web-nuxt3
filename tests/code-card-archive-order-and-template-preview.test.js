import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
const source = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8')

test('archive paginates globally by unused before used, not within one page', () => {
  const endpoint = source('server/api/code-cards/archive.get.ts')
  assert.match(endpoint, /ORDER BY CASE WHEN c\.status = 'used' THEN 1 ELSE 0 END ASC, b\.created_at DESC, c\.id DESC LIMIT \? OFFSET \?/)
  assert.match(endpoint, /COUNT\(\*\) AS total/)
})

test('archive carries latest editable template preview without rewriting issued snapshot', () => {
  const endpoint = source('server/api/code-cards/archive.get.ts')
  assert.match(endpoint, /LEFT JOIN character_card_templates t ON t\.id=b\.template_id/)
  assert.match(endpoint, /t\.definition_json AS template_definition_json/)
  assert.match(endpoint, /definition: JSON\.parse\(x\.snapshot_json\)/)
  assert.match(endpoint, /previewDefinition: x\.template_definition_json \? JSON\.parse\(x\.template_definition_json\) : JSON\.parse\(x\.snapshot_json\)/)
  const item = source('components/CodeCardArchiveItem.vue')
  assert.match(item, /:definition="card\.previewDefinition \?\? card\.definition"/)
  assert.match(item, /card\.previewDefinition\?\.name \?\? card\.definition\.name/)
})

test('archive clearly distinguishes current preview from original issued reward', () => {
  const page = source('pages/code-cards/archive.vue')
  assert.match(page, /ภาพจากแม่แบบปัจจุบัน/)
  assert.match(page, /รางวัลคงตามข้อมูลตอนเจน/)
})
