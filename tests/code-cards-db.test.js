import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import { randomUUID } from 'node:crypto'
import mysql from 'mysql2/promise'
import ts from 'typescript'

try { process.loadEnvFile('.env') } catch (e) { if (e.code !== 'ENOENT') throw e }
const settings = { host: process.env.GAMEDB_HOST || process.env.DB_HOST || '127.0.0.1', port: Number(process.env.GAMEDB_PORT || process.env.DB_PORT || 3306), user: process.env.GAMEDB_USER || process.env.DB_USER || 'root', password: process.env.GAMEDB_PASSWORD || process.env.DB_PASSWORD || '' }
const catalog = JSON.parse(readFileSync(new URL('../data/code-card-catalog.json', import.meta.url)))
const loadModule = async source => import(`data:text/javascript;base64,${Buffer.from(ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.ESNext } }).outputText).toString('base64')}`)
const helpers = await loadModule(readFileSync(new URL('../utils/code-card.ts', import.meta.url), 'utf8'))
Object.assign(globalThis, {
  __cardHelpers: helpers,
  __cardCatalog: catalog,
  useRuntimeConfig: () => ({ adminJwtSecret: 'test-only-encryption-secret-32-bytes-not-for-login' }),
  createError: ({ statusCode, statusMessage }) => Object.assign(new Error(statusMessage), { statusCode }),
})
let source = readFileSync(new URL('../server/utils/code-cards.ts', import.meta.url), 'utf8')
source = source.replace(/import \{ getAdminSession \}[^\n]+/, 'const getAdminSession = async e => e.session')
  .replace(/import \{ getGameDatabase \}[^\n]+/, 'const getGameDatabase = () => globalThis.__cardDb')
  .replace(/import \{ buildCardRewards, validateCard, matchesHeroEquipmentJob, normalizeCardEquipmentStars \}[^\n]+/, 'const { buildCardRewards, validateCard, matchesHeroEquipmentJob, normalizeCardEquipmentStars } = globalThis.__cardHelpers')
  .replace(/import catalog[^\n]+/, 'const catalog = globalThis.__cardCatalog')
const { generateCards, decryptCardCode, updateCardTemplate, cardInput } = await loadModule(source)

test('real DB issuance is idempotent, encrypted and immutable after editing template', async () => {
  const dbName = `code_cards_webtest_${randomUUID().replaceAll('-', '')}`
  const admin = await mysql.createConnection(settings)
  let pool
  try {
    await admin.query(`CREATE DATABASE \`${dbName}\` CHARACTER SET utf8mb4`)
    pool = mysql.createPool({ ...settings, database: dbName, connectionLimit: 6 })
    globalThis.__cardDb = pool
    const migration = readFileSync(new URL('../../SoulLandDivine-server/docs/database/migrations/2026-11-19-code-cards.sql', import.meta.url), 'utf8')
    for (const sql of migration.replace(/^--.*$/gm, '').split(';').filter(x => x.trim())) await pool.query(sql)
    const definition = structuredClone(catalog.defaultCard)
    const heroJob = catalog.heroes.find(h => h.id === definition.heroId)?.job
    assert.ok(Number.isInteger(heroJob))
    definition.equipment = ['weapon', 'neck', 'ring', 'wrist', 'boots'].map((slot, i) => ({ id: i === 0 ? catalog.weapons[0].id : catalog.equipment.find(x => x.slot === slot && x.job === heroJob).id, stars: 0, level: 0 }))
    const templateId = randomUUID(), requestId = randomUUID()
    await pool.execute('INSERT INTO character_card_templates (id,name,definition_json,created_by) VALUES (?,?,?,?)', [templateId, definition.name, JSON.stringify(definition), 'tester'])
    const invalidDefinition = structuredClone(definition)
    invalidDefinition.equipment[1].id = catalog.equipment.find(x => x.slot === 'neck' && x.job !== heroJob).id
    const invalidId = randomUUID()
    await pool.execute('INSERT INTO character_card_templates (id,name,definition_json,created_by) VALUES (?,?,?,?)', [invalidId, invalidDefinition.name, JSON.stringify(invalidDefinition), 'tester'])
    await assert.rejects(generateCards({}, invalidId, 1, 'tester', randomUUID()), /Job/)
    const results = await Promise.all(Array.from({ length: 4 }, () => generateCards({}, templateId, 2, 'tester', requestId)))
    assert.ok(results.every(x => x.batchId === requestId))
    const [codes] = await pool.query('SELECT * FROM character_card_codes')
    assert.equal(codes.length, 2)
    assert.notEqual(codes[0].code_hash, codes[1].code_hash)
    assert.match(decryptCardCode(codes[0].code_ciphertext, {}), /^SLC-[0-9A-F]{8}-[0-9A-F]{8}-[0-9A-F]{8}$/)
    assert.equal(codes[0].reward_string.split('|').length, 16)
    definition.talentValue = 0
    await pool.execute('UPDATE character_card_templates SET definition_json=? WHERE id=?', [JSON.stringify(definition), templateId])
    const [snapshots] = await pool.query('SELECT snapshot_json FROM character_card_codes')
    assert.equal(JSON.parse(snapshots[0].snapshot_json).talentValue, 35)
    await assert.rejects(generateCards({}, templateId, 3, 'tester', requestId), /คำขอ/)
    await assert.rejects(generateCards({}, templateId, 2, 'another-user', requestId), /คำขอ/)
    definition.equipment[0].id = ''
    await pool.execute('UPDATE character_card_templates SET definition_json=? WHERE id=?', [JSON.stringify(definition), templateId])
    await assert.rejects(generateCards({}, templateId, 1, 'tester', randomUUID()), /equipment/)
    // Regression: issuing an old code must deliver the edited rings, but a
    // redeemed code and its recorded mail must remain unchanged.
    definition.equipment[0].id = catalog.weapons[0].id
    const [oldCodes] = await pool.query('SELECT id,reward_string,snapshot_json FROM character_card_codes ORDER BY id')
    await pool.execute(
      "UPDATE character_card_codes SET status='used',redeemed_uid=12345,redeemed_at=NOW(),email_uid=9999 WHERE id=?",
      [oldCodes[0].id],
    )
    const previousRing = definition.rings[0].id
    const replacementRing = catalog.rings.find(x => x.id !== previousRing).id
    definition.rings[0].id = replacementRing
    const updatedCount = await updateCardTemplate(templateId, cardInput(definition), 'tester')
    assert.equal(updatedCount, 1)
    const [after] = await pool.query('SELECT id,status,reward_string,snapshot_json,redeemed_uid,email_uid FROM character_card_codes ORDER BY id')
    assert.equal(after[0].reward_string, oldCodes[0].reward_string, 'redeemed gift was modified')
    assert.equal(after[0].snapshot_json, oldCodes[0].snapshot_json, 'redeemed snapshot was modified')
    assert.equal(after[0].redeemed_uid, 12345)
    assert.equal(after[0].email_uid, 9999)
    assert.equal(after[1].status, 'ready')
    assert.ok(after[1].reward_string.includes(replacementRing + ':3:1@'))
    assert.ok(!after[1].reward_string.includes(previousRing + ':3:1@'), 'old ring still sent to player')
    assert.equal(JSON.parse(after[1].snapshot_json).rings[0].id, replacementRing)
    const invalidUpdated = structuredClone(definition)
    invalidUpdated.rings[0].id = ''
    await assert.rejects(updateCardTemplate(templateId, cardInput(invalidUpdated), 'tester'), /วงแหวน|rings/)
    const [[stillReady]] = await pool.query('SELECT reward_string FROM character_card_codes WHERE id=?', [after[1].id])
    assert.equal(stillReady.reward_string, after[1].reward_string, 'failed edit modified live gift')
    const [[count]] = await pool.query('SELECT COUNT(*) AS n FROM character_card_batches')
    assert.equal(count.n, 1)
  } finally {
    if (pool) await pool.end()
    if (!/^code_cards_webtest_[a-f0-9]{32}$/.test(dbName)) throw new Error('Unsafe test schema')
    await admin.query(`DROP DATABASE IF EXISTS \`${dbName}\``)
    await admin.end()
  }
})
