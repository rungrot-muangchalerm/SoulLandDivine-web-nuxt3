import { withGachaWriteLock } from '../../utils/gacha-write-lock'
import { getAdminSession } from '../../utils/admin-session'
import { recordOperationLog } from '../../utils/operation-log'
import { fetchGameAdminApi } from '../../utils/game-admin-api'
import { fetchDrawTimeXml, getGachaPool } from '../../utils/gacha-rate-up'
import { updateCustomGachaConfig } from '../../utils/custom-gacha-config'

export default defineEventHandler(async (event) => withGachaWriteLock(async () => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  const pool = getGachaPool(await fetchDrawTimeXml(), 10000)
  if (pool.type !== '10000') throw createError({ statusCode: 409, statusMessage: 'ตู้ปรับแต่งยังไม่ได้แยก Type 10000' })
  const current = await fetchGameAdminApi('/api/gacha/quality')
  const updated = updateCustomGachaConfig(await current.text(), await readBody(event))
  const response = await fetchGameAdminApi('/api/gacha/quality', {
    method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(updated.xml),
  })
  const result = await response.json() as { code?: number, message?: string }
  if (result.code !== 1) throw createError({ statusCode: 502, statusMessage: result.message || 'บันทึกกติกาตู้ไม่สำเร็จ' })
  await recordOperationLog({ username: session.username, ip: event.node.req.socket.remoteAddress || '',
    content: JSON.stringify({ drawType: 10000, config: updated.config }), type: '/gacha/custom-config' })
  return { config: updated.config, message: 'บันทึกกติกาตู้ปรับแต่งและส่งอัปเดตเข้าเกมแล้ว' }
}))
