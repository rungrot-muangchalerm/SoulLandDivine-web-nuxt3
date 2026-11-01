import { getAdminSession } from '../../utils/admin-session'
import { fetchGameAdminApi } from '../../utils/game-admin-api'

interface EmailTemplate {
  id: number
  title: string
  reward: string
  type: number
  validityDate: number
}

interface EmailTemplateResponse {
  code: number
  count: number
  templates: EmailTemplate[]
}

export default defineEventHandler(async (event) => {
  await getAdminSession(event)

  const response = await fetchGameAdminApi('/api/email/templates')
  const data = await response.json() as Partial<EmailTemplateResponse>
  if (
    data.code !== 1
    || !Array.isArray(data.templates)
    || data.templates.some((template) =>
      !template
      || !Number.isSafeInteger(template.id)
      || typeof template.title !== 'string'
      || typeof template.reward !== 'string',
    )
  ) {
    throw createError({ statusCode: 502, statusMessage: 'รูปแบบรายการ Email template จาก Game AdminAPI ไม่ถูกต้อง' })
  }

  return data.templates
})
