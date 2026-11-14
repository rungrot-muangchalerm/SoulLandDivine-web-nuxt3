import { getAdminSession } from '../../../utils/admin-session'
import { recordOperationLog } from '../../../utils/operation-log'
import { saveActivitySchedules, type ActivityScheduleBatchUpdate } from '../../../utils/activity-schedules'
import {
  getGachaLinkedRechargeActivityMessage,
  isGachaLinkedRechargeActivity,
  isProtectedRechargeActivity,
} from '../../../../utils/activity-schedule-overrides'

interface ActivityScheduleBatchRequest {
  configId?: unknown
  updates?: unknown
}

function isBatchUpdate(value: unknown): value is ActivityScheduleBatchUpdate {
  return Boolean(
    value
    && typeof value === 'object'
    && !Array.isArray(value)
    && typeof (value as { id?: unknown }).id === 'number',
  )
}

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  }

  const body = await readBody<ActivityScheduleBatchRequest>(event)
  if (
    typeof body?.configId !== 'string'
    || !Array.isArray(body.updates)
    || body.updates.length === 0
    || !body.updates.every(isBatchUpdate)
  ) {
    throw createError({ statusCode: 400, statusMessage: 'ข้อมูลชุดตารางเวลากิจกรรมไม่ถูกต้อง' })
  }

  const updates = body.updates
  for (const update of updates) {
    if (isGachaLinkedRechargeActivity(body.configId, update.id)) {
      throw createError({
        statusCode: 409,
        statusMessage: getGachaLinkedRechargeActivityMessage(body.configId, update.id)
          ?? 'กิจกรรมนี้ถูกควบคุมตามตู้กาชาที่เกี่ยวข้อง',
      })
    }
    if (
      isProtectedRechargeActivity(body.configId, update.id)
      && (update.openForConfiguredDuration === true
        || (update.fields?.ShowStart === '' && update.fields?.ShowEnd === ''))
    ) {
      throw createError({ statusCode: 400, statusMessage: 'กิจกรรม ID ' + update.id + ' ห้ามปิดระบบ' })
    }
  }

  const result = await saveActivitySchedules(body.configId, updates)
  if (!result.configured) return result

  await recordOperationLog({
    username: session.username,
    ip: event.node.req.socket.remoteAddress || '',
    content: JSON.stringify({
      configId: body.configId,
      updates: updates.map(({ id, fields, openForConfiguredDuration }) => ({
        id,
        ...(openForConfiguredDuration ? { openForConfiguredDuration: true } : {}),
        ...(fields ? { fields } : {}),
      })),
    }),
    type: '/activities/schedule/batch',
  })

  return result
})
