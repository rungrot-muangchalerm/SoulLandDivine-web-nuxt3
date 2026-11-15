import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

test('Activities page uses per-row controls and no longer exposes GiftType group actions', () => {
  const component = readFileSync(new URL('../components/ActivitySchedules.vue', import.meta.url), 'utf8')

  assert.match(component, /v-for="activity in configRows"/)
  assert.match(component, /setActivityAlwaysOpen\(activity/)
  assert.doesNotMatch(component, /setGroupActivity|groupKey|visibleGroups|group-active|exclusiveGroup/)
})

test('AdminAPI batch endpoint remains atomic for trusted multi-row updates', () => {
  const serverRoot = new URL('../../SoulLandDivine-server/', import.meta.url)
  const program = readFileSync(new URL('AdminAPI/Program.cs', serverRoot), 'utf8')
  const service = readFileSync(new URL('AdminAPI/Services/ActivityService.cs', serverRoot), 'utf8')
  const endpoint = program
    .split('app.MapPost("/api/activities/config/{configId}/batch"')[1]
    .split('app.MapPost("/api/activities/config/{configId}/{rowId:int}"')[0]
  const batchMethod = service
    .split('private IReadOnlyList<ActivityScheduleUpdateResult> UpdateSchedulesLocked')[1]
    .split('public ActivityOpenResult? OpenRechargeTabForConfiguredDuration')[0]

  assert.ok(endpoint)
  assert.equal((endpoint.match(/UpdateSchedules\(/g) || []).length, 1)
  assert.equal((endpoint.match(/ReloadActivityScheduleAsync\(/g) || []).length, 1)
  assert.equal((batchMethod.match(/PersistDocuments\(/g) || []).length, 1)
})