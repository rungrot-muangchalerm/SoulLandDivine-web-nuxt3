import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
const source = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8')

test('archive paginates globally by unused before used, not within one page', () => {
  const endpoint = source('server/api/code-cards/archive.get.ts')
  assert.match(endpoint, /ORDER BY CASE WHEN c\.status = 'used' THEN 1 ELSE 0 END ASC, b\.created_at DESC, c\.id DESC LIMIT \? OFFSET \?/)
  assert.match(endpoint, /COUNT\(\*\) AS total/)
})

test('archive returns actual reward snapshot after synchronizing ready codes', () => {
  const endpoint = source('server/api/code-cards/archive.get.ts')
  assert.match(endpoint, /definition: JSON\.parse\(x\.snapshot_json\)/)
  assert.match(endpoint, /previewDefinition: JSON\.parse\(x\.snapshot_json\)/)
  const item = source('components/CodeCardArchiveItem.vue')
  assert.match(item, /:definition="card\.previewDefinition \?\? card\.definition"/)
  assert.match(item, /card\.previewDefinition\?\.name \?\? card\.definition\.name/)
})

test('archive explains live unredeemed rewards and historical redeemed records', () => {
  const page = source('pages/code-cards/archive.vue')
  assert.match(page, /บัตรพร้อมใช้จะอัปเดตภาพและรางวัลตามแม่แบบล่าสุด/)
  assert.match(page, /บัตรที่ใช้แล้วเก็บประวัติเดิม/)
})
