import { timingSafeEqual } from 'node:crypto'
import { getCookie } from 'h3'
import { readFile } from 'node:fs/promises'
import { resolve } from 'node:path'
import { getDatabase, getGameDatabase } from '../utils/database'
import { getAdminSession } from '../utils/admin-session'
import { sendGamePacket } from '../utils/game-server'
import { recordOperationLog as writeOperationLog } from '../utils/operation-log'

type Body = Record<string, unknown>
type SqlValue = string | number | boolean | Date | null
type GameRoute = {
  protocol: number
  payload: (body: Body) => Body
}

const value = (body: Body, key: string, fallback?: unknown) =>
  body[key] === undefined ? fallback : body[key]

const sqlValue = (input: unknown): SqlValue => {
  if (input === undefined || input === null) return null
  if (typeof input === 'string' || typeof input === 'number' || typeof input === 'boolean' || input instanceof Date) {
    return input
  }
  throw createError({ statusCode: 400, statusMessage: 'ข้อมูลในคำขอไม่ถูกต้อง' })
}

const sqlValues = (...values: unknown[]): SqlValue[] => values.map(sqlValue)
const affectedRows = (result: unknown) =>
  Number((result as { affectedRows?: number }).affectedRows || 0)

async function recordOperation(
  event: Parameters<typeof getAdminSession>[0],
  username: string,
  route: string,
  body: Body,
) {
  const ip = event.node.req.socket.remoteAddress || ''
  await writeOperationLog({
    username,
    ip,
    content: JSON.stringify(body),
    type: `/${route}`,
  })
}

function xmlAttributes(tag: string) {
  const attributes: Record<string, string> = {}
  for (const match of tag.matchAll(/([\w:.-]+)="([^"]*)"/g)) {
    attributes[match[1]] = match[2]
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&')
  }
  return attributes
}

const gameRoutes: Record<string, GameRoute> = {
  'role/search': {
    protocol: 10002,
    payload: (b) => ({ serverId: b.serverId, uid: value(b, 'uid', 0), name: value(b, 'name', '') }),
  },
  'role/unVoice': {
    protocol: 10008,
    payload: (b) => ({ serverId: b.serverId, uid: b.uid, minutes: b.minutes, reason: value(b, 'reason', '') }),
  },
  'role/voice': { protocol: 10009, payload: (b) => ({ serverId: b.serverId, uid: b.uid }) },
  'role/freeze': {
    protocol: 10004,
    payload: (b) => ({ serverId: b.serverId, uid: b.uid, hours: b.minutes, reason: value(b, 'reason', '') }),
  },
  'role/unFreeze': { protocol: 10005, payload: (b) => ({ serverId: b.serverId, uid: b.uid }) },
  'servers/getServers': {
    protocol: 14001,
    payload: (b) => ({
      page: b.page, pageSize: b.pageSize, serverBegin: b.serverBegin, serverEnd: b.serverEnd,
    }),
  },
  'servers/isRecommend': { protocol: 14002, payload: (b) => ({ recommend: b.recommend }) },
  'servers/isMaintain': { protocol: 14002, payload: (b) => ({ maintain: b.maintain }) },
  'servers/isMaintainAll': { protocol: 14002, payload: () => ({ maintainAll: true }) },
  'servers/isMaintainAllCancel': { protocol: 14002, payload: () => ({ maintainAllCancel: true }) },
  'servers/isOpen': { protocol: 14002, payload: (b) => ({ open: b.open }) },
  'sensitive/addword': { protocol: 10021, payload: (b) => ({ content: b.content }) },
  'report/search': {
    protocol: 15001,
    payload: (b) => ({
      type: b.type, startServerId: b.startServerId, endServerId: b.endServerId,
      curPage: b.curPage, pageSize: b.pageSize,
    }),
  },
  'report/ignore': { protocol: 15002, payload: (b) => ({ id: b.id, serverId: b.serverId }) },
  'pay/order': {
    protocol: 10017,
    payload: (b) => ({ serverId: b.serverId, uid: b.uid, orderId: b.orderId, orderInfo: b.orderInfo, amount: b.money }),
  },
  'email/send': {
    protocol: 15003,
    payload: (b) => ({
      mailId: b.mailId, serverIdAndUid: b.uidList,
      reward: [b.reward1, b.reward2, b.reward3].filter(Boolean).join('|'),
    }),
  },
  'welfare/searchGrade': { protocol: 12004, payload: (b) => ({ id: b.welfareId }) },
  'welfare/addGrade': {
    protocol: 12001,
    payload: (b) => ({
      id: b.welfareId, name: b.welfareName, firstEmail: b.firstWelfare,
      fixedEmail: b.normalWelfare, sendType: b.periodType, day: b.period, time: b.sendOclock,
    }),
  },
  'welfare/changeGrade': {
    protocol: 12003,
    payload: (b) => ({
      id: b.welfareId, name: b.welfareName, firstEmail: b.firstWelfare, fixedEmail: b.normalWelfare,
    }),
  },
  'welfare/deleteGrade': { protocol: 12002, payload: (b) => ({ id: b.welfareId }) },
  'welfare/searchPlayer': { protocol: 12008, payload: (b) => ({ serverId: b.serverId, uid: b.uid }) },
  'welfare/addPlayer': {
    protocol: 12005,
    payload: (b) => ({ serverId: b.serverId, uid: b.uid, id: b.welfareId }),
  },
  'welfare/deletePlayer': {
    protocol: 12006,
    payload: (b) => ({ id: b.welfareId, uid: b.uid, serverId: b.serverId }),
  },
  'itemdelete/search': {
    protocol: 15004,
    payload: (b) => ({
      ServerId: b.serverId, UserId: b.uid, RewardType: b.type, ItemId: b.id,
    }),
  },
  'itemdelete/deduct': {
    protocol: 15005,
    payload: (b) => ({
      ServerId: b.ServerId, UserId: b.UserId, RewardType: b.RewardType,
      ItemId: b.ItemId, ItemUid: b.ItemUid, ItemNum: b.ItemNum,
    }),
  },
  'itemdelete/deductPlan': {
    protocol: 15006,
    payload: (b) => ({
      ServerId: b.ServerId, UserId: b.UserId, ActivityType: b.ActivityType, Num: b.Num, Price: b.Price,
    }),
  },
  'log/searchItemConsume': {
    protocol: 13002,
    payload: (b) => ({
      serverId: b.serverId, uid: b.PcUid, itemId: value(b, 'itemId', '') === '' ? 0 : b.itemId,
      order: b.order ? 0 : 1, fromTime: (b.time_data as unknown[])?.[0],
      endTime: (b.time_data as unknown[])?.[1], consumeWay: b.ConsumeWay,
      page: b.page, pageSize: b.pageSize,
    }),
  },
  'log/searchItemProduce': {
    protocol: 13001,
    payload: (b) => ({
      serverId: b.serverId, uid: b.PcUid, itemId: value(b, 'itemId', '') === '' ? 0 : b.itemId,
      order: b.order ? 0 : 1, fromTime: (b.time_data as unknown[])?.[0],
      endTime: (b.time_data as unknown[])?.[1], produceWay: b.ObtainWay,
      page: b.page, pageSize: b.pageSize,
    }),
  },
  'log/searchCurrencyConsume': {
    protocol: 13004,
    payload: (b) => ({
      serverId: b.serverId, uid: b.PcUid, itemId: value(b, 'itemId', '') === '' ? 0 : b.itemId,
      order: b.order ? 0 : 1, fromTime: (b.time_data as unknown[])?.[0],
      endTime: (b.time_data as unknown[])?.[1], consumeWay: b.ConsumeWay,
      page: b.page, pageSize: b.pageSize,
    }),
  },
  'log/searchCurrencyProduce': {
    protocol: 13003,
    payload: (b) => ({
      serverId: b.serverId, uid: b.PcUid, itemId: value(b, 'itemId', '') === '' ? 0 : b.itemId,
      order: b.order ? 0 : 1, fromTime: (b.time_data as unknown[])?.[0],
      endTime: (b.time_data as unknown[])?.[1], produceWay: b.ObtainWay,
      page: b.page, pageSize: b.pageSize,
    }),
  },
  'log/searchLoginOrLogOut': {
    protocol: 13005,
    payload: (b) => ({
      serverId: b.serverId, uid: b.PcUid, fromTime: (b.time_data as unknown[])?.[0],
      endTime: (b.time_data as unknown[])?.[1], isLogin: b.way, page: b.page, pageSize: b.pageSize,
    }),
  },
  'log/searchPay': {
    protocol: 10041,
    payload: (b) => ({
      serverId: b.serverId, uid: b.uid, startTime: (b.time_data as unknown[])?.[0],
      endTime: (b.time_data as unknown[])?.[1], orderId: b.orderId, orderInfo: b.orderInfo,
      page: b.page, pageSize: b.pageSize,
    }),
  },
}

async function searchBroadcast(body: Body) {
  const filters = ['channel = ?']
  const params: SqlValue[] = [sqlValue(body.channel)]
  if (body.serverId !== '0' && body.serverId) {
    filters.push('serverId = ?')
    params.push(sqlValue(body.serverId))
  }
  if (body.submitter && body.submitter !== 'all') {
    filters.push('submitter = ?')
    params.push(sqlValue(body.submitter))
  }
  const now = new Date()
  if (body.state_data === 'unexecuted') filters.push('startTime > NOW()')
  if (body.state_data === 'executing') filters.push('startTime <= NOW() AND stopTime > NOW()')
  if (body.state_data === 'finish') filters.push('stopTime < NOW()')
  const [rows] = await getDatabase().execute(
    `SELECT * FROM broadcast WHERE ${filters.join(' AND ')} ORDER BY id DESC`,
    params,
  )
  return (rows as Array<Record<string, unknown>>).map((row) => {
    const startTime = new Date(String(row.startTime))
    const stopTime = new Date(String(row.stopTime))
    return {
      ...row,
      status: startTime > now ? 'ยังไม่เริ่ม' : stopTime >= now ? 'กำลังดำเนินการ' : 'สิ้นสุดแล้ว',
    }
  })
}

export default defineEventHandler(async (event) => {
  const route = getRouterParam(event, 'path') || ''
  const body = await readBody<Body>(event)
  const session = await getAdminSession(event)
  const channel = String(body.channel ?? event.context.adminChannel ?? getCookie(event, 'channel') ?? '')
  if (!channel || channel !== event.context.adminChannel) {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  }
  body.channel = channel
  if (route.startsWith('users/') && route !== 'users/changePsw' && session.authorization !== 'admin') {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์จัดการผู้ใช้หรือประวัติการทำงาน' })
  }
  if (
    ['set/addChannel', 'set/changeChannel', 'set/deleteChannel'].includes(route)
    && !['admin', 'server'].includes(session.authorization)
  ) {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์จัดการช่องทาง' })
  }

  const gameRoute = gameRoutes[route]
  if (gameRoute) {
    const result = await sendGamePacket(gameRoute.payload(body), gameRoute.protocol, channel)
    await recordOperation(event, session.username, route, body)
    if (route === 'itemdelete/search') {
      const items = (result as { ItemList?: Array<Record<string, unknown>> })?.ItemList || []
      if (['1', '2', '9'].includes(String(body.type))) {
        if (items.length === 0) return 'nodata'
        const requestedAmount = Number(body.num)
        const availableAmount = Number(items[0].ItemNum)
        if (requestedAmount > availableAmount) return 'nomore'
        items[0].ItemNum = body.num
      }
      return items
    }
    return result
  }

  if (route === 'baseinfo/serverlist') {
    const config = useRuntimeConfig()
    const file = resolve(process.cwd(), config.serverListDir, 'test.xml')
    const xml = await readFile(file, 'utf8')
    const rootTag = xml.match(/<idspace\b[^>]*>/)?.[0]
    if (!rootTag) {
      throw createError({ statusCode: 500, statusMessage: 'รูปแบบไฟล์ server list ไม่ถูกต้อง' })
    }
    const classes = Array.from(xml.matchAll(/<class\b[^>]*\/?>/g), ([tag]) => ({ $: xmlAttributes(tag) }))
    return { idspace: { $: xmlAttributes(rootTag), class: classes } }
  }

  if (route === 'baseinfo/userlist') {
    const [rows] = await getDatabase().query(
      'SELECT id, username, channel FROM `user` ORDER BY id',
    )
    return (rows as Array<{ channel: string }>).filter((row) => row.channel?.includes(channel))
  }
  if (route === 'set/searchChannelOne') {
    const [rows] = await getDatabase().execute(
      'SELECT id, name, `index`, ip, url FROM channel_list WHERE `index` = ? LIMIT 1',
      [channel],
    )
    return rows
  }
  if (route === 'set/addChannel') {
    const [result] = await getDatabase().execute(
      'INSERT INTO channel_list (name, `index`, ip, url) VALUES (?, ?, ?, ?)',
      sqlValues(body.name, body.index, body.ip, body.url),
    )
    await recordOperation(event, session.username, route, body)
    return { result: (result as { insertId: number }).insertId ? 1 : 0 }
  }
  if (route === 'set/changeChannel') {
    const [result] = await getDatabase().execute(
      'UPDATE channel_list SET name = ?, `index` = ?, ip = ?, url = ? WHERE id = ?',
      sqlValues(body.name, body.index, body.ip, body.url, body.id),
    )
    await recordOperation(event, session.username, route, body)
    return [affectedRows(result)]
  }
  if (route === 'set/deleteChannel') {
    const [result] = await getDatabase().execute(
      'DELETE FROM channel_list WHERE id = ?',
      sqlValues(body.id),
    )
    await recordOperation(event, session.username, route, body)
    return affectedRows(result)
  }
  if (route === 'users/searchall') {
    const [rows] = await getGameDatabase().query(
      'SELECT id, username, authorization, channel FROM `admin_user` ORDER BY id',
    )
    return rows
  }
  if (route === 'users/searchOne') {
    const [rows] = await getGameDatabase().execute(
      'SELECT id, username, authorization, channel FROM `admin_user` WHERE id = ? LIMIT 1',
      sqlValues(body.id),
    )
    return rows
  }
  if (route === 'users/add') {
    await getGameDatabase().execute(
      'INSERT INTO `admin_user` (username, password, authorization, channel) VALUES (?, ?, ?, ?)',
      sqlValues(body.username, body.password, body.authorization, body.channel),
    )
    return { result: 'success' }
  }
  if (route === 'users/changePsw') {
    const currentPassword = body.currentPassword
    const newPassword = body.password
    if (body.username !== session.username) {
      throw createError({ statusCode: 403, statusMessage: 'เปลี่ยนรหัสผ่านได้เฉพาะบัญชีของตนเอง' })
    }
    if (
      typeof currentPassword !== 'string'
      || !/^[a-f0-9]{32}$/i.test(currentPassword)
      || typeof newPassword !== 'string'
      || !/^[a-f0-9]{32}$/i.test(newPassword)
    ) {
      throw createError({ statusCode: 400, statusMessage: 'รูปแบบรหัสผ่านไม่ถูกต้อง' })
    }
    const [rows] = await getGameDatabase().execute(
      'SELECT password FROM `admin_user` WHERE username = ? LIMIT 1',
      [session.username],
    )
    const storedPassword = (rows as Array<{ password: string }>)[0]?.password
    if (
      !storedPassword
      || !/^[a-f0-9]{32}$/i.test(storedPassword)
      || !timingSafeEqual(Buffer.from(storedPassword, 'hex'), Buffer.from(currentPassword, 'hex'))
    ) {
      throw createError({ statusCode: 401, statusMessage: 'รหัสผ่านเดิมไม่ถูกต้อง' })
    }
    const [result] = await getGameDatabase().execute(
      'UPDATE `admin_user` SET password = ? WHERE username = ?',
      [newPassword, session.username],
    )
    return [(result as { affectedRows: number }).affectedRows ? 1 : 0]
  }
  if (route === 'users/resetPass') {
    const [result] = await getGameDatabase().execute(
      'UPDATE `admin_user` SET password = ? WHERE id = ?',
      sqlValues(body.password, body.id),
    )
    return [affectedRows(result)]
  }
  if (route === 'users/change') {
    const [result] = await getGameDatabase().execute(
      'UPDATE `admin_user` SET username = ?, authorization = ?, channel = ? WHERE id = ?',
      sqlValues(body.username, body.authorization, body.channel, body.id),
    )
    return [affectedRows(result)]
  }
  if (route === 'users/delete') {
    const [result] = await getGameDatabase().execute(
      'DELETE FROM `admin_user` WHERE id = ?',
      sqlValues(body.id),
    )
    return affectedRows(result)
  }
  if (route === 'users/findLogs') {
    const filters = ['1 = 1']
    const params: SqlValue[] = []
    if (body.username && body.username !== 'all') {
      filters.push('username = ?')
      params.push(sqlValue(body.username))
    }
    if (body.type && body.type !== 'all') {
      filters.push('type = ?')
      params.push(sqlValue(body.type))
    }
    if (Array.isArray(body.time) && body.time.length === 2) {
      filters.push('time BETWEEN ? AND ?')
      params.push(sqlValue(body.time[0]), sqlValue(body.time[1]))
    }
    const [rows] = await getDatabase().execute(
      `SELECT id, username, time, type, content, ip FROM operationlog WHERE ${filters.join(' AND ')} ORDER BY id DESC`,
      params,
    )
    return rows
  }
  if (route === 'users/logTotalCount') {
    const filters = ['1 = 1']
    const params: SqlValue[] = []
    if (body.username && body.username !== 'all') {
      filters.push('username = ?')
      params.push(sqlValue(body.username))
    }
    if (body.category && body.category !== 'all') {
      filters.push('type = ?')
      params.push(sqlValue(body.category))
    }
    if (Array.isArray(body.time_data) && body.time_data.length === 2) {
      filters.push('time BETWEEN ? AND ?')
      params.push(sqlValue(body.time_data[0]), sqlValue(body.time_data[1]))
    }
    const [rows] = await getDatabase().execute(
      `SELECT COUNT(*) AS totalCount FROM operationlog WHERE ${filters.join(' AND ')}`,
      params,
    )
    return { code: 200, totalCount: (rows as Array<{ totalCount: number }>)[0]?.totalCount || 0 }
  }

  if (route === 'broadcast/search') return await searchBroadcast(body)
  if (route === 'broadcast/add') {
    const [result] = await getDatabase().execute(
      'INSERT INTO broadcast (serverId, title, submitter, content, type, startTime, stopTime, intervalTime, triggerTime, channel) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      sqlValues(
        body.serverId, body.title, body.submitter, body.content, body.type,
        body.startTime, body.stopTime, body.intervalTime, body.triggerTime, channel,
      ),
    )
    await recordOperation(event, session.username, route, body)
    return { result: (result as { insertId: number }).insertId ? 1 : 0 }
  }
  if (route === 'broadcast/update') {
    const [result] = await getDatabase().execute(
      'UPDATE broadcast SET serverId = ?, title = ?, submitter = ?, content = ?, type = ?, startTime = ?, stopTime = ?, intervalTime = ?, triggerTime = ? WHERE id = ? AND channel = ?',
      sqlValues(
        body.serverId, body.title, body.submitter, body.content, body.type,
        body.startTime, body.stopTime, body.intervalTime, body.triggerTime, body.id, channel,
      ),
    )
    await recordOperation(event, session.username, route, body)
    return [affectedRows(result)]
  }
  if (route === 'broadcast/delete') {
    const [result] = await getDatabase().execute(
      'DELETE FROM broadcast WHERE id = ? AND channel = ?',
      sqlValues(body.id, channel),
    )
    await recordOperation(event, session.username, route, body)
    return affectedRows(result)
  }

  if (route.startsWith('notice/')) {
    throw createError({ statusCode: 501, statusMessage: 'การจัดการประกาศยังต้องตั้งค่า announcement service ก่อน' })
  }
  throw createError({ statusCode: 404, statusMessage: `ไม่พบ API: ${route}` })
})
