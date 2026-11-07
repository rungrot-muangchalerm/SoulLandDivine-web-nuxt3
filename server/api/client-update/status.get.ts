import { getAdminSession } from '../../utils/admin-session'
import { getClientUpdateArtifactPath, isClientUpdatePlatform, readClientUpdateManifest } from '../../utils/client-updates'
import { stat } from 'node:fs/promises'

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') {
    throw createError({ statusCode: 403, statusMessage: 'ต้องใช้สิทธิ์ผู้ดูแลระบบ' })
  }

  const platforms = await Promise.all(['windows', 'android'].map(async (value) => {
    if (!isClientUpdatePlatform(value)) return null
    const artifactPath = getClientUpdateArtifactPath(event, value)
    const artifact = await stat(artifactPath).catch((error: NodeJS.ErrnoException) => {
      if (error.code === 'ENOENT') return null
      throw error
    })
    const manifest = await readClientUpdateManifest(event, value).catch((error) => {
      if (error && typeof error === 'object' && 'statusCode' in error && error.statusCode === 404) return null
      throw error
    })
    return {
      platform: value,
      fileReady: artifact?.isFile() && artifact.size > 0 || false,
      fileSize: artifact?.size || 0,
      manifest,
    }
  }))
  return platforms
})
