import assert from 'node:assert/strict'
import { existsSync, readFileSync } from 'node:fs'
import { resolve, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import test from 'node:test'
import ts from 'typescript'

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..')

function loadActivitySchedules(fetchGameAdminApi = async () => ({ text: async () => '' })) {
  const filename = resolve(root, 'server/utils/activity-schedules.ts')
  const source = readFileSync(filename, 'utf8')
  const compiled = ts.transpileModule(source, {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 },
  }).outputText
  const module = { exports: {} }
  const require = () => ({ fetchGameAdminApi })
  new Function('module', 'exports', 'require', 'createError', compiled)(
    module, module.exports, require, (details) => Object.assign(new Error(details.statusMessage), details),
  )
  return module.exports
}

test('activity schedule cards include matching banner artwork or a category fallback', () => {
  const { activityScheduleConfigs, parseActivitySchedule } = loadActivitySchedules()
  const rechargeTabs = activityScheduleConfigs.find((config) => config.id === 'recharge-tabs')
  const rows = parseActivitySchedule(rechargeTabs,
    '<idspace id="RechargeGiftTab"><class id="8" GiftType="9" SubType="2" ShowStart="2023-9-15 00:00:01" ShowEnd="2023-10-14 23:59:58"/><class id="1000" GiftType="26" SubType="3" ShowStart="2023-9-15 00:00:01" ShowEnd="2023-10-14 23:59:58"/></idspace>')

  assert.equal(rows[0].imageUrl, '/activity-banners/3.webp')
  assert.equal(rows[0].canOpenImmediately, true)
  assert.equal(rows[1].imageUrl, '/activity-banners/16.webp')
  assert.equal(rows[1].canOpenImmediately, false)
  assert.equal(
    parseActivitySchedule(
      activityScheduleConfigs.find((config) => config.id === 'recharge-time'),
      '<idspace id="RechargeGiftTime"><class id="1" GiftType="24" SubType="1" ShowStart="2022-8-2 00:01:00"/></idspace>',
    )[0].imageUrl,
    '/activity-banners/14.webp',
  )
})

test('every activity category uses an existing banner image', () => {
  const { activityScheduleConfigs, parseActivitySchedule } = loadActivitySchedules()
  for (const [index, config] of activityScheduleConfigs.entries()) {
    const field = config.fields[0].key
    const fields = config.id === 'recharge-tabs'
      ? `GiftType="1" ShowStart="2023-9-15 00:00:01"`
      : `${field}="1"`
    const [row] = parseActivitySchedule(
      config,
      `<idspace id="${config.rootId}"><class id="${index + 1}" ${fields}/></idspace>`,
    )
    assert.ok(row.imageUrl, `${config.id} should have an image URL`)
    assert.ok(existsSync(resolve(root, 'public', row.imageUrl.slice(1))), `${config.id}: ${row.imageUrl}`)
  }
})

test('theme pass immediate-open schedule clears competing week and server-day conditions', async () => {
  let request
  const { saveActivitySchedule } = loadActivitySchedules(async (path, init) => {
    request = { path, init }
    return { json: async () => ({ code: 1 }) }
  })
  const fields = {
    ShowStart: '2026-11-04 16:00:00',
    ShowEnd: '2026-11-05 16:00:00',
    ShowWeekStart: '',
    ShowWeekEnd: '',
    OpenStart: '-1',
    TabShowEnd: '2026-11-05 16:00:00',
  }

  await saveActivitySchedule('recharge-tabs', 8, fields)
  assert.equal(request.path, '/api/activities/config/recharge-tabs/8')
  assert.deepEqual(JSON.parse(request.init.body), fields)
})
