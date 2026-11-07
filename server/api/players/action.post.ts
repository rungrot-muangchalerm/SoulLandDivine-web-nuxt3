import { getAdminSession } from '../../utils/admin-session'
import { getAccountDatabase, getGameDatabase } from '../../utils/database'
import { recordOperationLog } from '../../utils/operation-log'

interface PlayerActionBody {
  serverId?: number | string
  uid?: number | string
  action?: 'silence' | 'unsilence' | 'freeze' | 'unfreeze'
  duration?: number | string
  reason?: string
}

const inactiveTime = '2010-01-01 08:00:00'

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  const body = await readBody<PlayerActionBody>(event)
  const serverId = Number(body.serverId)
  const uid = Number(body.uid)
  if (!Number.isSafeInteger(serverId) || serverId <= 0 || !Number.isSafeInteger(uid) || uid <= 0) {
    throw createError({ statusCode: 400, statusMessage: 'รหัสเซิร์ฟเวอร์หรือ UID ไม่ถูกต้อง' })
  }
  if (!['silence', 'unsilence', 'freeze', 'unfreeze'].includes(body.action || '')) {
    throw createError({ statusCode: 400, statusMessage: 'ไม่รองรับการดำเนินการนี้' })
  }
  const action = body.action as NonNullable<PlayerActionBody['action']>
  const reason = body.reason?.trim() || ''
  if (reason.length > 64) {
    throw createError({ statusCode: 400, statusMessage: 'เหตุผลต้องไม่เกิน 64 ตัวอักษร' })
  }

  const serverUidStart = serverId * 100_000
  const serverUidEnd = (serverId + 1) * 100_000
  if (uid < serverUidStart || uid >= serverUidEnd) {
    throw createError({ statusCode: 403, statusMessage: 'UID ไม่อยู่ในเซิร์ฟเวอร์ที่เลือก' })
  }

  const database = getGameDatabase()
  const [serverRows] = await getAccountDatabase().execute(
    'SELECT id FROM server_list WHERE id = ? LIMIT 1',
    [serverId],
  )
  if (!(serverRows as Array<{ id: number }>).length) {
    throw createError({ statusCode: 404, statusMessage: 'ไม่พบเซิร์ฟเวอร์ที่เลือก' })
  }

  const duration = Number(body.duration)
  if (action === 'silence' || action === 'freeze') {
    const maxDuration = action === 'silence' ? 525_600 : 8_760
    if (!Number.isSafeInteger(duration) || duration <= 0 || duration > maxDuration) {
      throw createError({ statusCode: 400, statusMessage: 'ระยะเวลาที่ระบุไม่ถูกต้อง' })
    }
  }

  const [characterRows] = await database.execute(
    'SELECT uid FROM `character` WHERE uid = ? AND uid >= ? AND uid < ? LIMIT 1',
    [uid, serverUidStart, serverUidEnd],
  )
  if (!(characterRows as Array<{ uid: number }>).length) {
    throw createError({ statusCode: 404, statusMessage: 'ไม่พบตัวละครในเซิร์ฟเวอร์ที่เลือก' })
  }

  let result: unknown
  if (action === 'silence') {
    ;[result] = await database.execute(
      'UPDATE `character` SET silenceTime = DATE_ADD(NOW(), INTERVAL ? MINUTE), silenceReason = ? WHERE uid = ? AND uid >= ? AND uid < ?',
      [duration, reason, uid, serverUidStart, serverUidEnd],
    )
  } else if (action === 'unsilence') {
    ;[result] = await database.execute(
      'UPDATE `character` SET silenceTime = ?, silenceReason = ? WHERE uid = ? AND uid >= ? AND uid < ?',
      [inactiveTime, '', uid, serverUidStart, serverUidEnd],
    )
  } else if (action === 'freeze') {
    ;[result] = await database.execute(
      'UPDATE `character` SET freezeState = 1, freezeTime = DATE_ADD(NOW(), INTERVAL ? HOUR), freezeReason = ? WHERE uid = ? AND uid >= ? AND uid < ?',
      [duration, reason, uid, serverUidStart, serverUidEnd],
    )
  } else {
    ;[result] = await database.execute(
      'UPDATE `character` SET freezeState = 0, freezeTime = ?, freezeReason = ? WHERE uid = ? AND uid >= ? AND uid < ?',
      [inactiveTime, '', uid, serverUidStart, serverUidEnd],
    )
  }

  await recordOperationLog({
    username: session.username,
    ip: event.node.req.socket.remoteAddress || '',
    content: JSON.stringify({ serverId, uid, action, duration: body.duration, reason }),
    type: `/players/${action}`,
  })

  return { result: Number((result as { affectedRows?: number }).affectedRows || 0) || 1 }
})
