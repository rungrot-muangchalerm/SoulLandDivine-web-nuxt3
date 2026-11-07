import { getAdminSession } from '../../utils/admin-session'
import { publishClientUpdate } from '../../utils/client-updates'
import { recordOperationLog } from '../../utils/operation-log'

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') {
    throw createError({ statusCode: 403, statusMessage: 'ต้องใช้สิทธิ์ผู้ดูแลระบบเพื่อเผยแพร่ client update' })
  }

  const manifest = await publishClientUpdate(event, await readBody(event))
  await recordOperationLog({
    username: session.username,
    ip: event.node.req.socket.remoteAddress || '',
    content: JSON.stringify({
      platform: manifest.platform,
      version: manifest.version,
      minimumVersion: manifest.minimumVersion,
      sha256: manifest.sha256,
      size: manifest.size,
    }),
    type: '/client-update/publish',
  })
  return { manifest, message: `เผยแพร่ ${manifest.platform} ${manifest.version} แล้ว` }
})
