import { getAdminSession } from '../../utils/admin-session'
import { fetchGameAdminApi } from '../../utils/game-admin-api'
import { fetchDrawTimeXml, getGachaPools } from '../../utils/gacha-rate-up'
import { getGachaCharacterRates } from '../../utils/gacha-character-rates'

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  }

  const drawType = Number(getQuery(event).drawType)
  if (!Number.isSafeInteger(drawType) || drawType < 1) {
    throw createError({ statusCode: 400, statusMessage: 'ประเภทตู้กาชาไม่ถูกต้อง' })
  }

  const pools = getGachaPools(await fetchDrawTimeXml())
  if (!pools.some((pool) => Number(pool.type) === drawType)) {
    throw createError({ statusCode: 404, statusMessage: `ไม่พบตู้กาชาประเภท ${drawType}` })
  }

  const response = await fetchGameAdminApi('/api/gacha/ratio')
  return {
    drawType,
    characters: getGachaCharacterRates(await response.text(), drawType),
  }
})
