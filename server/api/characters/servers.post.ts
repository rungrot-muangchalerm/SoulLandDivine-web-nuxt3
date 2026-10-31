import { getCookie } from 'h3'
import { getAdminSession } from '../../utils/admin-session'
import { getGameDatabase } from '../../utils/database'

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  const channel = getCookie(event, 'channel') || ''
  if (!channel || !session.channel?.includes(channel)) {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  }

  const [rows] = await getGameDatabase().query(
    'SELECT id, name FROM server_list ORDER BY id',
  )
  return rows
})
