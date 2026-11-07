import { getAdminSession } from '../../utils/admin-session'
import { getAccountDatabase, getGameDatabase } from '../../utils/database'
import { recordOperationLog } from '../../utils/operation-log'

interface PlayerResourcesBody {
  serverId?: number | string
  uid?: number | string
  exp?: number | string
  gold?: number | string
  diamond?: number | string
}

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  const body = await readBody<PlayerResourcesBody>(event)
  const serverId = Number(body.serverId)
  const uid = Number(body.uid)
  const exp = Number(body.exp)
  const gold = Number(body.gold)
  const diamond = Number(body.diamond)

  if (!Number.isSafeInteger(serverId) || serverId <= 0
    || !Number.isSafeInteger(uid) || uid <= 0
    || [exp, gold, diamond].some(value => !Number.isSafeInteger(value) || value < 0 || value > 4_294_967_295)
  ) {
    throw createError({ statusCode: 400, statusMessage: 'ข้อมูลทรัพยากรไม่ถูกต้อง' })
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

  const [characterRows] = await database.execute(
    'SELECT c.uid FROM `character` c JOIN character_resource r ON r.uid = c.uid WHERE c.uid = ? AND c.uid >= ? AND c.uid < ? LIMIT 1',
    [uid, serverUidStart, serverUidEnd],
  )
  if (!(characterRows as Array<{ uid: number }>).length) {
    throw createError({ statusCode: 404, statusMessage: 'ไม่พบตัวละครหรือข้อมูลทรัพยากรในเซิร์ฟเวอร์ที่เลือก' })
  }

  await database.execute(
    'UPDATE character_resource SET exp = ?, gold = ?, diamond = ? WHERE uid = ?',
    [exp, gold, diamond, uid],
  )
  await recordOperationLog({
    username: session.username,
    ip: event.node.req.socket.remoteAddress || '',
    content: JSON.stringify({ serverId, uid, exp, gold, diamond }),
    type: '/players/resources',
  })

  return { result: 1 }
})
