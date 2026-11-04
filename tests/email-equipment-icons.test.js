import assert from 'node:assert/strict'
import { readFileSync, readdirSync } from 'node:fs'
import { resolve, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import { createRequire } from 'node:module'
import test from 'node:test'
import ts from 'typescript'

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const nativeRequire = createRequire(import.meta.url)

function loadItemsHandler(rows) {
  const filename = resolve(root, 'server/api/email/items.post.ts')
  const source = readFileSync(filename, 'utf8')
  const compiled = ts.transpileModule(source, {
    compilerOptions: {
      module: ts.ModuleKind.CommonJS,
      target: ts.ScriptTarget.ES2022,
      esModuleInterop: true,
    },
  }).outputText
  const module = { exports: {} }
  const require = (name) => {
    const dependency = resolve(dirname(filename), name)
    if (name.endsWith('.json')) {
      return JSON.parse(readFileSync(dependency, 'utf8'))
    }
    if (dependency === resolve(root, 'server/utils/admin-session')) {
      return { getAdminSession: async () => ({}) }
    }
    if (dependency === resolve(root, 'server/utils/database')) {
      return { getGameDatabase: () => ({ query: async () => [rows, []] }) }
    }
    return nativeRequire(name)
  }
  new Function(
    'module',
    'exports',
    'require',
    'defineEventHandler',
    'createError',
    compiled,
  )(
    module,
    module.exports,
    require,
    (route) => route,
    (details) => Object.assign(new Error(details.statusMessage), details),
  )

  return module.exports.default
}

test('email equipment icon mappings resolve to shipped images', async () => {
  const mappings = JSON.parse(readFileSync(resolve(root, 'data/email-equipment-icons.json'), 'utf8'))
  const namesByType = JSON.parse(readFileSync(resolve(root, 'data/email-item-names.json'), 'utf8'))
  const filenames = new Set(readdirSync(resolve(root, 'public/icons_equipment')))
  const ids = ['3330214', '3330221', '3330241', '3330254']
  const boneIds = ['200146', '200155']
  const items = await loadItemsHandler([
    { itemInfo: [
      ...ids.map((id) => `${id}:5:1`),
      ...boneIds.map((id) => `${id}:4:1`),
    ].join('|') },
  ])({})

  assert.equal(mappings['3330214'], 'item_equip_dg2_boots')
  assert.equal(mappings['3330221'], 'item_equip_tk2_neck')
  assert.equal(mappings['3330241'], 'item_equip_kz2_neck')
  assert.equal(mappings['3330254'], 'item_equip_qg2_boots')

  for (const icon of Object.values(mappings)) {
    assert.ok(filenames.has(`${icon}.png`), `Missing email equipment icon: ${icon}.png`)
  }
  for (const id of ids) {
    assert.equal(
      items.find((item) => item.id === id)?.iconUrl,
      `/icons_equipment/${mappings[id]}.png`,
    )
  }

  assert.equal(items.find((item) => item.id === '200146')?.name, 'กระดูกขาซ้ายแมงมุมหน้าคน')
  assert.equal(items.find((item) => item.id === '200155')?.name, 'กระดูกแขนซ้ายอสูรเกล็ดสี่ตา')
  assert.equal(items.find((item) => item.id === '3330214')?.name, 'บูทสุวรรณ')
  assert.ok(Object.values(namesByType).flatMap(Object.values).every((name) => /[\u0E00-\u0E7F]/.test(name)))
  assert.ok(items.every((item) => !item.name || /[\u0E00-\u0E7F]/.test(item.name)))
})
