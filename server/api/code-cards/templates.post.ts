import { randomUUID } from 'node:crypto'
import { cardAdmin, cardInput } from '../../utils/code-cards'
import { getGameDatabase } from '../../utils/database'
import { recordOperationLog } from '../../utils/operation-log'
export default defineEventHandler(async event => {
  const session = await cardAdmin(event)
  const body = await readBody(event)
  const definition = cardInput(body.definition)
  const id = typeof body.id === 'string' && /^[0-9a-f-]{36}$/.test(body.id) ? body.id : randomUUID()
  await getGameDatabase().execute('INSERT INTO character_card_templates (id,name,definition_json,created_by) VALUES (?,?,?,?) ON DUPLICATE KEY UPDATE name=VALUES(name),definition_json=VALUES(definition_json)', [id, definition.name, JSON.stringify(definition), session.username])
  await recordOperationLog({ username: session.username, ip: event.node.req.socket.remoteAddress || '', type: '/code-cards/templates', content: JSON.stringify({ id, name: definition.name }) })
  return { id }
})
