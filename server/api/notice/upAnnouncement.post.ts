import { getAdminSession } from '../../utils/admin-session'
import { fetchGameAdminApi } from '../../utils/game-admin-api'

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
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

  const response = await fetchGameAdminApi('/upAnnouncement', {
    method: 'POST',
    body: payload,
  })
  setHeader(event, 'content-type', response.headers.get('content-type') || 'application/json; charset=utf-8')
  return await response.text()
})
