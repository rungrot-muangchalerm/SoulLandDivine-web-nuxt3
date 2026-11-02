import { getAdminSession } from '../../utils/admin-session'
import { fetchDrawTimeXml, getGachaPools } from '../../utils/gacha-rate-up'

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  }

  return getGachaPools(await fetchDrawTimeXml())
})
