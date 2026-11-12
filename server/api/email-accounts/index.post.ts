import type { ResultSetHeader, RowDataPacket } from 'mysql2/promise'
import { getAdminSession } from '../../utils/admin-session'
import { getDatabase } from '../../utils/database'
import { monthInBangkok } from '../../utils/email-vault'

export default defineEventHandler(async event => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') throw createError({ statusCode: 403, statusMessage: 'Admin only' })
  setHeader(event, 'Cache-Control', 'no-store')
  const body = await readBody(event)
  const db = getDatabase()
  const action = body?.action
  if (!['save', 'used', 'delete', 'reveal'].includes(action)) throw createError({ statusCode: 400, statusMessage: 'Invalid action' })
  const id = body.id
  if ((action !== 'save' || id !== undefined) && (!Number.isSafeInteger(id) || id <= 0)) throw createError({ statusCode: 400, statusMessage: 'Invalid ID' })
  if (action === 'save') {
    const email = typeof body.email === 'string' ? body.email.trim() : ''
    const password = body.password
    if (email.length > 254 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || typeof password !== 'string' || password.length > 4096 || (!id && !password)) {
      throw createError({ statusCode: 400, statusMessage: 'Invalid email or password' })
    }
    const storedPassword = password || null
    try {
      if (id) {
        const [result] = await db.execute<ResultSetHeader>('UPDATE admin_email_accounts SET email=?, password_plaintext=COALESCE(?, password_plaintext) WHERE id=?', [email, storedPassword, id])
        if (!result.affectedRows) throw createError({ statusCode: 404, statusMessage: 'Not found' })
      } else await db.execute('INSERT INTO admin_email_accounts (email, password_plaintext) VALUES (?, ?)', [email, storedPassword])
    } catch (error: any) {
      if (error.code === 'ER_DUP_ENTRY') throw createError({ statusCode: 409, statusMessage: 'Email already exists' })
      throw error
    }
  } else if (action === 'reveal') {
    const [rows] = await db.execute<RowDataPacket[]>('SELECT password_plaintext FROM admin_email_accounts WHERE id=?', [id])
    if (!rows.length) throw createError({ statusCode: 404, statusMessage: 'Not found' })
    return { password: rows[0].password_plaintext }
  } else {
    if (action === 'used' && typeof body.used !== 'boolean') throw createError({ statusCode: 400, statusMessage: 'Invalid used flag' })
    const [result] = action === 'delete'
      ? await db.execute<ResultSetHeader>('DELETE FROM admin_email_accounts WHERE id=?', [id])
      : await db.execute<ResultSetHeader>('UPDATE admin_email_accounts SET used_month=? WHERE id=?', [body.used ? monthInBangkok() : null, id])
    if (!result.affectedRows) throw createError({ statusCode: 404, statusMessage: 'Not found' })
  }
  return { ok: true }
})
