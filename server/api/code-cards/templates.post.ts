import { randomUUID } from 'node:crypto'
import { cardAdmin, cardInput, updateCardTemplate } from '../../utils/code-cards'
import { recordOperationLog } from '../../utils/operation-log'
export default defineEventHandler(async event => {
  const session = await cardAdmin(event)
  const body = await readBody(event)
  const definition = cardInput(body.definition)
  const id = typeof body.id === 'string' && /^[0-9a-f-]{36}$/.test(body.id) ? body.id : randomUUID()
  const updatedReady = await updateCardTemplate(id, definition, session.username)
  await recordOperationLog({ username: session.username, ip: event.node.req.socket.remoteAddress || '', type: '/code-cards/templates', content: JSON.stringify({ id, name: definition.name, updatedReady }) })
  return { id, updatedReady }
})
