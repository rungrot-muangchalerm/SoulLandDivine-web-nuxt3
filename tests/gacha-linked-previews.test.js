import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync, existsSync } from 'node:fs'
import ts from 'typescript'

const source = readFileSync(new URL('../utils/gacha-schedule-links.ts', import.meta.url), 'utf8')
const js = ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.ESNext } }).outputText
const links = await import(`data:text/javascript;base64,${Buffer.from(js).toString('base64')}`)
const overridesSource = readFileSync(new URL('../utils/activity-schedule-overrides.ts', import.meta.url), 'utf8')
const overridesJs = ts.transpileModule(overridesSource, { compilerOptions: { module: ts.ModuleKind.ESNext } }).outputText
const overrides = await import(`data:text/javascript;base64,${Buffer.from(overridesJs).toString('base64')}`)
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

test('activity manager excludes every server-linked recharge activity', { skip: !existsSync(serverFile) }, () => {
  const server = readFileSync(serverFile, 'utf8')
  const group = server.split('GachaLinkedRechargeActivityGroups =')[1].split('};')[0]
  const expected = [...group.matchAll(/\((\d+), new\[\] \{([^}]+)\}\)/g)]
    .flatMap(row => row[2].split(',').map(Number))
    .sort((a, b) => a - b)

  assert.deepEqual([...overrides.GACHA_LINKED_RECHARGE_ACTIVITY_IDS].sort((a, b) => a - b), expected)
  for (const id of expected) {
    assert.equal(overrides.isGachaLinkedRechargeActivity('recharge-tabs', id), true, `activity ${id}`)
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

test('Lougao gacha 99 controls theme pool 25 and linked activities', () => {
  assert.equal(links.getGachaScheduleControllerId(25), 99)
  assert.deepEqual(links.getGachaScheduleFollowers(99), [25])
  assert.deepEqual(links.getGachaScheduleActivities(25), [])
  assert.deepEqual(links.getGachaScheduleActivities(99), [121, 901, 902])
})

test('Sea Witch gacha 6 controls daily recharge activity 24', () => {
  assert.deepEqual(links.getGachaScheduleActivities(6), [24])
})

test('Tang Lie gacha 7 controls daily recharge set 5 activity 34', () => {
  assert.deepEqual(links.getGachaScheduleActivities(7), [34])
})

test('Bai Chenxiang gacha 12 controls Mahongjun gacha 20 and linked activities', () => {
  assert.equal(links.getGachaScheduleControllerId(20), 12)
  assert.deepEqual(links.getGachaScheduleFollowers(12), [20])
  assert.deepEqual(links.getGachaScheduleActivities(12), [109, 146])
  assert.deepEqual(links.getGachaScheduleActivities(20), [])
  assert.match(overrides.getGachaLinkedRechargeActivityNotice('recharge-tabs', 109), /ID 12/)
  assert.match(overrides.getGachaLinkedRechargeActivityNotice('recharge-tabs', 146), /ID 12/)
})

test('Sea Dragon gacha 8 controls recharge set 2006 activity 999', () => {
  assert.deepEqual(links.getGachaScheduleActivities(8), [999])
})

test('theme gacha 9 controls daily recharge activity 46', () => {
  assert.deepEqual(links.getGachaScheduleActivities(9), [46])
})

test('Sea Devil gacha 11 controls daily recharge set 8 activity 56', () => {
  assert.deepEqual(links.getGachaScheduleActivities(11), [56])
})

test('daily recharge activity 46 is protected from manual scheduling', () => {
  assert.equal(overrides.isGachaLinkedRechargeActivity('recharge-tabs', 46), true)
  assert.match(overrides.getGachaLinkedRechargeActivityNotice('recharge-tabs', 46), /ยูเรเซีย ID 9/)
})

test('deity recruitment pool 42 controls the Ayin group and hides retired pool 24', () => {
  assert.equal(links.getGachaScheduleControllerId(4), 42)
  assert.deepEqual(links.getGachaScheduleFollowers(42), [4])
  assert.deepEqual(links.getGachaScheduleActivities(24), [])
  assert.deepEqual(links.getGachaScheduleActivities(42), [18, 19, 126, 137, 151])
  assert.equal(links.isGachaSchedulePoolHidden(24), true)
})
