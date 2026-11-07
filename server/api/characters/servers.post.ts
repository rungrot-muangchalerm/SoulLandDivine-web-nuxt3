import { getAdminSession } from '../../utils/admin-session'
import { getAccountDatabase } from '../../utils/database'

export default defineEventHandler(async (event) => {
  await getAdminSession(event)

  const [rows] = await getAccountDatabase().query(
    'SELECT id, name FROM server_list ORDER BY id',
  )
  return rows
})
