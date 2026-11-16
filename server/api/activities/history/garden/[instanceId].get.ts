import type { RowDataPacket } from 'mysql2/promise'
import { getAdminSession } from '../../../../utils/admin-session'
import { getGameDatabase } from '../../../../utils/database'

interface ProgressRow extends RowDataPacket {
  uid: number
  period: number
  score: number
  seedInfo: string
  scoreReward: string
  updatedAt?: string
}
interface RankRow extends RowDataPacket {
  groupId: number
  uid: number
  ranking: number
  score: number
  emailId: number | null
  emailDispatchedAt: string | null
}
interface LifecycleRow extends RowDataPacket {
  activityRowId: number
  period: number
  state: string
  startsAt: string
  endsAt: string
  closedAt: string | null
  archivedAt: string | null
}

export default defineEventHandler(async event => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') {
    throw createError({ statusCode: 403, statusMessage: 'Admin only' })
  }
  setHeader(event, 'Cache-Control', 'no-store')

  const instanceId = getRouterParam(event, 'instanceId') || ''
  const legacyMatch = /^legacy-([1-9][0-9]{0,4})$/.exec(instanceId)

  if (legacyMatch) {
    const period = Number(legacyMatch[1])
    const [rows] = await getGameDatabase().execute<ProgressRow[]>(`
      SELECT uid, period, score, seedInfo, scoreReward
      FROM garden_period WHERE period = ? ORDER BY score DESC, uid ASC LIMIT 500
    `, [period])

    return {
      instanceId,
      period,
      legacy: true,
      // Do not misattribute these unattributed records to a dated activity.
      attribution: 'unclassified',
      lifecycle: null,
      progress: rows.map(row => ({
        uid: Number(row.uid), period: Number(row.period), score: Number(row.score),
        seedInfo: row.seedInfo, scoreReward: row.scoreReward,
      })),
      ranks: [],
    }
  }

  if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(instanceId)) {
    throw createError({ statusCode: 400, statusMessage: 'Invalid Garden instance ID' })
  }

  const [rows] = await getGameDatabase().execute<ProgressRow[]>(`
    SELECT uid, period, score, seedInfo, scoreReward,
      DATE_FORMAT(updated_at, '%Y-%m-%d %H:%i:%s') AS updatedAt
    FROM garden_instance_progress WHERE instance_id = ?
    ORDER BY score DESC, uid ASC LIMIT 500
  `, [instanceId])

  const [ranks] = await getGameDatabase().execute<RankRow[]>(`
    SELECT group_id AS groupId, uid, ranking, score, email_id AS emailId,
      DATE_FORMAT(email_dispatched_at, '%Y-%m-%d %H:%i:%s') AS emailDispatchedAt
    FROM garden_rank_history WHERE instance_id = ?
    ORDER BY group_id, ranking, uid LIMIT 1000
  `, [instanceId])

  const [lifecycle] = await getGameDatabase().execute<LifecycleRow[]>(`
    SELECT activity_row_id AS activityRowId, period, state,
      DATE_FORMAT(starts_at, '%Y-%m-%d %H:%i:%s') AS startsAt,
      DATE_FORMAT(ends_at, '%Y-%m-%d %H:%i:%s') AS endsAt,
      DATE_FORMAT(closed_at, '%Y-%m-%d %H:%i:%s') AS closedAt,
      DATE_FORMAT(archived_at, '%Y-%m-%d %H:%i:%s') AS archivedAt
    FROM garden_instance_lifecycle WHERE instance_id = ? LIMIT 1
  `, [instanceId])

  return {
    instanceId,
    period: Number(lifecycle[0]?.period || rows[0]?.period || 0),
    legacy: false,
    attribution: 'identified',
    lifecycle: lifecycle[0] || null,
    progress: rows.map(row => ({
      uid: Number(row.uid), period: Number(row.period), score: Number(row.score),
      seedInfo: row.seedInfo, scoreReward: row.scoreReward, updatedAt: row.updatedAt,
    })),
    ranks: ranks.map(row => ({
      groupId: Number(row.groupId), uid: Number(row.uid), ranking: Number(row.ranking),
      score: Number(row.score), emailId: row.emailId, emailDispatchedAt: row.emailDispatchedAt,
    })),
  }
})
