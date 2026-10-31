import { getCookie } from 'h3'
import { getAdminSession } from '../../utils/admin-session'
import { getDatabase } from '../../utils/database'

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  const channel = getCookie(event, 'channel') || ''
  if (!channel || !session.channel?.includes(channel)) {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  }
  if (!['admin', 'server'].includes(session.authorization)) {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์จัดการช่องทาง' })
  }

  const [rows] = await getDatabase().query(
    'SELECT id, name, `index`, ip, url FROM channel_list ORDER BY id',
  )
  return rows
})
