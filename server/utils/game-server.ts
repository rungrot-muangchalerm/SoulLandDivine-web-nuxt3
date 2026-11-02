import net from 'node:net'
import { getGameDatabase } from './database'

export async function sendGamePacket(
  payload: Record<string, unknown>,
  protocolId: number,
  channel: string,
) {
  const [rows] = await getGameDatabase().execute(
    'SELECT ip FROM `channel_list` WHERE `index` = ? LIMIT 1',
    [channel],
  )
  const configuredHost = (rows as Array<{ ip: string | null }>)[0]?.ip
  const runtime = useRuntimeConfig()
  const host = configuredHost || runtime.gameServerHost
  const port = runtime.gameServerPort

  if (!host) {
    throw createError({ statusCode: 503, statusMessage: 'ยังไม่ได้ตั้งค่า game server ของช่องทางนี้' })
  }

  const message = { ...payload }
  delete message.channel
  delete message.protocolId
  const json = Buffer.from(JSON.stringify(message), 'utf8')
  if (json.length > 0xffff) {
    throw createError({ statusCode: 413, statusMessage: 'ข้อมูลที่ส่งไป game server มีขนาดใหญ่เกินไป' })
  }

  const packet = Buffer.allocUnsafe(json.length + 6)
  packet.writeUInt16LE(json.length, 0)
  packet.writeUInt32LE(protocolId, 2)
  json.copy(packet, 6)

  return await new Promise<unknown>((resolve, reject) => {
    const socket = net.createConnection({ host, port })
    let response = ''
    let settled = false
    const finish = (error?: Error, value?: unknown) => {
      if (settled) return
      settled = true
      socket.destroy()
      if (error) reject(createError({ statusCode: 502, statusMessage: error.message }))
      else resolve(value)
    }

    socket.setTimeout(15000)
    socket.once('connect', () => socket.write(packet))
    socket.on('data', (chunk) => {
      response += chunk.toString('utf8')
      try {
        finish(undefined, JSON.parse(response))
      } catch (error) {
        if (error instanceof SyntaxError) return
        finish(error instanceof Error ? error : new Error('Invalid game server response'))
      }
    })
    socket.once('timeout', () => finish(new Error('Game server request timed out')))
    socket.once('error', (error) => finish(error))
    socket.once('end', () => {
      if (!settled) finish(new Error('Game server closed the connection before replying'))
    })
  })
}
