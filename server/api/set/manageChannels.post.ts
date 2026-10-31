import { getAdminSession } from '../../utils/admin-session'
import { getDatabase } from '../../utils/database'

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  if (!['admin', 'server'].includes(session.authorization)) {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์จัดการช่องทาง' })
  }

  const [rows] = await getDatabase().query(
    'SELECT id, name, `index`, ip, url FROM channel_list ORDER BY id',
  )
  return rows
})
