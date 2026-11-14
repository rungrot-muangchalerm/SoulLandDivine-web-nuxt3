import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync, existsSync } from 'node:fs'
import ts from 'typescript'

const source = readFileSync(new URL('../utils/gacha-schedule-links.ts', import.meta.url), 'utf8')
const js = ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.ESNext } }).outputText
const links = await import(`data:text/javascript;base64,${Buffer.from(js).toString('base64')}`)
const serverFile = new URL('../../SoulLandDivine-server/AdminAPI/Services/ActivityService.cs', import.meta.url)

test('preview activity IDs match the server schedule linkage', { skip: !existsSync(serverFile) }, () => {
  const server = readFileSync(serverFile, 'utf8')
  const group = server.split('GachaLinkedRechargeActivityGroups =')[1].split('};')[0]
  const expected = [...group.matchAll(/\((\d+), new\[\] \{([^}]+)\}\)/g)]
  assert.ok(expected.length > 0)
  for (const row of expected) {
    assert.deepEqual(links.getGachaScheduleActivities(Number(row[1])), row[2].split(',').map(Number), `controller ${row[1]}`)
  }
})

test('standalone pools do not receive unrelated activity previews', () => {
  assert.deepEqual(links.getGachaScheduleActivities(10000), [])
})

test('poison gacha 103 controls theme recruitment pool 18 and activity 141', () => {
  assert.equal(links.getGachaScheduleControllerId(18), 103)
  assert.deepEqual(links.getGachaScheduleFollowers(103), [18])
  assert.deepEqual(links.getGachaScheduleActivities(18), [])
  assert.deepEqual(links.getGachaScheduleActivities(103), [141])
})

test('deity recruitment pool 42 controls the Ayin group and hides retired pool 24', () => {
  assert.equal(links.getGachaScheduleControllerId(4), 42)
  assert.deepEqual(links.getGachaScheduleFollowers(42), [4])
  assert.deepEqual(links.getGachaScheduleActivities(24), [])
  assert.deepEqual(links.getGachaScheduleActivities(42), [18, 19, 126, 137, 151])
  assert.equal(links.isGachaSchedulePoolHidden(24), true)
})
