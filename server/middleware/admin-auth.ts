import { getRequestURL } from 'h3'
import { getAdminSession } from '../utils/admin-session'

const publicApiPaths = new Set([
  '/api/login',
  '/api/logout',
  '/api/set/searchChannel',
  '/api/client-update/manifest',
  '/api/client-update/download/windows',
  '/api/client-update/download/android',
])

export default defineEventHandler(async (event) => {
  const pathname = getRequestURL(event).pathname
  if (!pathname.startsWith('/api/') || publicApiPaths.has(pathname)) return

  await getAdminSession(event)
})
