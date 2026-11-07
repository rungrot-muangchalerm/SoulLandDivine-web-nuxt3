import { createReadStream } from 'node:fs'
import { stat } from 'node:fs/promises'
import { sendStream, setHeader } from 'h3'
import {
  getClientUpdateArtifactPath,
  getClientUpdateFileName,
  isClientUpdatePlatform,
  readClientUpdateManifest,
} from '../../../utils/client-updates'

export default defineEventHandler(async (event) => {
  const platform = getRouterParam(event, 'platform')
  if (!isClientUpdatePlatform(platform)) {
    throw createError({ statusCode: 404, statusMessage: 'ไม่พบไฟล์อัปเดต' })
  }

  const manifest = await readClientUpdateManifest(event, platform)
  const artifactPath = getClientUpdateArtifactPath(event, platform)
  const artifactInfo = await stat(artifactPath).catch((error: NodeJS.ErrnoException) => {
    if (error.code === 'ENOENT') return null
    throw error
  })
  if (!artifactInfo?.isFile()) {
    throw createError({ statusCode: 404, statusMessage: 'ไม่พบไฟล์อัปเดต' })
  }
  if (artifactInfo.size !== manifest.size) {
    throw createError({ statusCode: 409, statusMessage: 'ไฟล์อัปเดตเปลี่ยนหลังเผยแพร่ กรุณาเผยแพร่ manifest ใหม่' })
  }

  setHeader(event, 'content-type', platform === 'android' ? 'application/vnd.android.package-archive' : 'application/octet-stream')
  setHeader(event, 'content-length', artifactInfo.size)
  setHeader(event, 'content-disposition', `attachment; filename="${getClientUpdateFileName(platform)}"`)
  setHeader(event, 'cache-control', 'no-store')
  return sendStream(event, createReadStream(artifactPath))
})
