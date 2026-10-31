import { setCookie } from 'h3'
import { getGameDatabase } from '../utils/database'
import { createSession } from '../utils/admin-session'

interface LoginBody {
  username?: string
  password?: string
  channel?: string
}

export default defineEventHandler(async (event) => {
  const body = await readBody<LoginBody>(event)
  const username = body.username?.trim()
  const password = body.password
  const channel = body.channel
  if (!username || !password || !channel) {
    throw createError({ statusCode: 400, statusMessage: 'กรุณากรอกข้อมูลให้ครบถ้วน' })
  }

  const [rows] = await getGameDatabase().execute(
    'SELECT username, password, authorization, channel FROM `admin_user` WHERE username = ? LIMIT 1',
    [username],
  )
  const user = (rows as Array<{
    username: string
    password: string
    authorization: string
    channel: string
  }>)[0]

  if (!user || user.password !== password) {
    throw createError({ statusCode: 401, statusMessage: 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง' })
  }
  if (!user.channel?.includes(channel)) {
    throw createError({ statusCode: 403, statusMessage: 'ผู้ใช้นี้ไม่มีสิทธิ์ในช่องทางที่เลือก' })
  }

  const sessionId = await createSession(username)
  setCookie(event, 'userRandom', sessionId, {
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    maxAge: 60 * 60 * 2,
    path: '/',
  })
  setCookie(event, 'username', user.username, {
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    maxAge: 60 * 60 * 2,
    path: '/',
  })
  setCookie(event, 'channel', channel, {
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    maxAge: 60 * 60 * 2,
    path: '/',
  })
  return {
    code: 1,
    message: 'เข้าสู่ระบบสำเร็จ',
    authorization: user.authorization === 'senior' ? 'admin' : user.authorization,
  }
})
