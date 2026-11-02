import { getAdminSession } from '../../utils/admin-session'
import { recordOperationLog } from '../../utils/operation-log'
import { fetchGameAdminApi } from '../../utils/game-admin-api'
import { fetchDrawTimeXml, getGachaPools } from '../../utils/gacha-rate-up'
import { MAX_CHARACTER_RATIO, updateGachaCharacterRate } from '../../utils/gacha-character-rates'

interface CharacterRateRequest {
  drawType?: unknown
  heroId?: unknown
  ratio?: unknown
}

interface GameAdminResponse {
  code?: unknown
  message?: unknown
}

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  }

  const body = await readBody<CharacterRateRequest>(event)
  if (
    typeof body?.drawType !== 'number'
    || !Number.isSafeInteger(body.drawType)
    || body.drawType < 1
  ) {
    throw createError({ statusCode: 400, statusMessage: 'ประเภทตู้กาชาไม่ถูกต้อง' })
  }
  if (typeof body.heroId !== 'number' || !Number.isSafeInteger(body.heroId) || body.heroId < 1) {
    throw createError({ statusCode: 400, statusMessage: 'ID ตัวละครไม่ถูกต้อง' })
  }
  if (
    typeof body.ratio !== 'number'
    || !Number.isSafeInteger(body.ratio)
    || body.ratio < 0
    || body.ratio > MAX_CHARACTER_RATIO
  ) {
    throw createError({ statusCode: 400, statusMessage: `เรทตัวละครต้องเป็นจำนวนเต็มระหว่าง 0 ถึง ${MAX_CHARACTER_RATIO}` })
  }

  const pools = getGachaPools(await fetchDrawTimeXml())
  if (!pools.some((pool) => Number(pool.type) === body.drawType)) {
    throw createError({ statusCode: 404, statusMessage: `ไม่พบตู้กาชาประเภท ${body.drawType}` })
  }

  const currentResponse = await fetchGameAdminApi('/api/gacha/ratio')
  const currentXml = await currentResponse.text()
  const updated = updateGachaCharacterRate(currentXml, body.drawType, body.heroId, body.ratio)
  const saveResponse = await fetchGameAdminApi('/api/gacha/ratio', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(updated.xml),
  })

  let result: GameAdminResponse
  try {
    result = await saveResponse.json() as GameAdminResponse
  } catch {
    throw createError({ statusCode: 502, statusMessage: 'รูปแบบผลลัพธ์จาก Game AdminAPI ไม่ถูกต้อง' })
  }
  if (result.code !== 1) {
    throw createError({
      statusCode: 502,
      statusMessage: typeof result.message === 'string'
        ? `Game AdminAPI บันทึก DrawHeroRatio.xml ไม่สำเร็จ: ${result.message}`
        : 'Game AdminAPI บันทึก DrawHeroRatio.xml ไม่สำเร็จ',
    })
  }

  await recordOperationLog({
    username: session.username,
    ip: event.node.req.socket.remoteAddress || '',
    content: JSON.stringify({
      drawType: body.drawType,
      heroId: body.heroId,
      previousRatio: updated.previousRatio,
      ratio: body.ratio,
    }),
    type: '/gacha/character-rates',
  })

  return {
    drawType: body.drawType,
    characters: updated.characters,
    message: 'บันทึกเรทตัวละครแล้ว',
  }
})
