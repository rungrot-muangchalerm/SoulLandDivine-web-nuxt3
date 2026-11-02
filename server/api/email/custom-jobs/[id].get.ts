import { getAdminSession } from '../../../utils/admin-session'
import { getCustomEmailJob } from '../../../utils/custom-email-queue'

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  const jobId = getRouterParam(event, 'id') || ''
  const job = getCustomEmailJob(jobId)

  if (!job) {
    throw createError({ statusCode: 404, statusMessage: 'ไม่พบงานส่งอีเมล หรือข้อมูลหมดอายุแล้ว' })
  }
  const activeChannel = event.context.adminChannel
  if (
    job.username !== session.username
    || (activeChannel !== '*' && job.channel !== activeChannel)
  ) {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ดูสถานะงานนี้' })
  }

  return job
})
