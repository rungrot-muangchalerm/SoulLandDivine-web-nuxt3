import { deleteCookie } from 'h3'
import { revokeSession, TOKEN_COOKIE } from '../utils/admin-session'

export default defineEventHandler(async (event) => {
  try {
    await revokeSession(event)
  } finally {
    deleteCookie(event, TOKEN_COOKIE, { path: '/' })
    deleteCookie(event, 'userRandom', { path: '/' })
    deleteCookie(event, 'username', { path: '/' })
    deleteCookie(event, 'channel', { path: '/' })
  }
  return sendRedirect(event, '/login')
})
