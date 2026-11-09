import { readFile } from 'node:fs/promises'
import { join } from 'node:path'
import defaults from '../config/client-connection.json'
import { getClientUpdateDirectory } from '../utils/client-updates'
import { isIP } from 'node:net'

export default defineEventHandler(async (event) => {
  setHeader(event, 'cache-control', 'no-store')
  const path = join(getClientUpdateDirectory(event), 'connection-config.json')
  const content = await readFile(path, 'utf8').catch((error: NodeJS.ErrnoException) => {
    if (error.code === 'ENOENT') return null
    throw error
  })
  let config: Record<string, unknown>
  try {
    if (content !== null && content.length > 16384) throw new Error('Config too large')
    config = content === null ? defaults : JSON.parse(content)
    if (!config || Array.isArray(config) || typeof config !== 'object') throw new Error('Invalid config')
    if (!Number.isSafeInteger(config.serverId) || (config.serverId as number) <= 0
      || !Number.isInteger(config.loginPort) || (config.loginPort as number) < 1 || (config.loginPort as number) > 65535
      || typeof config.loginHost !== 'string') throw new Error('Invalid endpoint')
    const host = config.loginHost.trim()
    if (!isIP(host) && (host.length > 253 || !host.split('.').every(label => /^[a-z\d](?:[a-z\d-]{0,61}[a-z\d])?$/i.test(label)))) {
      throw new Error('Invalid host')
    }
    for (const key of ['announcementUrl', 'payNotifyUrl', 'updateManifestUrl']) {
      if (typeof config[key] !== 'string') throw new Error('Invalid URL')
      const url = new URL(config[key] as string)
      if (!['http:', 'https:'].includes(url.protocol) || url.username || url.password) throw new Error('Invalid URL')
    }
    // Return only public connection fields, never arbitrary runtime data.
    return {
      serverId: config.serverId, loginHost: host, loginPort: config.loginPort,
      announcementUrl: config.announcementUrl, payNotifyUrl: config.payNotifyUrl,
      updateManifestUrl: config.updateManifestUrl,
    }
  } catch {
    throw createError({ statusCode: 503, statusMessage: 'Client connection config is invalid' })
  }
})
