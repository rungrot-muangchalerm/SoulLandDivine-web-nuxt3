import { createHmac, randomUUID, timingSafeEqual } from 'node:crypto'
import { deleteCookie, getCookie, type H3Event } from 'h3'
import { getGameDatabase } from './database'

const TOKEN_COOKIE = 'admin_token'
const TOKEN_LIFETIME_SECONDS = 60 * 60 * 2

interface AdminTokenPayload {
  sub: string
  jti: string
  channel: string
  iat: number
  exp: number
}

export interface AdminSession {
  username: string
  authorization: string
  channel: string
}

declare module 'h3' {
  interface H3EventContext {
    adminSession?: AdminSession
    adminChannel?: string
  }
}

function getJwtSecret(event: H3Event) {
  const secret = useRuntimeConfig(event).adminJwtSecret
  if (typeof secret !== 'string' || Buffer.byteLength(secret) < 32) {
    throw createError({
      statusCode: 500,
      statusMessage: 'ต้องตั้งค่า ADMIN_JWT_SECRET เป็น secret แบบสุ่มอย่างน้อย 32 bytes',
    })
  }
  return secret
}

function encode(value: string | Buffer) {
  return Buffer.from(value).toString('base64url')
}

function signature(input: string, secret: string) {
  return createHmac('sha256', secret).update(input).digest()
}

function signToken(payload: AdminTokenPayload, secret: string) {
  const header = encode(JSON.stringify({ alg: 'HS256', typ: 'JWT' }))
  const body = encode(JSON.stringify(payload))
  const unsignedToken = `${header}.${body}`
  return `${unsignedToken}.${encode(signature(unsignedToken, secret))}`
}

function verifyToken(token: string | undefined, secret: string): AdminTokenPayload {
  if (!token) {
    throw createError({ statusCode: 401, statusMessage: 'กรุณาเข้าสู่ระบบ' })
  }

  const parts = token.split('.')
  if (parts.length !== 3) {
    throw createError({ statusCode: 401, statusMessage: 'เซสชันไม่ถูกต้อง กรุณาเข้าสู่ระบบอีกครั้ง' })
  }

  const [encodedHeader, encodedPayload, encodedSignature] = parts
  const expectedSignature = signature(`${encodedHeader}.${encodedPayload}`, secret)
  let actualSignature: Buffer
  let header: unknown
  let payload: unknown
  try {
    actualSignature = Buffer.from(encodedSignature, 'base64url')
    header = JSON.parse(Buffer.from(encodedHeader, 'base64url').toString('utf8'))
    payload = JSON.parse(Buffer.from(encodedPayload, 'base64url').toString('utf8'))
  } catch {
    throw createError({ statusCode: 401, statusMessage: 'เซสชันไม่ถูกต้อง กรุณาเข้าสู่ระบบอีกครั้ง' })
  }

  if (
    actualSignature.length !== expectedSignature.length
    || !timingSafeEqual(actualSignature, expectedSignature)
    || !header
    || typeof header !== 'object'
    || (header as { alg?: unknown }).alg !== 'HS256'
    || (header as { typ?: unknown }).typ !== 'JWT'
    || !payload
    || typeof payload !== 'object'
  ) {
    throw createError({ statusCode: 401, statusMessage: 'เซสชันไม่ถูกต้อง กรุณาเข้าสู่ระบบอีกครั้ง' })
  }

  const claims = payload as Partial<AdminTokenPayload>
  const now = Math.floor(Date.now() / 1000)
  if (
    typeof claims.sub !== 'string'
    || !claims.sub
    || typeof claims.jti !== 'string'
    || !claims.jti
    || typeof claims.channel !== 'string'
    || !claims.channel
    || typeof claims.iat !== 'number'
    || typeof claims.exp !== 'number'
    || claims.exp <= now
    || claims.iat > now
  ) {
    throw createError({ statusCode: 401, statusMessage: 'เซสชันหมดอายุหรือไม่ถูกต้อง กรุณาเข้าสู่ระบบอีกครั้ง' })
  }
  return claims as AdminTokenPayload
}

function clearAuthCookies(event: H3Event) {
  deleteCookie(event, TOKEN_COOKIE, { path: '/' })
  deleteCookie(event, 'userRandom', { path: '/' })
  deleteCookie(event, 'username', { path: '/' })
  deleteCookie(event, 'channel', { path: '/' })
}

function channelAllowed(userChannels: string, channel: string) {
  return userChannels.split(',').map((item) => item.trim()).includes(channel)
}

export async function getAdminSession(event: H3Event): Promise<AdminSession> {
  if (event.context.adminSession) return event.context.adminSession

  const token = getCookie(event, TOKEN_COOKIE)
  if (!token) {
    throw createError({ statusCode: 401, statusMessage: 'กรุณาเข้าสู่ระบบ' })
  }
  const secret = getJwtSecret(event)
  const claims = verifyToken(token, secret)
  const [rows] = await getGameDatabase().execute(
    'SELECT username, authorization, channel, userRandom FROM `admin_user` WHERE username = ? LIMIT 1',
    [claims.sub],
  )
  const row = (rows as Array<AdminSession & { userRandom: string | null }>)[0]
  const selectedChannel = getCookie(event, 'channel') || ''
  if (
    !row
    || row.userRandom !== claims.jti
    || !channelAllowed(row.channel, claims.channel)
    || selectedChannel !== claims.channel
  ) {
    clearAuthCookies(event)
    throw createError({ statusCode: 401, statusMessage: 'เซสชันหมดอายุหรือถูกยกเลิก กรุณาเข้าสู่ระบบอีกครั้ง' })
  }

  if (row.authorization === 'senior') {
    row.authorization = 'admin'
  }
  event.context.adminSession = row
  event.context.adminChannel = claims.channel
  return row
}

export async function createSession(event: H3Event, username: string, channel: string) {
  const secret = getJwtSecret(event)
  const jti = randomUUID()
  await getGameDatabase().execute(
    'UPDATE `admin_user` SET userRandom = ? WHERE username = ?',
    [jti, username],
  )
  const now = Math.floor(Date.now() / 1000)
  const payload: AdminTokenPayload = {
    sub: username,
    jti,
    channel,
    iat: now,
    exp: now + TOKEN_LIFETIME_SECONDS,
  }
  return signToken(payload, secret)
}

export async function revokeSession(event: H3Event) {
  const token = getCookie(event, TOKEN_COOKIE)
  if (!token) return

  let claims: AdminTokenPayload
  try {
    claims = verifyToken(token, getJwtSecret(event))
  } catch (error) {
    if (error && typeof error === 'object' && 'statusCode' in error && error.statusCode === 401) return
    throw error
  }
  await getGameDatabase().execute(
    'UPDATE `admin_user` SET userRandom = NULL WHERE username = ? AND userRandom = ?',
    [claims.sub, claims.jti],
  )
}

export { TOKEN_COOKIE, TOKEN_LIFETIME_SECONDS }
