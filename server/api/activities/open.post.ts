import { getAdminSession } from '../../utils/admin-session'
import { recordOperationLog } from '../../utils/operation-log'
import { openRechargeTabForConfiguredDuration } from '../../utils/activity-schedules'
import { isGachaLinkedRechargeActivity } from '../../../utils/activity-schedule-overrides'

interface ActivityOpenRequest {
  configId?: unknown
  id?: unknown
}

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  }

  const body = await readBody<ActivityOpenRequest>(event)
  if (body?.configId !== 'recharge-tabs' || typeof body.id !== 'number' || !Number.isSafeInteger(body.id)) {
    throw createError({ statusCode: 400, statusMessage: 'ข้อมูลกิจกรรมไม่ถูกต้อง' })
  }
  if (isGachaLinkedRechargeActivity(body.configId, body.id)) {
    throw createError({ statusCode: 409, statusMessage: `กิจกรรม ID ${body.id} ถูกควบคุมตามตู้กาชาเงินคราม ID 24` })
  }

  const result = await openRechargeTabForConfiguredDuration(body.id)
  if (!result) return { configured: false }

  await recordOperationLog({
    username: session.username,
    ip: event.node.req.socket.remoteAddress || '',
    content: JSON.stringify({
      configId: body.configId,
      id: body.id,
      durationDays: result.durationDays,
      fields: result.fields,
    }),
    type: '/activities/open',
  })

  return { configured: true, ...result }
})
