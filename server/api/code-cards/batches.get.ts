import type { RowDataPacket } from 'mysql2'
import { cardAdmin } from '../../utils/code-cards'
import { getGameDatabase } from '../../utils/database'
export default defineEventHandler(async event => {
  await cardAdmin(event)
  const [rows] = await getGameDatabase().query<RowDataPacket[]>('SELECT b.id,b.name,b.quantity,b.created_at,COUNT(CASE WHEN c.status=\'used\' THEN 1 END) AS used FROM character_card_batches b LEFT JOIN character_card_codes c ON c.batch_id=b.id GROUP BY b.id ORDER BY b.created_at DESC LIMIT 100')
  return rows
})
