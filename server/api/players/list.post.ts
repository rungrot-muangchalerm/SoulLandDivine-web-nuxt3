import { getCookie } from 'h3'
import { getAdminSession } from '../../utils/admin-session'
import { getGameDatabase } from '../../utils/database'
import { recordOperationLog } from '../../utils/operation-log'

interface ListBody {
  serverId?: number | string
  page?: number | string
}

interface PlayerRow {
  accountUid: number
  accountId: string
  channelName: string
  timeCreated: string | null
  lastLoginTime: string | null
  characterCount: number
  characters: CharacterRow[]
  accumulateTotal: number
}

interface CharacterRow {
  uid: number
  name: string
  sex: number
  online: string
  timeCreated: string | null
  lastLoginTime: string | null
  silenceTime: string | null
  freezeTime: string | null
  level: number
  exp: number
  gold: number
  diamond: number
  accumulateTotal: number
}

const pageSize = 50

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  const channel = getCookie(event, 'channel') || ''
  if (!channel || !session.channel?.includes(channel)) {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  }

  const body = await readBody<ListBody>(event)
  const serverId = Number(body.serverId)
  const page = Number(body.page ?? 1)
  if (!Number.isSafeInteger(serverId) || serverId <= 0 || serverId > 21_474) {
    throw createError({ statusCode: 400, statusMessage: 'รหัสเซิร์ฟเวอร์ไม่ถูกต้อง' })
  }
  if (!Number.isSafeInteger(page) || page <= 0 || !Number.isSafeInteger((page - 1) * pageSize)) {
    throw createError({ statusCode: 400, statusMessage: 'เลขหน้าไม่ถูกต้อง' })
  }

  const [serverRows] = await getGameDatabase().execute(
    'SELECT id FROM server_list WHERE id = ? LIMIT 1',
    [serverId],
  )
  if (!(serverRows as Array<{ id: number }>).length) {
    throw createError({ statusCode: 404, statusMessage: 'ไม่พบเซิร์ฟเวอร์ที่เลือก' })
  }

  const serverUidStart = serverId * 100_000
  const serverUidEnd = (serverId + 1) * 100_000
  const database = getGameDatabase()
  const [countRows] = await database.execute(
    `SELECT COUNT(*) AS total
    FROM account a
    WHERE EXISTS (
      SELECT 1
      FROM \`character\` c
      WHERE c.accountName = a.id
        AND c.channelName = a.channelName
        AND c.uid >= ?
        AND c.uid < ?
    )`,
    [serverUidStart, serverUidEnd],
  )
  const total = Number((countRows as Array<{ total: number }>)[0]?.total || 0)

  const [accountRows] = await database.execute(
    `SELECT
      a.uid AS accountUid,
      a.id AS accountId,
      a.channelName,
      DATE_FORMAT(a.timeCreated, '%Y-%m-%d %H:%i:%s') AS timeCreated,
      DATE_FORMAT(a.lastLoginTime, '%Y-%m-%d %H:%i:%s') AS lastLoginTime
    FROM account a
    WHERE EXISTS (
      SELECT 1
      FROM \`character\` c
      WHERE c.accountName = a.id
        AND c.channelName = a.channelName
        AND c.uid >= ?
        AND c.uid < ?
    )
    ORDER BY a.uid
    LIMIT ? OFFSET ?`,
    [serverUidStart, serverUidEnd, pageSize, (page - 1) * pageSize],
  )

  const players: PlayerRow[] = (accountRows as Omit<PlayerRow, 'characters' | 'accumulateTotal' | 'characterCount'>[])
    .map(player => ({ ...player, characterCount: 0, characters: [], accumulateTotal: 0 }))
  if (players.length) {
    const accountPlaceholders = players.map(() => '?').join(', ')
    const [characterRows] = await database.execute(
      `SELECT
        a.uid AS accountUid,
        c.uid,
        c.charName AS name,
        c.sex,
        'ไม่ทราบจากฐานข้อมูล' AS online,
        DATE_FORMAT(c.createdTime, '%Y-%m-%d %H:%i:%s') AS timeCreated,
        DATE_FORMAT(c.lastLoginTime, '%Y-%m-%d %H:%i:%s') AS lastLoginTime,
        DATE_FORMAT(c.silenceTime, '%Y-%m-%d %H:%i:%s') AS silenceTime,
        DATE_FORMAT(c.freezeTime, '%Y-%m-%d %H:%i:%s') AS freezeTime,
        c.level,
        COALESCE(r.exp, 0) AS exp,
        COALESCE(r.gold, 0) AS gold,
        COALESCE(r.diamond, 0) AS diamond,
        COALESCE(w.accumulate_total, 0) AS accumulateTotal
      FROM account a
      JOIN \`character\` c
        ON c.accountName = a.id
        AND c.channelName = a.channelName
      LEFT JOIN character_resource r ON r.uid = c.uid
      LEFT JOIN recharge w ON w.pc_uid = c.uid
      WHERE a.uid IN (${accountPlaceholders})
        AND c.uid >= ?
        AND c.uid < ?
      ORDER BY a.uid, c.uid`,
      [...players.map(player => player.accountUid), serverUidStart, serverUidEnd],
    )

    const playerByUid = new Map(players.map(player => [String(player.accountUid), player]))
    for (const character of characterRows as Array<CharacterRow & { accountUid: number }>) {
      const player = playerByUid.get(String(character.accountUid))
      if (!player) continue
      const { accountUid: _accountUid, ...playerCharacter } = character
      player.characters.push(playerCharacter)
      player.characterCount += 1
      player.accumulateTotal += Number(playerCharacter.accumulateTotal)
    }
  }

  await recordOperationLog({
    username: session.username,
    ip: event.node.req.socket.remoteAddress || '',
    content: JSON.stringify({ serverId, page, pageSize, channel }),
    type: '/players/list',
  })

  return { data: players, page, pageSize, total }
})
