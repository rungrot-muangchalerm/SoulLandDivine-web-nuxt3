import type { RowDataPacket } from 'mysql2'
import { cardAdmin, decryptCardCode } from '../../utils/code-cards'
import { getGameDatabase } from '../../utils/database'
import { ARCHIVE_PAGE_SIZE, normalizeArchivePage } from '../../../utils/code-card-archive'

export default defineEventHandler(async event => {
  await cardAdmin(event)
  const page = normalizeArchivePage(getQuery(event).page)
  const database = getGameDatabase()
  const [counts] = await database.query<RowDataPacket[]>('SELECT COUNT(*) AS total FROM character_card_codes')
  const total = Number(counts[0]?.total ?? 0)
  const [rows] = await database.execute<RowDataPacket[]>(
    'SELECT c.id,c.code_ciphertext,c.status,c.snapshot_json,c.redeemed_uid,c.redeemed_at FROM character_card_codes c JOIN character_card_batches b ON b.id=c.batch_id ORDER BY b.created_at DESC, c.id DESC LIMIT ? OFFSET ?',
    [ARCHIVE_PAGE_SIZE, (page - 1) * ARCHIVE_PAGE_SIZE],
  )
  return {
    page,
    total,
    cards: rows.map(x => ({
      id: String(x.id),
      code: decryptCardCode(x.code_ciphertext, event),
      status: x.status,
      definition: JSON.parse(x.snapshot_json),
      redeemedUid: x.redeemed_uid,
      redeemedAt: x.redeemed_at,
    })),
  }
})