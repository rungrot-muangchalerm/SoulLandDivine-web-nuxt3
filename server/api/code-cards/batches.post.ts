import { cardAdmin, generateCards } from '../../utils/code-cards'
import { recordOperationLog } from '../../utils/operation-log'
export default defineEventHandler(async event => {
  const session = await cardAdmin(event)
  const body = await readBody(event)
  if (typeof body.templateId !== 'string' || !/^[0-9a-f-]{36}$/.test(body.templateId)) throw createError({ statusCode: 400, statusMessage: 'กรุณาเลือกแม่แบบ' })
  if (typeof body.requestId !== 'string' || !/^[0-9a-f-]{36}$/.test(body.requestId)) throw createError({ statusCode: 400, statusMessage: 'รหัสคำขอไม่ถูกต้อง' })
  const result = await generateCards(event, body.templateId, body.quantity, session.username, body.requestId)
  await recordOperationLog({ username: session.username, ip: event.node.req.socket.remoteAddress || '', type: '/code-cards/generate', content: JSON.stringify({ ...result, templateId: body.templateId }) })
  return result
})
