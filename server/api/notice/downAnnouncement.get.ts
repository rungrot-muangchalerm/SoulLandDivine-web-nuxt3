import { getAdminSession } from '../../utils/admin-session'
import { fetchGameAdminApi } from '../../utils/game-admin-api'

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  }

  const fileName = getQuery(event).fileName
  if (typeof fileName !== 'string' || fileName !== fileName.split(/[\\/]/).pop() || fileName.startsWith('.')) {
    throw createError({ statusCode: 400, statusMessage: 'ชื่อไฟล์ไม่ถูกต้อง' })
  }
  const query = new URLSearchParams({ fileName })
  const response = await fetchGameAdminApi(`/downAnnouncement?${query}`)
  setHeader(event, 'content-type', response.headers.get('content-type') || 'application/octet-stream')
  setHeader(event, 'content-disposition', `attachment; filename="${encodeURIComponent(fileName)}"`)
  return Buffer.from(await response.arrayBuffer())
})
