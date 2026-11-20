import { readFileSync } from 'node:fs'
import mysql from 'mysql2/promise'
import ts from 'typescript'

if (!['--dry-run', '--apply'].includes(process.argv[2]) || process.argv.length !== 3) {
  console.error('Usage: node scripts/sync-ready-card-rewards.mjs --dry-run|--apply')
  process.exit(2)
}
const apply = process.argv[2] === '--apply'
try { process.loadEnvFile('.env') } catch (error) {
  if (error.code !== 'ENOENT') throw error
}
const source = readFileSync(new URL('../utils/code-card.ts', import.meta.url), 'utf8')
const compiled = ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.ESNext } }).outputText
const { validateCard, buildCardRewards } = await import('data:text/javascript;base64,' + Buffer.from(compiled).toString('base64'))

const database = mysql.createPool({
  host: process.env.GAMEDB_HOST || process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.GAMEDB_PORT || process.env.DB_PORT || 3306),
  user: process.env.GAMEDB_USER || process.env.DB_USER || 'root',
  password: process.env.GAMEDB_PASSWORD || process.env.DB_PASSWORD || '',
  database: process.env.GAMEDB_NAME || 'gamedb_cmdl',
  connectionLimit: 2,
})
let total = 0, matched = 0, invalid = 0
try {
  const [templates] = await database.query(
    "SELECT t.id,t.definition_json,COUNT(c.id) AS ready_count FROM character_card_templates t JOIN character_card_batches b ON b.template_id=t.id JOIN character_card_codes c ON c.batch_id=b.id AND c.status='ready' AND c.redeemed_uid IS NULL AND c.email_uid IS NULL GROUP BY t.id,t.definition_json"
  )
  for (const template of templates) {
    let snapshot, rewards
    try {
      const definition = validateCard(JSON.parse(template.definition_json))
      snapshot = JSON.stringify(definition)
      rewards = buildCardRewards(definition)
    } catch (error) {
      invalid++
      console.log('SKIP incomplete template', template.id)
      continue
    }
    const connection = await database.getConnection()
    try {
      await connection.beginTransaction()
      // Locking the template row serializes reconciliation with new batch issuance.
      const [locked] = await connection.execute('SELECT id FROM character_card_templates WHERE id=? FOR UPDATE', [template.id])
      if (!locked.length) throw new Error('Template disappeared while reconciling')
      const fresh = validateCard(JSON.parse((await connection.execute('SELECT definition_json FROM character_card_templates WHERE id=?', [template.id]))[0][0].definition_json))
      const freshSnapshot = JSON.stringify(fresh)
      const freshRewards = buildCardRewards(fresh)
      const [rows] = await connection.execute(
        "SELECT COUNT(*) AS count FROM character_card_codes c JOIN character_card_batches b ON b.id=c.batch_id WHERE b.template_id=? AND c.status='ready' AND c.redeemed_uid IS NULL AND c.email_uid IS NULL AND (c.reward_string<>? OR c.snapshot_json<>?)",
        [template.id, freshRewards, freshSnapshot],
      )
      const mismatched = Number(rows[0].count)
      if (apply && mismatched) {
        const [result] = await connection.execute(
          "UPDATE character_card_codes c JOIN character_card_batches b ON b.id=c.batch_id SET c.reward_string=?,c.snapshot_json=? WHERE b.template_id=? AND c.status='ready' AND c.redeemed_uid IS NULL AND c.email_uid IS NULL AND (c.reward_string<>? OR c.snapshot_json<>?)",
          [freshRewards, freshSnapshot, template.id, freshRewards, freshSnapshot],
        )
        if (result.affectedRows !== mismatched) throw new Error('Concurrent code changes; reconciliation rolled back for template ' + template.id)
      }
      if (apply) await connection.commit()
      else await connection.rollback()
      total += mismatched
      matched += Number(template.ready_count)
    } catch (error) {
      await connection.rollback()
      throw error
    } finally { connection.release() }
  }
  console.log(JSON.stringify({ mode: apply ? 'applied' : 'dry-run', activeReady: matched, mismatchedReady: total, invalidTemplatesSkipped: invalid, redeemedCodesChanged: 0 }))
} finally { await database.end() }
