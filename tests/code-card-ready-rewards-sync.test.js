import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const read = name => readFileSync(new URL('../' + name, import.meta.url), 'utf8')
test('saving templates updates ready codes rewards atomically and leaves used codes untouched', () => {
  const api = read('server/api/code-cards/templates.post.ts')
  const service = read('server/utils/code-cards.ts')
  assert.match(api, /updateCardTemplate\(/)
  assert.match(service, /export async function updateCardTemplate\(/)
  assert.match(service, /await connection\.beginTransaction\(\)/)
  assert.match(service, /await connection\.commit\(\)/)
  assert.match(service, /await connection\.rollback\(\)/)
  assert.match(service, /UPDATE character_card_codes c JOIN character_card_batches b ON b\.id=c\.batch_id/)
  assert.match(service, /SET c\.reward_string=\?,c\.snapshot_json=\?/)
  assert.match(service, /WHERE b\.template_id=\? AND c\.status='ready'/)
  assert.match(service, /buildCardRewards\(definition\)/)
})
test('archive shows what each code actually delivers, even for redeemed codes', () => {
  const route = read('server/api/code-cards/archive.get.ts')
  assert.doesNotMatch(route, /previewDefinition: x\.template_definition_json/)
  assert.match(route, /previewDefinition: JSON\.parse\(x\.snapshot_json\)/)
})
