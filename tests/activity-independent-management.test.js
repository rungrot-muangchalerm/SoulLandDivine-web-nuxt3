import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const componentFile = new URL('../components/ActivitySchedules.vue', import.meta.url)
const parserFile = new URL('../server/utils/activity-schedules.ts', import.meta.url)
const clientXmlFile = new URL('../../SoulLandDivine-client/Assets/Resources/XML/Server/Recharge/RechargeGiftTab.xml', import.meta.url)
const rechargeManagerFile = new URL('../../SoulLandDivine-client/Assets/Lua/Manager/Recharge/RechargeManager.lua', import.meta.url)

test('Activities management lists each row independently and displays GiftType as metadata', () => {
  const component = readFileSync(componentFile, 'utf8')

  assert.match(component, /v-for="activity in configRows"/)
  assert.match(component, /activity\.giftType/)
  assert.match(component, /GiftType/)
  assert.match(component, /const resultCount = computed\(\(\) => configRows\.value\.length\)/)
  assert.doesNotMatch(component, /pageSize|pageCount|visibleRows|class="pagination/)
  assert.doesNotMatch(component, /groupKey|setGroupActivity|groups = computed|exclusiveGroup|activeGroupKey|activityGroupRoute/)
  assert.doesNotMatch(component, /activity\.giftType\s*(?:===|!==)\s*\d+/)
})

test('Activity schedule API parser keeps GiftType label separate from activity identity', () => {
  const parser = readFileSync(parserFile, 'utf8')

  assert.match(parser, /giftTypeLabel:\s*giftTypeNames\[Number\(values\.GiftType\)\]/)
  assert.doesNotMatch(parser, /exclusiveGroup|groupName/)
})

test('current multi-row event types use independent client tabs rather than one GiftType slot', () => {
  const xml = readFileSync(clientXmlFile, 'utf8')
  const rows = [...xml.matchAll(/<class\b([^>]*)\/>/g)].map((match) =>
    Object.fromEntries([...match[1].matchAll(/([\w]+)="([^"]*)"/g)].map((attribute) => [attribute[1], attribute[2]])),
  )
  const independentGiftTypes = new Set([9, 11, 15, 16, 19, 22, 25, 26, 39, 40, 42, 43, 44, 47])

  for (const giftType of independentGiftTypes) {
    const matching = rows.filter((row) => Number(row.GiftType) === giftType)
    assert.ok(matching.length > 1, 'GiftType ' + giftType + ' has multiple configured activities')
    assert.ok(matching.every((row) => row.SeparateTab === '1'), 'GiftType ' + giftType + ' renders each activity as a separate tab')
  }

  const manager = readFileSync(rechargeManagerFile, 'utf8')
  assert.match(manager, /if rechargeGiftData\.separateTab then[\s\S]*?rechargeGiftTabById\[tonumber\(rechargeGiftData\.id\)\] = rechargeGiftData/)
})