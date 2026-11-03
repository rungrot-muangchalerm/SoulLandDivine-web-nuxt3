import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import { resolve, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import { createRequire } from 'node:module'
import test from 'node:test'
import ts from 'typescript'

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const nativeRequire = createRequire(import.meta.url)
const createError = (details) => Object.assign(new Error(details.statusMessage), details)

// Execute the production TypeScript in memory with mocked Nitro/network dependencies.
// No build, database, HTTP requests or live game writes are performed.
function loader(overrides = {}) {
  const cache = new Map()
  function load(relative) {
    const filename = resolve(root, relative)
    if (overrides[filename]) return overrides[filename]
    if (cache.has(filename)) return cache.get(filename).exports
    const source = readFileSync(filename, 'utf8')
    const compiled = ts.transpileModule(source, {
      compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 },
    }).outputText
    const module = { exports: {} }
    cache.set(filename, module)
    const require = (name) => name.startsWith('.')
      ? load(resolve(dirname(filename), `${name}.ts`))
      : nativeRequire(name)
    new Function('module', 'exports', 'require', 'createError', 'defineEventHandler', 'readBody', compiled)(
      module, module.exports, require, createError, (handler) => handler, async (event) => event.body,
    )
    return module.exports
  }
  return load
}

const scheduleXml = `<idspace id="DrawTime">
<class id="1" Type="1" BeginTime="" EndTime=""/>
<class id="2" Type="2" BeginTime="" EndTime=""/>
<class id="3" Type="3" BeginTime="" EndTime="" OpenServerBeginTime="2" OpenServerEndTime="6" BeginWeekTime="2|5|00:00:00" EndWeekTime="3|1|23:59:59"/>
<class id="103" Type="103" BeginTime="" EndTime="" BeginWeekTime="2|5|00:00:00" EndWeekTime="3|1|23:59:59"/>
</idspace>`
const ratioXml = `<idspace id="DrawHeroRatio">
<class id="21" CEHUA="Tang San" Quality3="2" Ratio3="225" Quality103="2" Ratio103="13" OpenWeek="0" OpenDay="0"/>
<class id="22" CEHUA="Xiao Wu" Quality3="2" Ratio3="13" Quality103="2" Ratio103="100" OpenWeek="0" OpenDay="0"/>
<class id="30" CEHUA="Other" Quality3="3" Ratio3="100"/>
</idspace>`
const schedule = loader()('server/utils/gacha-rate-up.ts')
const rates = loader()('server/utils/gacha-character-rates.ts')

test('manual window clears all legacy schedules and does not change other pools', () => {
  const xml = schedule.updateGachaPoolSchedule(scheduleXml, 3, '2026-11-03 08:52:04', '2026-11-04 08:00:00')
  const edited = xml.match(/<class id="3"[^>]+/)[0]
  for (const field of ['OpenServerBeginTime', 'OpenServerEndTime', 'BeginWeekTime', 'EndWeekTime']) {
    assert.ok(edited.includes(`${field}=""`), field)
  }
  assert.equal(xml.match(/<class id="103"[^>]+/)[0], scheduleXml.match(/<class id="103"[^>]+/)[0])
  const pool = schedule.getGachaPool(xml, 3, new Date('2026-11-03T03:00:00Z'))
  assert.equal(pool.active, true)
  assert.equal(schedule.getGachaPool(xml, 3, new Date('2026-11-04T01:00:01Z')).active, false)
})

test('Thailand schedule times remain correct outside the host timezone', () => {
  assert.equal(schedule.parseLocalDateTime('2026-11-03 08:52:04').toISOString(), '2026-11-03T01:52:04.000Z')
  assert.equal(schedule.formatLocalDateTime(new Date('2026-11-03T01:52:04Z')), '2026-11-03 08:52:04')
  assert.equal(schedule.parseLocalDateTime('2026-02-30 08:00:00'), null)
  assert.equal(schedule.parseLocalDateTime('2026-11-03 25:00:00'), null)
})

test('scheduled opening and automatic expiration are derived from the same window', () => {
  const xml = schedule.updateGachaPoolSchedule(scheduleXml, 3, '2026-11-03 08:00:00', '2026-11-04 08:00:00')
  assert.equal(schedule.getGachaPool(xml, 3, new Date('2026-11-03T00:59:59Z')).active, false)
  assert.equal(schedule.getGachaPool(xml, 3, new Date('2026-11-03T01:00:00Z')).active, true)
  assert.equal(schedule.getGachaPool(xml, 3, new Date('2026-11-04T01:00:01Z')).active, false)
  assert.deepEqual(schedule.getGachaPools(xml).map((pool) => pool.id), [3, 103])
})

test('character weight edits affect only the selected hero and draw type', () => {
  const result = rates.updateGachaCharacterRate(ratioXml, 3, 21, 900)
  assert.equal(result.characters.find((hero) => hero.id === 21).ratio, 900)
  assert.equal(result.characters.find((hero) => hero.id === 22).ratio, 13)
  assert.equal(rates.getGachaCharacterRates(result.xml, 103).find((hero) => hero.id === 21).ratio, 13)
  assert.throws(() => rates.updateGachaCharacterRate(ratioXml, 3, 30, 0), { statusCode: 400 })
  assert.throws(() => rates.updateGachaCharacterRate(ratioXml, 3, 21, -1), { statusCode: 400 })
})

function routeFixture(apiResult = { code: 1 }, authorization = 'admin') {
  let time = scheduleXml
  let ratio = ratioXml
  const writes = []
  const override = {}
  override[resolve(root, 'server/utils/admin-session.ts')] = {
    getAdminSession: async () => ({ authorization, username: 'test' }),
  }
  override[resolve(root, 'server/utils/operation-log.ts')] = { recordOperationLog: async () => {} }
  override[resolve(root, 'server/utils/game-admin-api.ts')] = {
    fetchGameAdminApi: async (path, init) => {
      if (init?.method === 'POST') {
        const content = JSON.parse(init.body)
        writes.push({ path, content })
        if (path.endsWith('/time')) time = content
        else ratio = content
        return { json: async () => apiResult }
      }
      return { text: async () => path.endsWith('/time') ? time : ratio }
    },
  }
  const load = loader(override)
  return {
    schedule: load('server/api/gacha/rate-up.post.ts').default,
    rates: load('server/api/gacha/character-rates.post.ts').default,
    writes,
    event: (body) => ({ body, node: { req: { socket: { remoteAddress: '127.0.0.1' } } } }),
  }
}

test('opening a pool posts a complete explicit window to the game API', async () => {
  const fixture = routeFixture()
  const response = await fixture.schedule(fixture.event({ poolId: 3, action: 'open', endTime: '2099-11-04T08:00' }))
  assert.equal(response.active, true)
  assert.equal(fixture.writes.length, 1)
  assert.equal(fixture.writes[0].path, '/api/gacha/time')
  assert.ok(!fixture.writes[0].content.includes('OpenServerBeginTime="2"'))
})

test('closing a never-opened pool must not create a permanent pool', async () => {
  const fixture = routeFixture()
  const response = await fixture.schedule(fixture.event({ poolId: 103, action: 'close' }))
  assert.equal(response.active, false)
  const start = schedule.parseLocalDateTime(response.beginTime)
  const end = schedule.parseLocalDateTime(response.endTime)
  assert.ok(start && end && start < end && end < new Date())
  const row = fixture.writes[0].content.match(/<class id="103"[^>]+/)[0]
  assert.ok(row.includes('BeginWeekTime=""') && row.includes('EndWeekTime=""'))
})

test('failed runtime reload is returned as an error, never a success message', async () => {
  const fixture = routeFixture({ code: 4, message: 'runtime reload failed' })
  await assert.rejects(fixture.schedule(fixture.event({ poolId: 3, action: 'open', endTime: '2099-11-04T08:00' })),
    { statusCode: 502 })
  await assert.rejects(fixture.rates(fixture.event({ drawType: 3, heroId: 21, ratio: 900 })),
    { statusCode: 502 })
})

test('rate changes use the ratio API; unauthorized requests make no writes', async () => {
  const fixture = routeFixture()
  await fixture.rates(fixture.event({ drawType: 3, heroId: 21, ratio: 900 }))
  assert.equal(fixture.writes[0].path, '/api/gacha/ratio')
  const rejected = routeFixture({ code: 1 }, 'viewer')
  await assert.rejects(rejected.schedule(rejected.event({ poolId: 3, action: 'close' })), { statusCode: 403 })
  assert.equal(rejected.writes.length, 0)
})

test('simultaneous edits run sequentially and a failed edit releases the queue', async () => {
  const { withGachaWriteLock } = loader()('server/utils/gacha-write-lock.ts')
  const order = []
  const first = withGachaWriteLock(async () => {
    order.push('first')
    await new Promise((resolve) => setTimeout(resolve, 10))
    order.push('failed')
    throw new Error('expected')
  })
  const second = withGachaWriteLock(async () => { order.push('second'); return 'ok' })
  await assert.rejects(first, /expected/)
  assert.equal(await second, 'ok')
  assert.deepEqual(order, ['first', 'failed', 'second'])
})

test('GM polling updates expiration without erasing the operator\'s draft', async () => {
  const source = readFileSync(resolve(root, 'pages/gacha.vue'), 'utf8').match(/<script setup lang="ts">([\s\S]*?)<\/script>/)[1]
  const compiled = ts.transpileModule(source, {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 },
    reportDiagnostics: true,
  })
  assert.equal((compiled.diagnostics || []).length, 0)
  const newPool = { id: 3, type: '3', name: 'test', beginTime: '2026-11-03 08:00:00', endTime: '2026-11-04 08:00:00', active: false }
  const state = new Function('ref', 'onMounted', 'onBeforeUnmount', '$fetch', 'exports',
    `${compiled.outputText}; return { setPools, pools, endTimes, refreshScheduleSilently }`)(
    (value) => ({ value }), () => {}, () => {}, async () => [newPool], {},
  )
  state.setPools([{ ...newPool, active: true }])
  state.endTimes.value[3] = '2099-12-01T09:00'
  await state.refreshScheduleSilently()
  assert.equal(state.pools.value[0].active, false)
  assert.equal(state.endTimes.value[3], '2099-12-01T09:00')
})

const custom = loader()('server/utils/custom-gacha-config.ts')
const qualityXml = `<idspace id="DrawQualityRatio">
<class id="3" Single="300" Continuous="2000" SingleItem="4007" ContinuousItem="4008" BlessingMax="99" CostRatio="2:100|3:200|4:300|5:400"/>
<class id="10000" Single="300" Continuous="2000" SingleDiscount="300" ContinuousDiscount="2000" SingleItem="4007" ContinuousItem="4008" BlessingMax="99" CostRatio="2:100|3:200|4:300|5:400" ItemRatio="2:100|3:200|4:300|5:400"/>
</idspace>`

test('custom settings change only Type 10000, with independent prices, tickets and pity', () => {
  const original = custom.getCustomGachaConfig(qualityXml)
  const result = custom.updateCustomGachaConfig(qualityXml, {
    ...original, singlePrice: 150, continuousPrice: 1000, blessingMax: 50,
    singleItem: 0, continuousItem: 0, ssrWeight: 500,
  })
  assert.equal(result.xml.match(/<class id="3"[^>]+/)[0], qualityXml.match(/<class id="3"[^>]+/)[0])
  assert.equal(result.config.singlePrice, 150)
  assert.equal(result.config.blessingMax, 50)
  assert.equal(result.config.singleItem, 0)
  const row = result.xml.match(/<class id="10000"[^>]+/)[0]
  assert.ok(row.includes('SingleDiscount="150"'))
  assert.ok(row.includes('CostRatio="2:500|3:200|4:300|5:400"'))
  assert.ok(row.includes('ItemRatio="2:500|3:200|4:300|5:400"'))
})

test('custom rules reject invalid weights, nonexistent ticket IDs and shared type configurations', () => {
  const original = custom.getCustomGachaConfig(qualityXml)
  assert.throws(() => custom.updateCustomGachaConfig(qualityXml, { ...original, singlePrice: -1 }), { statusCode: 400 })
  assert.throws(() => custom.updateCustomGachaConfig(qualityXml, { ...original, singleItem: 99999999 }), { statusCode: 400 })
  assert.throws(() => custom.updateCustomGachaConfig(qualityXml, { ...original, ssrWeight: 0, srWeight: 0, rWeight: 0, nWeight: 0 }), { statusCode: 400 })
  assert.throws(() => custom.getCustomGachaConfig('<idspace id="DrawQualityRatio"><class id="3"/></idspace>'), { statusCode: 409 })
})

function customRouteFixture(type = '10000', result = { code: 1 }) {
  const writes = []
  const overrides = {}
  overrides[resolve(root, 'server/utils/admin-session.ts')] = { getAdminSession: async () => ({ authorization: 'admin', username: 'test' }) }
  overrides[resolve(root, 'server/utils/operation-log.ts')] = { recordOperationLog: async () => {} }
  overrides[resolve(root, 'server/utils/game-admin-api.ts')] = {
    fetchGameAdminApi: async (path, init) => {
      if (init?.method === 'POST') { writes.push({ path, content: JSON.parse(init.body) }); return { json: async () => result } }
      return { text: async () => path.endsWith('/time')
        ? `<idspace id="DrawTime"><class id="10000" Type="${type}" BeginTime="" EndTime=""/></idspace>` : qualityXml }
    },
  }
  const load = loader(overrides)
  return { get: load('server/api/gacha/custom-config.get.ts').default,
    post: load('server/api/gacha/custom-config.post.ts').default, writes }
}

test('custom API requires isolated Type 10000 and saves through the live reload endpoint', async () => {
  const fixture = customRouteFixture()
  const current = await fixture.get({})
  const response = await fixture.post({ body: { ...current, singlePrice: 175 }, node: { req: { socket: {} } } })
  assert.equal(response.config.singlePrice, 175)
  assert.equal(fixture.writes[0].path, '/api/gacha/quality')
  const shared = customRouteFixture('3')
  await assert.rejects(shared.get({}), { statusCode: 409 })
  await assert.rejects(shared.post({}), { statusCode: 409 })
  assert.equal(shared.writes.length, 0)
})

test('custom save does not report success when the game API rejects the reload', async () => {
  const fixture = customRouteFixture('10000', { code: 4, message: 'reload failed' })
  await assert.rejects(fixture.post({ body: custom.getCustomGachaConfig(qualityXml), node: { req: { socket: {} } } }), { statusCode: 502 })
})
