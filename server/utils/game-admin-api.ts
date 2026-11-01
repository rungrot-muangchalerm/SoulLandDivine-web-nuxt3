export async function fetchGameAdminApi(path: string, init: RequestInit = {}) {
  const config = useRuntimeConfig()
  if (
    typeof config.gameAdminApiUrl !== 'string'
    || !config.gameAdminApiUrl
    || typeof config.gameAdminApiToken !== 'string'
    || !config.gameAdminApiToken
  ) {
    throw createError({
      statusCode: 503,
      statusMessage: 'กรุณาตั้งค่า ADMIN_API_URL และ ADMIN_API_TOKEN ในไฟล์ .env',
    })
  }

  let url: URL
  try {
    url = new URL(path.replace(/^\/+/, ''), `${config.gameAdminApiUrl.replace(/\/+$/, '')}/`)
  } catch {
    throw createError({ statusCode: 500, statusMessage: 'ADMIN_API_URL ไม่ถูกต้อง' })
  }
  if (!['http:', 'https:'].includes(url.protocol)) {
    throw createError({ statusCode: 500, statusMessage: 'ADMIN_API_URL ต้องใช้ HTTP หรือ HTTPS' })
  }

  const headers = new Headers(init.headers)
  headers.set('token', config.gameAdminApiToken)

  let response: Response
  try {
    response = await fetch(url, {
      ...init,
      headers,
      signal: init.signal || AbortSignal.timeout(30000),
    })
  } catch (error) {
    const message = error instanceof Error ? error.message : 'เชื่อมต่อ AdminAPI ไม่สำเร็จ'
    throw createError({ statusCode: 502, statusMessage: message })
  }

  if (!response.ok) {
    const hint = response.status === 403
      ? ' (ตรวจสอบ ADMIN_API_TOKEN)'
      : ''
    throw createError({
      statusCode: 502,
      statusMessage: `Game AdminAPI ตอบกลับ HTTP ${response.status}${hint}`,
    })
  }

  return response
}
