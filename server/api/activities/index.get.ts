import { getAdminSession } from '../../utils/admin-session'
import { activityScheduleConfigs, fetchActivitySchedules } from '../../utils/activity-schedules'

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  }

  return {
    configs: activityScheduleConfigs,
    activities: await fetchActivitySchedules(),
  }
})
