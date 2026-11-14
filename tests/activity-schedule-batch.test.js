import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import ts from 'typescript'

const helperSource = readFileSync(new URL('../utils/activity-schedule-batch.ts', import.meta.url), 'utf8')
const helperJs = ts.transpileModule(helperSource, { compilerOptions: { module: ts.ModuleKind.ESNext } }).outputText
const batch = await import('data:text/javascript;base64,' + Buffer.from(helperJs).toString('base64'))

const overridesSource = readFileSync(new URL('../utils/activity-schedule-overrides.ts', import.meta.url), 'utf8')
const overridesJs = ts.transpileModule(overridesSource, { compilerOptions: { module: ts.ModuleKind.ESNext } }).outputText
const overrides = await import('data:text/javascript;base64,' + Buffer.from(overridesJs).toString('base64'))

test('group activation prepares configured-duration and manual updates in one batch', () => {
  const now = new Date(2026, 10, 14, 12, 0, 0)
  const rows = [
    { id: 101, configId: 'recharge-tabs', durationDays: 7 },
    { id: 102, configId: 'recharge-tabs' },
    { id: 103, configId: 'recharge-tabs', durationDays: 14 },
  ]

  const updates = batch.buildActivityScheduleBatchUpdates(rows, true, now, overrides.getActivityOverrideFields)

  assert.deepEqual(updates, [
    { id: 101, openForConfiguredDuration: true },
    { id: 102, fields: overrides.getActivityOverrideFields('recharge-tabs', true, now) },
    { id: 103, openForConfiguredDuration: true },
  ])
  assert.equal(updates.length, rows.length)
})

test('group closing sends manual close fields for every row', () => {
  const now = new Date(2026, 10, 14, 12, 0, 0)
  const rows = [
    { id: 101, configId: 'recharge-tabs', durationDays: 7 },
    { id: 102, configId: 'recharge-tabs' },
  ]

  const updates = batch.buildActivityScheduleBatchUpdates(rows, false, now, overrides.getActivityOverrideFields)

  assert.deepEqual(updates, rows.map(row => ({
    id: row.id,
    fields: overrides.getActivityOverrideFields(row.configId, false, now),
  })))
})

test('group activation submits one batch request instead of one reload request per row', () => {
  const component = readFileSync(new URL('../components/ActivitySchedules.vue', import.meta.url), 'utf8')
  const groupHandler = component
    .split('async function setGroupActivity')[1]
    .split('async function setActivityAlwaysOpen')[0]

  assert.match(groupHandler, /\/api\/activities\/schedule\/batch/)
  assert.equal((groupHandler.match(/\$fetch(?:<|\()/g) || []).length, 1)
  assert.doesNotMatch(groupHandler, /\/api\/activities\/open|\/api\/activities\/schedule['"]/)
})


test('AdminAPI batch endpoint persists once and requests one runtime reload', () => {
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
