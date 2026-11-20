import { createCipheriv, createDecipheriv, createHash, randomBytes } from 'node:crypto'
import type { RowDataPacket } from 'mysql2'
import type { H3Event } from 'h3'
import { getAdminSession } from './admin-session'
import { getGameDatabase } from './database'
import { buildCardRewards, validateCard, matchesHeroEquipmentJob, normalizeCardEquipmentStars } from '../../utils/code-card'
import catalog from '../../data/code-card-catalog.json'

export async function cardAdmin(event: H3Event) {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') throw createError({ statusCode: 403, statusMessage: 'เฉพาะผู้ดูแลระบบ' })
  if (event.method !== 'GET') {
    const origin = getHeader(event, 'origin')
    if (getHeader(event, 'sec-fetch-site') === 'cross-site' || (origin && new URL(origin).host !== getHeader(event, 'host'))) {
      throw createError({ statusCode: 403, statusMessage: 'ไม่อนุญาตคำขอจากเว็บไซต์อื่น' })
    }
  }
  setHeader(event, 'Cache-Control', 'no-store')
  return session
}
function encryptionKey(event: H3Event) {
  const secret = useRuntimeConfig(event).adminJwtSecret
  if (typeof secret !== 'string' || secret.length < 32) throw createError({ statusCode: 503, statusMessage: 'ยังไม่ได้ตั้งค่ากุญแจระบบ' })
  return createHash('sha256').update(`character-card:${secret}`).digest()
}
function encrypt(code: string, key: Buffer) {
  const iv = randomBytes(12)
  const cipher = createCipheriv('aes-256-gcm', key, iv)
  const bytes = Buffer.concat([cipher.update(code, 'utf8'), cipher.final()])
  return Buffer.concat([iv, cipher.getAuthTag(), bytes]).toString('base64')
}
export function decryptCardCode(value: string, event: H3Event) {
  const bytes = Buffer.from(value, 'base64')
  const cipher = createDecipheriv('aes-256-gcm', encryptionKey(event), bytes.subarray(0, 12))
  cipher.setAuthTag(bytes.subarray(12, 28))
  return Buffer.concat([cipher.update(bytes.subarray(28)), cipher.final()]).toString('utf8')
}
export function cardInput(input: unknown) {
  try {
    const card = validateCard(input)
    const has = (items: Array<{ id: string }>, id: string) => !id || items.some(x => x.id === id)
    if (!has(catalog.heroes, card.heroId) || !has(catalog.weapons, card.equipment[0].id)
      || card.equipment.slice(1).some((x, i) => x.id && !catalog.equipment.some(e => e.id === x.id && e.slot === ['neck', 'ring', 'wrist', 'boots'][i])) || card.rings.some(x => !has(catalog.rings, x.id))) throw new Error('ไม่พบรายการรางวัลในข้อมูลเกม หรืออุปกรณ์ไม่ตรงช่อง')
    const hero = catalog.heroes.find(h => h.id === card.heroId)
    if (card.equipment.slice(1).some(e => e.id)) {
      if (!hero) throw new Error('กรุณาเลือกตัวละครก่อนเลือกอุปกรณ์')
      if (card.equipment.slice(1).some(e => {
        if (!e.id) return false
        const equipment = catalog.equipment.find(x => x.id === e.id)
        return !equipment || !matchesHeroEquipmentJob(hero.job, equipment.job)
      })) throw new Error('อุปกรณ์ไม่ตรงประเภท Job ของตัวละคร กรุณาเลือกอุปกรณ์ที่ตัวละครสวมใส่ได้')
    }
    for (const ring of card.rings) {
      if (!ring.elementId) continue
      const match = catalog.rings.find(x => x.id === ring.id)
      if (ring.year < 100000 || !match?.elementIds?.includes(ring.elementId)) {
        throw new Error('ออฟธาตุที่เลือกไม่ตรงชนิดวงแหวนหรืออายุยังไม่ถึงแสนปี')
      }
    }
    return normalizeCardEquipmentStars(card, catalog.equipment)
  } catch (error) {
    throw createError({ statusCode: 400, statusMessage: error instanceof Error ? error.message : 'ข้อมูลบัตรไม่ถูกต้อง' })
  }
}
export async function generateCards(event: H3Event, templateId: string, quantity: number, username: string, batchId: string) {
  if (!Number.isSafeInteger(quantity) || quantity < 1 || quantity > 200) throw createError({ statusCode: 400, statusMessage: 'เจนได้ครั้งละ 1–200 ใบ' })
  const key = encryptionKey(event)
  const connection = await getGameDatabase().getConnection()
  try {
    await connection.beginTransaction()
    const [rows] = await connection.execute<RowDataPacket[]>('SELECT name,definition_json FROM character_card_templates WHERE id=? FOR UPDATE', [templateId])
    if (!rows.length) throw createError({ statusCode: 404, statusMessage: 'ไม่พบแม่แบบ' })
    const [previous] = await connection.execute<RowDataPacket[]>('SELECT template_id,quantity,created_by FROM character_card_batches WHERE id=?', [batchId])
    if (previous.length) {
      if (previous[0].template_id !== templateId || previous[0].quantity !== quantity || previous[0].created_by !== username) throw createError({ statusCode: 409, statusMessage: 'คำขอเจนชุดนี้ถูกใช้แล้ว กรุณารีเฟรชหน้า' })
      await connection.commit()
      return { batchId, quantity }
    }
    const card = cardInput(JSON.parse(rows[0].definition_json))
    let rewards: string
    try { rewards = buildCardRewards(card) } catch (e) { throw createError({ statusCode: 400, statusMessage: (e as Error).message }) }
    const snapshot = JSON.stringify(card)
    await connection.execute('INSERT INTO character_card_batches (id,template_id,name,quantity,snapshot_json,created_by) VALUES (?,?,?,?,?,?)', [batchId, templateId, card.name, quantity, snapshot, username])
    for (let i = 0; i < quantity; i++) {
      const raw = `SLC${randomBytes(12).toString('hex').toUpperCase()}`
      const display = `SLC-${raw.slice(3, 11)}-${raw.slice(11, 19)}-${raw.slice(19)}`
      await connection.execute('INSERT INTO character_card_codes (code_hash,code_ciphertext,batch_id,status,reward_string,snapshot_json) VALUES (?,?,?,\'ready\',?,?)', [createHash('sha256').update(raw).digest('hex'), encrypt(display, key), batchId, rewards, snapshot])
    }
    await connection.commit()
    return { batchId, quantity }
  } catch (error) {
    await connection.rollback()
    throw error
  } finally { connection.release() }
}

/**
 * Save the editable template and synchronize gift payloads for codes that
 * have not yet been redeemed. The game's code redemption transaction locks the
 * same code row; redeemed codes and dispatched emails must remain immutable.
 */
export async function updateCardTemplate(id: string, definition: ReturnType<typeof cardInput>, username: string) {
  const connection = await getGameDatabase().getConnection()
  try {
    await connection.beginTransaction()
    await connection.execute(
      'INSERT INTO character_card_templates (id,name,definition_json,created_by) VALUES (?,?,?,?) ON DUPLICATE KEY UPDATE name=VALUES(name),definition_json=VALUES(definition_json)',
      [id, definition.name, JSON.stringify(definition), username],
    )
    // Issuing a new batch locks the template row first, so this transaction
    // cannot race a batch created from an older template.
    const [ready] = await connection.execute<RowDataPacket[]>(
      "SELECT c.id FROM character_card_codes c JOIN character_card_batches b ON b.id=c.batch_id WHERE b.template_id=? AND c.status='ready' AND c.redeemed_uid IS NULL AND c.email_uid IS NULL LIMIT 1 FOR UPDATE",
      [id],
    )
    let updatedReady = 0
    if (ready.length) {
      let rewards: string
      try { rewards = buildCardRewards(definition) } catch (error) {
        throw createError({ statusCode: 400, statusMessage: 'แม่แบบยังไม่พร้อมสำหรับโค้ดที่ออกไว้: ' + (error as Error).message })
      }
      const [result] = await connection.execute(
        "UPDATE character_card_codes c JOIN character_card_batches b ON b.id=c.batch_id SET c.reward_string=?,c.snapshot_json=? WHERE b.template_id=? AND c.status='ready' AND c.redeemed_uid IS NULL AND c.email_uid IS NULL",
        [rewards, JSON.stringify(definition), id],
      )
      updatedReady = (result as { affectedRows: number }).affectedRows
    }
    await connection.commit()
    return updatedReady
  } catch (error) {
    await connection.rollback()
    throw error
  } finally {
    connection.release()
  }
}
