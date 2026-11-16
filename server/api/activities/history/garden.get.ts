import type { RowDataPacket } from 'mysql2/promise'
import { getAdminSession } from '../../../utils/admin-session'
import { getGameDatabase } from '../../../utils/database'

interface InstanceRow extends RowDataPacket {
  instanceId: string
  period: number
  state: string
  activityRowId: number | null
  startsAt: string | null
  endsAt: string | null
  archivedAt: string | null
  firstSeen: string | null
  lastChanged: string | null
  players: number
  totalScore: number
  topScore: number
}
interface RankRow extends RowDataPacket {
  instanceId: string
  ranks: number
  emails: number
}
interface LegacyRow extends RowDataPacket {
  period: number
  players: number
  totalScore: number
  topScore: number
  nonEmptySeeds: number
  claimedRewards: number
}

export default defineEventHandler(async event => {
  const session = await getAdminSession(event)
  if (session.authorization !== 'admin') {
    throw createError({ statusCode: 403, statusMessage: 'Admin only' })
  }
  setHeader(event, 'Cache-Control', 'no-store')

  // The lifecycle is authoritative for completed cycles, even when nobody
  // participated. Progress-only rounds are included before settlement starts.
  // The UNION prevents zero-player archived instances from vanishing.
  const [instances] = await getGameDatabase().execute<InstanceRow[]>(`
    SELECT ids.instance_id AS instanceId, ids.period,
      COALESCE(lifecycle.state, 'running') AS state,
      lifecycle.activity_row_id AS activityRowId,
      DATE_FORMAT(lifecycle.starts_at, '%Y-%m-%d %H:%i:%s') AS startsAt,
      DATE_FORMAT(lifecycle.ends_at, '%Y-%m-%d %H:%i:%s') AS endsAt,
      DATE_FORMAT(lifecycle.archived_at, '%Y-%m-%d %H:%i:%s') AS archivedAt,
      DATE_FORMAT(COALESCE(progress.first_seen, lifecycle.created_at), '%Y-%m-%d %H:%i:%s') AS firstSeen,
      DATE_FORMAT(COALESCE(progress.last_changed, lifecycle.archived_at, lifecycle.closed_at, lifecycle.created_at), '%Y-%m-%d %H:%i:%s') AS lastChanged,
      COALESCE(progress.players, 0) AS players,
      COALESCE(progress.total_score, 0) AS totalScore,
      COALESCE(progress.top_score, 0) AS topScore
    FROM (
      SELECT instance_id, period FROM garden_instance_lifecycle
      UNION
      SELECT instance_id, period FROM garden_instance_progress
    ) AS ids
    LEFT JOIN garden_instance_lifecycle AS lifecycle
      ON lifecycle.instance_id = ids.instance_id AND lifecycle.period = ids.period
    LEFT JOIN (
      SELECT instance_id, MIN(created_at) AS first_seen,
        MAX(updated_at) AS last_changed,
        COUNT(*) AS players, COALESCE(SUM(score), 0) AS total_score,
        COALESCE(MAX(score), 0) AS top_score
      FROM garden_instance_progress GROUP BY instance_id
    ) AS progress ON progress.instance_id = ids.instance_id
    ORDER BY COALESCE(progress.last_changed, lifecycle.archived_at, lifecycle.created_at) DESC
    LIMIT 100
  `)

  const [rankHistory] = await getGameDatabase().execute<RankRow[]>(`
    SELECT instance_id AS instanceId, COUNT(*) AS ranks,
      COALESCE(SUM(email_dispatched_at IS NOT NULL), 0) AS emails
    FROM garden_rank_history
    GROUP BY instance_id
  `)

  // Unknown legacy cycles are deliberately NOT attributed to a new UUID.
  const [legacy] = await getGameDatabase().execute<LegacyRow[]>(`
    SELECT period, COUNT(*) AS players, COALESCE(SUM(score), 0) AS totalScore,
      COALESCE(MAX(score), 0) AS topScore,
      SUM(seedInfo <> '') AS nonEmptySeeds,
      SUM(scoreReward <> '') AS claimedRewards
    FROM garden_period GROUP BY period ORDER BY period
  `)

  const rankCounts = new Map(rankHistory.map(row => [row.instanceId, {
    ranks: Number(row.ranks),
    emails: Number(row.emails),
  }]))

  return {
    instances: instances.map(row => ({
      instanceId: row.instanceId,
      period: Number(row.period),
      state: row.state,
      activityRowId: row.activityRowId,
      startsAt: row.startsAt,
      endsAt: row.endsAt,
      archivedAt: row.archivedAt,
      firstSeen: row.firstSeen,
      lastChanged: row.lastChanged,
      players: Number(row.players),
      totalScore: Number(row.totalScore),
      topScore: Number(row.topScore),
      ...rankCounts.get(row.instanceId) || { ranks: 0, emails: 0 },
    })),
    legacy: legacy.map(row => ({
      period: Number(row.period),
      players: Number(row.players),
      totalScore: Number(row.totalScore),
      topScore: Number(row.topScore),
      nonEmptySeeds: Number(row.nonEmptySeeds),
      claimedRewards: Number(row.claimedRewards),
    })),
  }
})
