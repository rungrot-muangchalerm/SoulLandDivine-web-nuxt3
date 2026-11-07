import { getAdminSession } from '../../utils/admin-session'
import { getAccountDatabase, getGameDatabase } from '../../utils/database'
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

  const body = await readBody<ListBody>(event)
  const serverId = Number(body.serverId)
  const page = Number(body.page ?? 1)
  if (!Number.isSafeInteger(serverId) || serverId <= 0 || serverId > 21_474) {
    throw createError({ statusCode: 400, statusMessage: 'รหัสเซิร์ฟเวอร์ไม่ถูกต้อง' })
  }
  if (!Number.isSafeInteger(page) || page <= 0 || !Number.isSafeInteger((page - 1) * pageSize)) {
    throw createError({ statusCode: 400, statusMessage: 'เลขหน้าไม่ถูกต้อง' })
  }

  const [serverRows] = await getAccountDatabase().execute(
    'SELECT id FROM server_list WHERE id = ? LIMIT 1',
    [serverId],
  )
  if (!(serverRows as Array<{ id: number }>).length) {
    throw createError({ statusCode: 404, statusMessage: 'ไม่พบเซิร์ฟเวอร์ที่เลือก' })
  }

  const serverUidStart = serverId * 100_000
  const serverUidEnd = (serverId + 1) * 100_000
  const gameDatabase = getGameDatabase()
  const accountDatabase = getAccountDatabase()
  const [accountKeyRows] = await gameDatabase.execute(
    `SELECT DISTINCT accountName, channelName
    FROM \`character\`
    WHERE uid >= ? AND uid < ?`,
    [serverUidStart, serverUidEnd],
  )

  const accountKeys = accountKeyRows as Array<{ accountName: string; channelName: string }>
  const accountRows: Array<Omit<PlayerRow, 'characters' | 'accumulateTotal' | 'characterCount'>> = []
  for (let index = 0; index < accountKeys.length; index += 250) {
    const batch = accountKeys.slice(index, index + 250)
    const filters = batch.map(() => '(id = ? AND channelName = ?)').join(' OR ')
    const values = batch.flatMap(({ accountName, channelName }) => [accountName, channelName])
    const [rows] = await accountDatabase.execute(
      `SELECT
        uid AS accountUid,
        id AS accountId,
        channelName,
        DATE_FORMAT(timeCreated, '%Y-%m-%d %H:%i:%s') AS timeCreated,
        DATE_FORMAT(lastLoginTime, '%Y-%m-%d %H:%i:%s') AS lastLoginTime
      FROM account
      WHERE ${filters}`,
      values,
    )
    accountRows.push(...rows as Array<Omit<PlayerRow, 'characters' | 'accumulateTotal' | 'characterCount'>>)
  }
  accountRows.sort((left, right) => left.accountUid - right.accountUid)
  const total = accountRows.length

  const players: PlayerRow[] = accountRows
    .slice((page - 1) * pageSize, page * pageSize)
    .map(player => ({ ...player, characterCount: 0, characters: [], accumulateTotal: 0 }))
  if (players.length) {
    const accountFilters = players.map(() => '(c.accountName = ? AND c.channelName = ?)').join(' OR ')
    const accountValues = players.flatMap(({ accountId, channelName }) => [accountId, channelName])
    const [characterRows] = await gameDatabase.execute(
      `SELECT
        c.uid,
        c.accountName,
        c.channelName,
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
      FROM \`character\` c
      LEFT JOIN character_resource r ON r.uid = c.uid
      LEFT JOIN recharge w ON w.pc_uid = c.uid
      WHERE ${accountFilters}
        AND c.uid >= ?
        AND c.uid < ?
      ORDER BY c.accountName, c.channelName, c.uid`,
      [...accountValues, serverUidStart, serverUidEnd],
    )

    const playerByKey = new Map(players.map(player => [
      `${player.accountId}\u0000${player.channelName}`,
      player,
    ]))
    for (const character of characterRows as Array<CharacterRow & { accountName: string; channelName: string }>) {
      const player = playerByKey.get(`${character.accountName}\u0000${character.channelName}`)
      if (!player) continue
      const { accountName: _accountName, channelName: _channelName, ...playerCharacter } = character
      player.characters.push(playerCharacter)
      player.characterCount += 1
      player.accumulateTotal += Number(playerCharacter.accumulateTotal)
    }
  }

  await recordOperationLog({
    username: session.username,
    ip: event.node.req.socket.remoteAddress || '',
    content: JSON.stringify({ serverId, page, pageSize }),
    type: '/players/list',
  })

  return { data: players, page, pageSize, total }
})
