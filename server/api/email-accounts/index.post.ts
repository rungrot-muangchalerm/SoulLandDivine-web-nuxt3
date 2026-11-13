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
    const contactUrl = typeof body.contactUrl === 'string' ? body.contactUrl.trim() : ''
    if (body.contactUrl != null && typeof body.contactUrl !== 'string') throw createError({ statusCode: 400, statusMessage: 'Invalid contact URL' })
    if (contactUrl) {
      try {
        const url = new URL(contactUrl)
        if (contactUrl.length > 2048 || !['http:', 'https:'].includes(url.protocol) || url.username || url.password) throw new Error('Invalid URL')
      } catch {
        throw createError({ statusCode: 400, statusMessage: 'กรุณากรอกลิงก์ติดต่อที่ขึ้นต้นด้วย https:// หรือ http://' })
      }
    }
    try {
      if (id) {
        const [result] = await db.execute<ResultSetHeader>('UPDATE admin_email_accounts SET email=?, password_plaintext=COALESCE(?, password_plaintext), contact_url=COALESCE(?, contact_url) WHERE id=?', [email, storedPassword, body.contactUrl === undefined ? null : contactUrl, id])
        if (!result.affectedRows) throw createError({ statusCode: 404, statusMessage: 'Not found' })
      } else await db.execute('INSERT INTO admin_email_accounts (email, password_plaintext, contact_url) VALUES (?, ?, ?)', [email, storedPassword, contactUrl])
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
