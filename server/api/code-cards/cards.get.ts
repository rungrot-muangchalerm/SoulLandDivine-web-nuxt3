import type { RowDataPacket } from 'mysql2'
import { cardAdmin, decryptCardCode } from '../../utils/code-cards'
import { getGameDatabase } from '../../utils/database'
export default defineEventHandler(async event => {
  await cardAdmin(event)
  const batchId = getQuery(event).batchId
  if (typeof batchId !== 'string' || !/^[0-9a-f-]{36}$/.test(batchId)) throw createError({ statusCode: 400, statusMessage: 'ชุดบัตรไม่ถูกต้อง' })
  const [rows] = await getGameDatabase().execute<RowDataPacket[]>('SELECT id,code_ciphertext,status,snapshot_json,redeemed_uid,redeemed_at FROM character_card_codes WHERE batch_id=? ORDER BY id LIMIT 200', [batchId])
  return rows.map(x => ({ id: String(x.id), code: decryptCardCode(x.code_ciphertext, event), status: x.status, definition: JSON.parse(x.snapshot_json), redeemedUid: x.redeemed_uid, redeemedAt: x.redeemed_at }))
})
