import { getDatabase } from '../utils/database'
import { sendGamePacket } from '../utils/game-server'

interface ScheduledBroadcast {
  id: number
  serverId: string
  content: string
  type: string
  intervalTime: number | null
  stopTime: Date
  channel: string
}

export default defineNitroPlugin((nitroApp) => {
  let running = false
  let cooldownUntil = 0

  const timer = setInterval(async () => {
    if (running || Date.now() < cooldownUntil) return
    running = true
    try {
      const connection = await getDatabase().getConnection()
      let due: ScheduledBroadcast[] = []
      try {
        await connection.beginTransaction()
        const [rows] = await connection.query(
          `SELECT id, serverId, content, type, intervalTime, stopTime, channel
           FROM broadcast
           WHERE startTime <= NOW() AND stopTime > NOW() AND triggerTime <= NOW()
           FOR UPDATE`,
        )
        due = rows as ScheduledBroadcast[]
        for (const item of due) {
          await connection.execute(
            'UPDATE broadcast SET triggerTime = DATE_ADD(NOW(), INTERVAL 30 SECOND) WHERE id = ?',
            [item.id],
          )
        }
        await connection.commit()
      } catch (error) {
        await connection.rollback()
        throw error
      } finally {
        connection.release()
      }

      for (const item of due) {
        try {
          const result = await sendGamePacket(
            { serverId: item.serverId, content: item.content },
            10015,
            item.channel,
          ) as { result?: number }
          if (result.result !== 1) continue

          if (item.type !== 'loop' || !item.intervalTime) {
            await getDatabase().execute('UPDATE broadcast SET triggerTime = NULL WHERE id = ?', [item.id])
            continue
          }
          const nextTime = new Date(Date.now() + item.intervalTime * 60_000)
          if (nextTime < new Date(item.stopTime)) {
            await getDatabase().execute(
              'UPDATE broadcast SET triggerTime = ? WHERE id = ?',
              [nextTime, item.id],
            )
          } else {
            await getDatabase().execute('UPDATE broadcast SET triggerTime = NULL WHERE id = ?', [item.id])
          }
        } catch (error) {
          console.error(`Broadcast ${item.id} delivery failed:`, error)
        }
      }
    } catch (error) {
      console.error('Broadcast scheduler failed:', error)
      cooldownUntil = Date.now() + 10_000
    } finally {
      running = false
    }
  }, 1000)

  nitroApp.hooks.hook('close', () => clearInterval(timer))
})
