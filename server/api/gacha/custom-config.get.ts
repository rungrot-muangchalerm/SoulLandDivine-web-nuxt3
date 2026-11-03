import { getAdminSession } from '../../utils/admin-session'
import { fetchGameAdminApi } from '../../utils/game-admin-api'
import { fetchDrawTimeXml, getGachaPool } from '../../utils/gacha-rate-up'
import { getCustomGachaConfig } from '../../utils/custom-gacha-config'

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  const pool = getGachaPool(await fetchDrawTimeXml(), 10000)
  if (pool.type !== '10000') throw createError({ statusCode: 409, statusMessage: 'ตู้ 10000 ยังใช้ Type ร่วมกับตู้เดิม ต้องแยกข้อมูล server ก่อน' })
  const response = await fetchGameAdminApi('/api/gacha/quality')
  return getCustomGachaConfig(await response.text())
})
