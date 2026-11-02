import { getAdminSession } from '../../utils/admin-session'
import { recordOperationLog } from '../../utils/operation-log'
import { saveActivitySchedule } from '../../utils/activity-schedules'

interface ActivityScheduleRequest {
  configId?: unknown
  id?: unknown
  fields?: unknown
}

function isStringRecord(value: unknown): value is Record<string, string> {
  return Boolean(
    value
    && typeof value === 'object'
    && !Array.isArray(value)
    && Object.values(value).every((item) => typeof item === 'string'),
  )
}

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  }

  const body = await readBody<ActivityScheduleRequest>(event)
  if (
    typeof body?.configId !== 'string'
    || typeof body.id !== 'number'
    || !isStringRecord(body.fields)
  ) {
    throw createError({ statusCode: 400, statusMessage: 'ข้อมูลตารางเวลากิจกรรมไม่ถูกต้อง' })
  }

  const fields = body.fields
  await saveActivitySchedule(body.configId, body.id, fields)
  await recordOperationLog({
    username: session.username,
    ip: event.node.req.socket.remoteAddress || '',
    content: JSON.stringify({ configId: body.configId, id: body.id, fields }),
    type: '/activities/schedule',
  })

  return { message: 'บันทึกตารางเวลากิจกรรมแล้ว' }
})
