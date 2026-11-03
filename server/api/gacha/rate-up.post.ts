import { withGachaWriteLock } from '../../utils/gacha-write-lock'
import { getAdminSession } from '../../utils/admin-session'
import { recordOperationLog } from '../../utils/operation-log'
import { fetchGameAdminApi } from '../../utils/game-admin-api'
import {
  fetchDrawTimeXml,
  formatLocalDateTime,
  getGachaPool,
  parseLocalDateTime,
  updateGachaPoolSchedule,
} from '../../utils/gacha-rate-up'

interface RateUpRequest {
  action?: unknown
  endTime?: unknown
  poolId?: unknown
}

interface GameAdminResponse {
  code?: unknown
  message?: unknown
}

export default defineEventHandler(async (event) => withGachaWriteLock(async () => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  }

  const body = await readBody<RateUpRequest>(event)
  const action = body?.action
  if (action !== 'open' && action !== 'close') {
    throw createError({ statusCode: 400, statusMessage: 'คำสั่งเปิดหรือปิดตู้ไม่ถูกต้อง' })
  }
  const poolId = body.poolId
  if (typeof poolId !== 'number' || !Number.isSafeInteger(poolId) || poolId < 1) {
    throw createError({ statusCode: 400, statusMessage: 'กรุณาเลือกตู้กาชาที่ต้องการจัดการ' })
  }

  const xml = await fetchDrawTimeXml()
  const previous = getGachaPool(xml, poolId)
  const now = new Date()
  let beginTime = previous.beginTime
  let endTime: string

  if (action === 'open') {
    if (typeof body.endTime !== 'string' || !/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/.test(body.endTime)) {
      throw createError({ statusCode: 400, statusMessage: 'กรุณาระบุเวลาปิดตู้ให้ถูกต้อง' })
    }
    const end = parseLocalDateTime(`${body.endTime.replace('T', ' ')}:00`)
    if (!end || end <= now) {
      throw createError({ statusCode: 400, statusMessage: 'เวลาปิดตู้ต้องอยู่หลังเวลาปัจจุบัน' })
    }
    beginTime = formatLocalDateTime(now)
    endTime = formatLocalDateTime(end)
  } else {
    endTime = formatLocalDateTime(new Date(now.getTime() - 1000))
    // A missing start date means permanent in the game server's legacy model.
    // Use a complete past interval even when this pool was never opened before.
    beginTime = formatLocalDateTime(new Date(now.getTime() - 2000))
  }

  const xmlContent = updateGachaPoolSchedule(xml, poolId, beginTime, endTime)
  const response = await fetchGameAdminApi('/api/gacha/time', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(xmlContent),
  })

  let result: GameAdminResponse
  try {
    result = await response.json() as GameAdminResponse
  } catch {
    throw createError({ statusCode: 502, statusMessage: 'รูปแบบผลลัพธ์จาก Game AdminAPI ไม่ถูกต้อง' })
  }
  if (result.code !== 1) {
    throw createError({
      statusCode: 502,
      statusMessage: typeof result.message === 'string'
        ? `Game AdminAPI บันทึก DrawTime.xml ไม่สำเร็จ: ${result.message}`
        : 'Game AdminAPI บันทึก DrawTime.xml ไม่สำเร็จ',
    })
  }

  await recordOperationLog({
    username: session.username,
    ip: event.node.req.socket.remoteAddress || '',
    content: JSON.stringify({ poolId, action, beginTime, endTime }),
    type: '/gacha/rate-up',
  })

  return {
    ...getGachaPool(xmlContent, poolId),
    message: action === 'open' ? 'บันทึกเปิดตู้และส่งอัปเดตเข้าเกมแล้ว' : 'บันทึกปิดตู้และส่งอัปเดตเข้าเกมแล้ว',
  }
}))
