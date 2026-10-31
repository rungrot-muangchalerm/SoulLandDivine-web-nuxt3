import { getCookie } from 'h3'
import { getAdminSession } from '../../utils/admin-session'
import { getGameDatabase } from '../../utils/database'
import { recordOperationLog } from '../../utils/operation-log'

interface SearchBody {
  serverId?: number | string
  uid?: number | string
  name?: string
}

interface CharacterRow {
  uid: number
  name: string
  sex: number
  accountName: string
  online: boolean | null
  timeCreated: string | null
  lastLoginTime: string | null
  silenceTime: string | null
  freezeTime: string | null
  level: number
  exp: number
  gold: number
  diamond: number
  accumulateTotal: number
}

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  const channel = getCookie(event, 'channel') || ''
  if (!channel || !session.channel?.includes(channel)) {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  }

  const body = await readBody<SearchBody>(event)
  const serverId = Number(body.serverId)
  const uidText = body.uid === undefined || body.uid === null ? '' : String(body.uid).trim()
  const name = body.name?.trim() || ''
  if (!Number.isSafeInteger(serverId) || serverId <= 0) {
    throw createError({ statusCode: 400, statusMessage: 'รหัสเซิร์ฟเวอร์ไม่ถูกต้อง' })
  }
  if ((!uidText && !name) || (uidText && !/^\d{1,10}$/.test(uidText)) || name.length > 64) {
    throw createError({ statusCode: 400, statusMessage: 'กรุณาระบุ UID หรือชื่อตัวละครให้ถูกต้อง' })
  }

  const [serverRows] = await getGameDatabase().execute(
    'SELECT id FROM server_list WHERE id = ? LIMIT 1',
    [serverId],
  )
  if (!(serverRows as Array<{ id: number }>).length) {
    throw createError({ statusCode: 404, statusMessage: 'ไม่พบเซิร์ฟเวอร์ที่เลือก' })
  }

  const serverUidStart = serverId * 100_000
  const serverUidEnd = (serverId + 1) * 100_000
  const filters = ['c.uid >= ?', 'c.uid < ?']
  const values: Array<number | string> = [serverUidStart, serverUidEnd]
  if (uidText) {
    filters.push('c.uid = ?')
    values.push(Number(uidText))
  }
  if (name) {
    filters.push('c.charName = ?')
    values.push(name)
  }

  const [rows] = await getGameDatabase().execute(
    `SELECT
      c.uid,
      c.charName AS name,
      c.sex,
      c.accountName,
      NULL AS online,
      DATE_FORMAT(c.createdTime, '%Y-%m-%d %H:%i:%s') AS timeCreated,
      DATE_FORMAT(c.lastLoginTime, '%Y-%m-%d %H:%i:%s') AS lastLoginTime,
      DATE_FORMAT(c.silenceTime, '%Y-%m-%d %H:%i:%s') AS silenceTime,
      DATE_FORMAT(c.freezeTime, '%Y-%m-%d %H:%i:%s') AS freezeTime,
      c.level,
      COALESCE(r.exp, 0) AS exp,
      COALESCE(r.gold, 0) AS gold,
      COALESCE(r.diamond, 0) AS diamond,
      COALESCE(w.accumulate_total, 0) AS accumulateTotal
    FROM \`character\` c
    LEFT JOIN character_resource r ON r.uid = c.uid
    LEFT JOIN recharge w ON w.pc_uid = c.uid
    WHERE ${filters.join(' AND ')}
    LIMIT 2`,
    values,
  )

  const characters = rows as CharacterRow[]
  if (characters.length > 1) {
    throw createError({
      statusCode: 409,
      statusMessage: 'พบชื่อตัวละครซ้ำ กรุณาค้นหาด้วย UID',
    })
  }

  await recordOperationLog({
    username: session.username,
    ip: event.node.req.socket.remoteAddress || '',
    content: JSON.stringify({ serverId, uid: uidText || undefined, name: name || undefined, channel }),
    type: '/characters/search',
  })
  return characters[0] || null
})
