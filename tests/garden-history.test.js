import test from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
const read = p => readFileSync(new URL(p, import.meta.url), 'utf8')

test('Garden history list is admin-only, read-only and keeps unidentified legacy separately', () => {
  const route = read('../server/api/activities/history/garden.get.ts')
  assert.match(route, /getAdminSession\(event\)/)
  assert.match(route, /session\.authorization !== 'admin'/)
  assert.match(route, /getGameDatabase\(\)/)
  assert.match(route, /FROM garden_instance_progress|FROM `garden_instance_progress`/i)
  assert.match(route, /FROM garden_period|FROM `garden_period`/i)
  assert.match(route, /FROM garden_rank_history|FROM `garden_rank_history`/i)
  assert.match(route, /Cache-Control.*no-store/)
  assert.doesNotMatch(route, /\b(?:DELETE FROM|TRUNCATE|DROP TABLE|UPDATE garden_period)\b/i)
})

test('Garden history detail reads a specific immutable instance with parameterized queries', () => {
  const route = read('../server/api/activities/history/garden/[instanceId].get.ts')
  assert.match(route, /getAdminSession\(event\)/)
  assert.match(route, /getRouterParam\(event, 'instanceId'\)/)
  assert.match(route, /\[instanceId\]|instanceId\s*\)/)
  assert.match(route, /getGameDatabase\(\)\.execute/)
  assert.match(route, /WHERE instance_id = \?/)
  assert.doesNotMatch(route, /DELETE|TRUNCATE|DROP TABLE/i)
})

test('Activity page links to archived Garden activity history and displays legacy attribution clearly', () => {
  const index = read('../pages/activities/index.vue')
  const page = read('../pages/activities/history/index.vue')
  const detail = read('../pages/activities/history/[instanceId].vue')
  assert.match(index, /\/activities\/history/)
  assert.match(page, /garden/)
  assert.match(page, /Legacy|ข้อมูลเก่า/)
  assert.match(page, /\/api\/activities\/history\/garden/)
  assert.match(detail, /\/api\/activities\/history\/garden\//)
  assert.doesNotMatch(page + detail, /v-html/)
})

test('Garden history lists zero-player archived cycles from lifecycle as well as live progress', () => {
  const route = read('../server/api/activities/history/garden.get.ts')
  const page = read('../pages/activities/history/index.vue')
  assert.match(route, /FROM garden_instance_lifecycle/)
  assert.match(route, /LEFT JOIN/)
  assert.match(route, /state/)
  assert.match(route, /archivedAt/)
  assert.match(page, /item\.state/)
})