import type { RowDataPacket } from 'mysql2/promise'
import { getAdminSession } from '../../utils/admin-session'
import { getDatabase } from '../../utils/database'
import { monthInBangkok } from '../../utils/email-vault'

export default defineEventHandler(async event => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') throw createError({ statusCode: 403, statusMessage: 'Admin only' })
  setHeader(event, 'Cache-Control', 'no-store')
  const month = monthInBangkok()
  const [rows] = await getDatabase().execute<RowDataPacket[]>('SELECT id, email, used_month FROM admin_email_accounts ORDER BY id DESC')
  return { month, accounts: rows.map(row => ({ id: row.id, email: row.email, used: row.used_month === month })) }
})
