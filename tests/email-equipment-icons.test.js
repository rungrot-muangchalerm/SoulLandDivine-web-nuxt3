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
    if (dependency === resolve(root, 'server/utils/equipment-quality')) {
      return nativeRequire(`${dependency}.ts`)
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

test('email soul-bone catalog includes every localized item with its image', async () => {
  const namesByType = JSON.parse(readFileSync(resolve(root, 'data/email-item-names.json'), 'utf8'))
  const filenames = new Set(readdirSync(resolve(root, 'public/icons_renamed')))
  const items = await loadItemsHandler([])({})
  const soulBones = items.filter((item) => item.rewardType === '4')
  const soulBoneIds = Object.keys(namesByType['4'])

  assert.equal(soulBoneIds.length, 319)
  assert.equal(soulBones.length, soulBoneIds.length)

  for (const id of soulBoneIds) {
    const item = soulBones.find((soulBone) => soulBone.id === id)
    assert.ok(item, `Soul bone ${id} is missing from the email catalog`)
    assert.equal(item.name, namesByType['4'][id])
    assert.ok(item.iconUrl, `Soul bone ${id} is missing its image`)
    assert.ok(filenames.has(decodeURIComponent(item.iconUrl.split('/').pop())))
  }
})

test('email general item catalog includes every localized item with its image', async () => {
  const namesByType = JSON.parse(readFileSync(resolve(root, 'data/email-item-names.json'), 'utf8'))
  const heroFragmentIcons = JSON.parse(readFileSync(resolve(root, 'data/email-hero-fragment-icons.json'), 'utf8'))
  const numericIconFiles = new Set(readdirSync(resolve(root, 'public/icons_renamed')))
  const heroFragmentIconFiles = new Set(readdirSync(resolve(root, 'public/icons_hero_fragments')))
  const items = await loadItemsHandler([])({})
  const generalItems = items.filter((item) => item.rewardType === '2')

  assert.equal(generalItems.length, Object.keys(namesByType['2']).length)
  assert.equal(Object.keys(heroFragmentIcons).length, 23)
  for (const [id, name] of Object.entries(namesByType['2'])) {
    const item = generalItems.find((candidate) => candidate.id === id)
    assert.ok(item, `General item ${id} is missing from the email catalog`)
    assert.equal(item.name, name)
    assert.ok(item.iconUrl, `General item ${id} is missing its image`)

    const filename = decodeURIComponent(item.iconUrl.split('/').pop())
    const filenames = item.iconUrl.startsWith('/icons_hero_fragments/')
      ? heroFragmentIconFiles
      : numericIconFiles
    assert.ok(filenames.has(filename), `General item ${id} image ${filename} is missing`)
  }

  for (const [id, filename] of Object.entries(heroFragmentIcons)) {
    assert.ok(heroFragmentIconFiles.has(filename), `Hero fragment image ${filename} is missing`)
    assert.equal(
      generalItems.find((item) => item.id === id)?.iconUrl,
      `/icons_hero_fragments/${filename}`,
    )
  }

  assert.equal(
    generalItems.find((item) => item.id === '9996')?.iconUrl,
    '/icons_renamed/9968_gameclient_item1_box9.png',
  )
})

test('email catalog includes every localized item type and all equipment images', async () => {
  const namesByType = JSON.parse(readFileSync(resolve(root, 'data/email-item-names.json'), 'utf8'))
  const equipmentIcons = JSON.parse(readFileSync(resolve(root, 'data/email-equipment-icons.json'), 'utf8'))
  const equipmentFiles = new Set(readdirSync(resolve(root, 'public/icons_equipment')))
  const numericIconFiles = new Set(readdirSync(resolve(root, 'public/icons_renamed')))
  const items = await loadItemsHandler([])({})

  for (const [rewardType, names] of Object.entries(namesByType)) {
    const typeItems = items.filter((item) => item.rewardType === rewardType)
    assert.equal(typeItems.length, Object.keys(names).length, `Incomplete reward type ${rewardType}`)
    for (const [id, name] of Object.entries(names)) {
      const item = typeItems.find((candidate) => candidate.id === id)
      assert.ok(item, `Item ${id} is missing from reward type ${rewardType}`)
      assert.equal(item.name, name)
    }
  }

  const equipmentItems = items.filter((item) => item.rewardType === '5')
  assert.equal(equipmentItems.length, Object.keys(equipmentIcons).length)
  for (const item of equipmentItems) {
    assert.ok(item.iconUrl, `Equipment ${item.id} is missing its image`)
    const filename = decodeURIComponent(item.iconUrl.split('/').pop())
    assert.ok(
      equipmentFiles.has(filename) || numericIconFiles.has(filename),
      `Equipment ${item.id} image ${filename} is missing`,
    )
  }
})

test('email pet eggs use their Game Client icons', async () => {
  const petEggIcons = JSON.parse(readFileSync(resolve(root, 'data/email-pet-egg-icons.json'), 'utf8'))
  const filenames = new Set(readdirSync(resolve(root, 'public/icons_pet_eggs')))
  const items = await loadItemsHandler([])({})
  const petEggs = items.filter((item) => item.rewardType === '21')

  assert.equal(Object.keys(petEggIcons).length, 47)
  assert.equal(petEggs.length, Object.keys(petEggIcons).length)
  for (const [id, icon] of Object.entries(petEggIcons)) {
    const item = petEggs.find((petEgg) => petEgg.id === id)
    assert.ok(item, `Pet egg ${id} is missing from the email catalog`)
    assert.equal(item.iconUrl, `/icons_pet_eggs/${icon}.png`)
    assert.ok(filenames.has(`${icon}.png`), `Missing Game Client pet egg icon ${icon}.png`)
  }
})

test('email hidden weapons use their Game Client icons', async () => {
  const hiddenWeaponIcons = JSON.parse(readFileSync(resolve(root, 'data/email-hidden-weapon-icons.json'), 'utf8'))
  const filenames = new Set(readdirSync(resolve(root, 'public/icons_hidden_weapons')))
  const items = await loadItemsHandler([])({})
  const hiddenWeapons = items.filter((item) => item.rewardType === '13')

  assert.equal(Object.keys(hiddenWeaponIcons).length, 22)
  assert.equal(hiddenWeapons.length, Object.keys(hiddenWeaponIcons).length)
  for (const [id, icon] of Object.entries(hiddenWeaponIcons)) {
    const item = hiddenWeapons.find((hiddenWeapon) => hiddenWeapon.id === id)
    assert.ok(item, `Hidden weapon ${id} is missing from the email catalog`)
    assert.equal(item.iconUrl, `/icons_hidden_weapons/${icon}.png`)
    assert.ok(filenames.has(`${icon}.png`), `Missing Game Client hidden weapon icon ${icon}.png`)
  }
})

test('email item picker excludes task rewards, which are not inventory items', () => {
  const emailPage = readFileSync(resolve(root, 'components/legacy-pages/email/SendEmail.vue'), 'utf8')
  assert.doesNotMatch(emailPage, /value:\s*'6',\s*label:\s*'ภารกิจ'/)
})
