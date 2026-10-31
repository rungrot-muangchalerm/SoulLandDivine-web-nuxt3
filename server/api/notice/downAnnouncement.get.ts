import { getCookie } from 'h3'
import { getAdminSession } from '../../utils/admin-session'

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  const channel = getCookie(event, 'channel') || ''
  if (!channel || !session.channel?.includes(channel)) {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  }

  const fileName = getQuery(event).fileName
  if (typeof fileName !== 'string' || fileName !== fileName.split(/[\\/]/).pop() || fileName.startsWith('.')) {
    throw createError({ statusCode: 400, statusMessage: 'ชื่อไฟล์ไม่ถูกต้อง' })
  }
  const serviceUrl = useRuntimeConfig().announcementServiceUrl
  if (!serviceUrl) {
    throw createError({ statusCode: 503, statusMessage: 'ยังไม่ได้ตั้งค่า announcement service' })
  }

  const upstreamUrl = new URL('/downAnnouncement', serviceUrl)
  upstreamUrl.searchParams.set('fileName', fileName)
  const response = await fetch(upstreamUrl, { signal: AbortSignal.timeout(30000) })
  if (!response.ok) {
    throw createError({ statusCode: 502, statusMessage: `announcement service returned ${response.status}` })
  }
  setHeader(event, 'content-type', response.headers.get('content-type') || 'application/octet-stream')
  setHeader(event, 'content-disposition', `attachment; filename="${encodeURIComponent(fileName)}"`)
  return Buffer.from(await response.arrayBuffer())
})
