import { createHash, randomUUID } from 'node:crypto'
import { createReadStream } from 'node:fs'
import { mkdir, readFile, rename, stat, writeFile } from 'node:fs/promises'
import { isAbsolute, join, resolve } from 'node:path'
import type { H3Event } from 'h3'

export const clientUpdatePlatforms = ['windows', 'android'] as const
export type ClientUpdatePlatform = typeof clientUpdatePlatforms[number]

export interface ClientUpdateManifest {
  platform: ClientUpdatePlatform
  version: string
  minimumVersion: string
  androidVersionCode?: number
  releaseNotes: string
  fileName: string
  sha256: string
  size: number
  publishedAt: string
}

const artifactNames: Record<ClientUpdatePlatform, string> = {
  windows: 'SoulLandDivine-Setup.exe',
  android: 'SoulLandDivine.apk',
}

export function isClientUpdatePlatform(value: unknown): value is ClientUpdatePlatform {
  return typeof value === 'string' && clientUpdatePlatforms.includes(value as ClientUpdatePlatform)
}

export function getClientUpdateDirectory(event: H3Event) {
  const configuredDirectory = useRuntimeConfig(event).clientUpdateDir
  if (typeof configuredDirectory !== 'string' || configuredDirectory.trim() === '') {
    throw createError({ statusCode: 500, statusMessage: 'CLIENT_UPDATE_DIR ยังไม่ได้ตั้งค่า' })
  }
  return isAbsolute(configuredDirectory)
    ? configuredDirectory
    : resolve(process.cwd(), configuredDirectory)
}

export function getClientUpdateArtifactPath(event: H3Event, platform: ClientUpdatePlatform) {
  return join(getClientUpdateDirectory(event), platform, artifactNames[platform])
}

function isVersion(value: unknown): value is string {
  return typeof value === 'string' && /^\d+(?:\.\d+){2}$/.test(value)
}

function compareVersions(first: string, second: string) {
  const firstParts = first.split('.').map(Number)
  const secondParts = second.split('.').map(Number)
  for (let index = 0; index < Math.max(firstParts.length, secondParts.length); index++) {
    const difference = (firstParts[index] || 0) - (secondParts[index] || 0)
    if (difference !== 0) return difference
  }
  return 0
}

export async function publishClientUpdate(
  event: H3Event,
  input: {
    platform?: unknown
    version?: unknown
    minimumVersion?: unknown
    androidVersionCode?: unknown
    releaseNotes?: unknown
  },
) {
  if (!isClientUpdatePlatform(input.platform)) {
    throw createError({ statusCode: 400, statusMessage: 'เลือก platform เป็น windows หรือ android' })
  }
  if (!isVersion(input.version) || !isVersion(input.minimumVersion)) {
    throw createError({ statusCode: 400, statusMessage: 'version และ minimumVersion ต้องเป็นรูปแบบตัวเลข เช่น 1.2.0' })
  }
  if (compareVersions(input.minimumVersion, input.version) > 0) {
    throw createError({ statusCode: 400, statusMessage: 'minimumVersion ต้องไม่สูงกว่า version' })
  }
  if (typeof input.releaseNotes !== 'string' || input.releaseNotes.length > 2000) {
    throw createError({ statusCode: 400, statusMessage: 'releaseNotes ต้องเป็นข้อความไม่เกิน 2,000 ตัวอักษร' })
  }
  if (input.platform === 'android'
    && (!Number.isSafeInteger(input.androidVersionCode) || (input.androidVersionCode as number) <= 0)) {
    throw createError({ statusCode: 400, statusMessage: 'Android versionCode ต้องเป็นจำนวนเต็มบวก' })
  }

  const platform = input.platform
  const artifactPath = getClientUpdateArtifactPath(event, platform)
  const artifactInfo = await stat(artifactPath).catch((error: NodeJS.ErrnoException) => {
    if (error.code === 'ENOENT') return null
    throw error
  })
  if (!artifactInfo?.isFile() || artifactInfo.size === 0) {
    throw createError({ statusCode: 409, statusMessage: `ไม่พบไฟล์ ${artifactNames[platform]} ในโฟลเดอร์อัปเดตของ ${platform}` })
  }

  const hash = createHash('sha256')
  for await (const chunk of createReadStream(artifactPath)) {
    hash.update(chunk)
  }
  const sha256 = hash.digest('hex')

  const previousManifest = await readClientUpdateManifest(event, platform).catch((error) => {
    if (error && typeof error === 'object' && 'statusCode' in error && error.statusCode === 404) return null
    throw error
  })
  if (previousManifest) {
    const versionChange = compareVersions(input.version, previousManifest.version)
    if (versionChange < 0 || (versionChange === 0 && sha256 !== previousManifest.sha256)) {
      throw createError({ statusCode: 409, statusMessage: 'เวอร์ชันต้องเพิ่มขึ้น; หากเผยแพร่เวอร์ชันเดิมต้องใช้ไฟล์เดิม' })
    }
    if (platform === 'android') {
      const previousVersionCode = previousManifest.androidVersionCode
      const versionCode = input.androidVersionCode as number
      if (typeof previousVersionCode !== 'number'
        || (versionChange > 0 && versionCode <= previousVersionCode)
        || (versionChange === 0 && versionCode !== previousVersionCode)) {
        throw createError({ statusCode: 409, statusMessage: 'Android versionCode ต้องเพิ่มขึ้นพร้อม version หรือคงเดิมเมื่อเผยแพร่ซ้ำ' })
      }
    }
  }

  const manifest: ClientUpdateManifest = {
    platform,
    version: input.version,
    minimumVersion: input.minimumVersion,
    ...(platform === 'android' ? { androidVersionCode: input.androidVersionCode as number } : {}),
    releaseNotes: input.releaseNotes,
    fileName: artifactNames[platform],
    sha256,
    size: artifactInfo.size,
    publishedAt: new Date().toISOString(),
  }
  const manifestPath = join(getClientUpdateDirectory(event), `manifest-${platform}.json`)
  await mkdir(getClientUpdateDirectory(event), { recursive: true })
  const temporaryPath = `${manifestPath}.${randomUUID()}.tmp`
  await writeFile(temporaryPath, JSON.stringify(manifest, null, 2), { encoding: 'utf8', flag: 'wx' })
  await rename(temporaryPath, manifestPath)
  return manifest
}

export async function readClientUpdateManifest(event: H3Event, platform: ClientUpdatePlatform) {
  const manifestPath = join(getClientUpdateDirectory(event), `manifest-${platform}.json`)
  const content = await readFile(manifestPath, 'utf8').catch((error: NodeJS.ErrnoException) => {
    if (error.code === 'ENOENT') return null
    throw error
  })
  if (content === null) {
    throw createError({ statusCode: 404, statusMessage: `ยังไม่มีอัปเดตสำหรับ ${platform}` })
  }

  let manifest: ClientUpdateManifest
  try {
    manifest = JSON.parse(content) as ClientUpdateManifest
  } catch {
    throw createError({ statusCode: 500, statusMessage: `manifest ของ ${platform} เสียหาย` })
  }
  if (manifest.platform !== platform || !isVersion(manifest.version) || !isVersion(manifest.minimumVersion)
    || compareVersions(manifest.minimumVersion, manifest.version) > 0
    || (platform === 'android' && (!Number.isSafeInteger(manifest.androidVersionCode) || (manifest.androidVersionCode as number) <= 0))
    || manifest.fileName !== artifactNames[platform] || !/^[a-f0-9]{64}$/.test(manifest.sha256)
    || !Number.isSafeInteger(manifest.size) || manifest.size <= 0
    || typeof manifest.releaseNotes !== 'string' || typeof manifest.publishedAt !== 'string') {
    throw createError({ statusCode: 500, statusMessage: `manifest ของ ${platform} ไม่ถูกต้อง` })
  }
  return manifest
}

export function getClientUpdateFileName(platform: ClientUpdatePlatform) {
  return artifactNames[platform]
}
