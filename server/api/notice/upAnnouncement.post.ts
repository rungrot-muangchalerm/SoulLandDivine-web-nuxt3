import { getCookie } from 'h3'
import { getAdminSession } from '../../utils/admin-session'

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  const channel = getCookie(event, 'channel') || ''
  if (!channel || !session.channel?.includes(channel)) {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  }

  const config = useRuntimeConfig()
  if (!config.announcementServiceUrl || !config.announcementServiceToken) {
    throw createError({ statusCode: 503, statusMessage: 'ยังไม่ได้ตั้งค่า announcement service' })
  }
  const form = await readMultipartFormData(event)
  const file = form?.find((part) => part.name === 'file')
  const fileName = form?.find((part) => part.name === 'fileName')?.data.toString()
  if (!file?.data || !fileName || fileName !== fileName.split(/[\\/]/).pop() || fileName.startsWith('.')) {
    throw createError({ statusCode: 400, statusMessage: 'ไฟล์หรือชื่อไฟล์ไม่ถูกต้อง' })
  }

  const payload = new FormData()
  payload.append('file', new Blob([Uint8Array.from(file.data)], { type: file.type || 'application/octet-stream' }), fileName)
  payload.append('fileName', fileName)
  payload.append('token', config.announcementServiceToken)

  const response = await fetch(new URL('/upAnnouncement', config.announcementServiceUrl), {
    method: 'POST',
    body: payload,
    signal: AbortSignal.timeout(30000),
  })
  if (!response.ok) {
    throw createError({ statusCode: 502, statusMessage: `announcement service returned ${response.status}` })
  }
  setHeader(event, 'content-type', response.headers.get('content-type') || 'application/json; charset=utf-8')
  return await response.text()
})
