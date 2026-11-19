import type { RowDataPacket } from 'mysql2'
import { cardAdmin } from '../../utils/code-cards'
import { getGameDatabase } from '../../utils/database'
export default defineEventHandler(async event => {
  await cardAdmin(event)
  const [rows] = await getGameDatabase().query<RowDataPacket[]>('SELECT id,name,definition_json,updated_at FROM character_card_templates ORDER BY updated_at DESC LIMIT 200')
  return rows.map(x => ({ id: x.id, name: x.name, definition: JSON.parse(x.definition_json), updatedAt: x.updated_at }))
})
