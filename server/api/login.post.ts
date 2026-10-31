import { deleteCookie, setCookie } from 'h3'
import { getGameDatabase } from '../utils/database'
import { createSession, TOKEN_COOKIE, TOKEN_LIFETIME_SECONDS } from '../utils/admin-session'

interface LoginBody {
  username?: string
  password?: string
}

export default defineEventHandler(async (event) => {
  const body = await readBody<LoginBody>(event)
  const username = body.username?.trim()
  const password = body.password
  if (!username || !password) {
    throw createError({ statusCode: 400, statusMessage: 'กรุณากรอกข้อมูลให้ครบถ้วน' })
  }

  const [rows] = await getGameDatabase().execute(
    'SELECT username, password, authorization FROM `admin_user` WHERE username = ? LIMIT 1',
    [username],
  )
  const user = (rows as Array<{
    username: string
    password: string
    authorization: string
  }>)[0]

  if (!user || user.password !== password) {
    throw createError({ statusCode: 401, statusMessage: 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง' })
  }
  const token = await createSession(event, username)
  const cookieOptions = {
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    maxAge: TOKEN_LIFETIME_SECONDS,
    path: '/',
  } as const
  deleteCookie(event, 'userRandom', { path: '/' })
  deleteCookie(event, 'channel', { path: '/' })
  setCookie(event, TOKEN_COOKIE, token, cookieOptions)
  setCookie(event, 'username', user.username, {
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    maxAge: TOKEN_LIFETIME_SECONDS,
    path: '/',
  })
  return {
    code: 1,
    message: 'เข้าสู่ระบบสำเร็จ',
    authorization: user.authorization === 'senior' ? 'admin' : user.authorization,
  }
})
