import { deleteCookie, getCookie, type H3Event } from 'h3'
import { randomUUID } from 'node:crypto'
import { getGameDatabase } from './database'

export interface AdminSession {
  username: string
  authorization: string
  channel: string
}

export async function getAdminSession(event: H3Event) {
  const sessionId = getCookie(event, 'userRandom')
  if (!sessionId) {
    throw createError({ statusCode: 401, statusMessage: 'กรุณาเข้าสู่ระบบ' })
  }

  const [rows] = await getGameDatabase().execute(
    'SELECT username, authorization, channel FROM `admin_user` WHERE userRandom = ? LIMIT 1',
    [sessionId],
  )
  const row = (rows as Array<AdminSession>)[0]
  if (!row) {
    deleteCookie(event, 'userRandom', { path: '/' })
    throw createError({ statusCode: 401, statusMessage: 'กรุณาเข้าสู่ระบบอีกครั้ง' })
  }
  if (row.authorization === 'senior') {
    row.authorization = 'admin'
  }
  return row
}

export async function createSession(username: string) {
  const sessionId = randomUUID()
  await getGameDatabase().execute(
    'UPDATE `admin_user` SET userRandom = ? WHERE username = ?',
    [sessionId, username],
  )
  return sessionId
}
