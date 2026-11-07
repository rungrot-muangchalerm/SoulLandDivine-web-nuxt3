import { getQuery } from 'h3'
import { stat } from 'node:fs/promises'
import { getClientUpdateArtifactPath, isClientUpdatePlatform, readClientUpdateManifest } from '../../utils/client-updates'

export default defineEventHandler(async (event) => {
  const platform = getQuery(event).platform
  if (!isClientUpdatePlatform(platform)) {
    throw createError({ statusCode: 400, statusMessage: 'platform ต้องเป็น windows หรือ android' })
  }

  const manifest = await readClientUpdateManifest(event, platform)
  const artifact = await stat(getClientUpdateArtifactPath(event, platform)).catch((error: NodeJS.ErrnoException) => {
    if (error.code === 'ENOENT') return null
    throw error
  })
  if (!artifact?.isFile() || artifact.size !== manifest.size) {
    throw createError({ statusCode: 409, statusMessage: 'ไฟล์อัปเดตไม่ตรงกับ manifest กรุณาเผยแพร่ใหม่' })
  }
  setHeader(event, 'cache-control', 'no-store')
  return {
    ...manifest,
    downloadPath: `/api/client-update/download/${platform}`,
  }
})
