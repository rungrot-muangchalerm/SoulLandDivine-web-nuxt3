import { timingSafeEqual } from 'node:crypto'
import { getCookie } from 'h3'
import { readFile } from 'node:fs/promises'
import { resolve } from 'node:path'
import { getAccountDatabase, getDatabase, getGameDatabase } from '../utils/database'
import { getAdminSession } from '../utils/admin-session'
import { sendGamePacket } from '../utils/game-server'
import { recordOperationLog as writeOperationLog } from '../utils/operation-log'
import { enqueueCustomEmail } from '../utils/custom-email-queue'
import {
  getEmailRewardBatches,
  MAX_EMAIL_REWARD_BATCH_LENGTH,
} from '../utils/email-rewards'

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

function getEmailRewards(body: Body) {
  const rewards = Array.isArray(body.rewards)
    ? body.rewards
    : [body.reward1, body.reward2, body.reward3]
  if (rewards.some((reward) => typeof reward !== 'string')) {
    throw createError({ statusCode: 400, statusMessage: 'รายการไอเทมไม่ถูกต้อง' })
  }
  return rewards.filter((reward): reward is string => Boolean(reward))
}

function getCustomEmailRecipients(value: unknown) {
  if (typeof value !== 'string') {
    throw createError({ statusCode: 400, statusMessage: 'กรุณาระบุ serverId:UID ของผู้รับ' })
  }

  const entries = value.split('|').map((entry) => entry.trim())
  if (!entries.length || entries.length > 50) {
    throw createError({ statusCode: 400, statusMessage: 'ระบุผู้รับได้ตั้งแต่ 1 ถึง 50 คนต่อครั้ง' })
  }

  const recipients = entries.map((entry) => {
    const match = /^([1-9]\d*):([1-9]\d*)$/.exec(entry)
    if (!match) {
      throw createError({ statusCode: 400, statusMessage: 'รูปแบบผู้รับไม่ถูกต้อง ใช้ serverId:UID และคั่นหลายคนด้วย |' })
    }

    const serverId = Number(match[1])
    const uid = Number(match[2])
    if (
      !Number.isSafeInteger(serverId)
      || serverId > 2147483647
      || !Number.isSafeInteger(uid)
      || uid > 2147483647
    ) {
      throw createError({ statusCode: 400, statusMessage: 'serverId หรือ UID ต้องไม่เกิน 2147483647' })
    }
    return { serverId, uid }
  })

  if (new Set(recipients.map(({ serverId, uid }) => `${serverId}:${uid}`)).size !== recipients.length) {
    throw createError({ statusCode: 400, statusMessage: 'มีผู้รับซ้ำในรายการ' })
  }
  return recipients
}

function characterLength(value: string) {
  return value.length
}

function validEmailReward(value: string) {
  const match = /^([1-9]\d*):(1|2|3|4|5|6|7|9|11|13|21):([1-9]\d*)(?:@([0-9:]+))?$/.exec(value)
  if (!match) return false
  if (match[2] === '3' && !/^[1-9]\d*$/.test(match[4] || '')) return false
  const numericValues = [match[1], match[3], ...(match[4] ? match[4].split(':') : [])]
  return numericValues.every((item) =>
    Number.isSafeInteger(Number(item)) && Number(item) <= 2147483647,
  )
}

function isSoulRingReward(reward: string) {
  return /^([1-9]\d*):3:([1-9]\d*)@([1-9]\d*)$/.test(reward)
}

function getSoulRingEmailBatches(rewards: string[]) {
  const batches: Array<{ rewards: string[]; repeatCount: number }> = []
  for (const reward of rewards) {
    const match = /^([1-9]\d*):3:([1-9]\d*)@([1-9]\d*)$/.exec(reward)
    if (!match) continue
    const quantity = Number(match[2])
    const singleRingReward = `${match[1]}:3:1@${match[3]}`
    batches.push({ rewards: [singleRingReward], repeatCount: quantity })
  }
  return batches
}

async function sendEmailRewardBatches(
  rewards: string[],
  sendBatch: (batch: string[]) => Promise<unknown>,
) {
  const batches = getEmailRewardBatches(rewards)
  const results: unknown[] = []
  for (const batch of batches) {
    results.push(await sendBatch(batch))
  }

  if (results.length === 1) return results[0]

  const failedBatches = results.flatMap((result, index) =>
    typeof result === 'object' && result !== null && 'result' in result
      && result.result === 1
      ? []
      : [index + 1],
  )
  return {
    result: failedBatches.length ? 0 : 1,
    sent: results.length - failedBatches.length,
    total: results.length,
    batchCount: results.length,
    failedBatches,
  }
}

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
      reward: getEmailRewards(b).join('|'),
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

async function searchBroadcast(body: Body, allChannels: boolean) {
  const filters = allChannels ? [] : ['channel = ?']
  const params: SqlValue[] = allChannels ? [] : [sqlValue(body.channel)]
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
  const allChannels = event.context.adminChannel === '*'
  const channel = String(body.channel ?? event.context.adminChannel ?? getCookie(event, 'channel') ?? '')
  const allChannelRoutes = new Set([
    'baseinfo/serverlist',
    'baseinfo/userlist',
    'set/searchChannelOne',
    'users/searchall',
    'users/searchOne',
    'users/findLogs',
    'users/logTotalCount',
    'broadcast/search',
    'servers/getServers',
    'email/send',
    'email/sendCustom',
    'welfare/searchGrade',
    'welfare/searchPlayer',
    'welfare/addPlayer',
    'welfare/deletePlayer',
  ])
  if (allChannels && !allChannelRoutes.has(route)) {
    throw createError({ statusCode: 501, statusMessage: 'ฟีเจอร์นี้ยังไม่รองรับการทำงานกับฐานข้อมูลโดยตรง' })
  }
  if (allChannels && ['email/send', 'email/sendCustom'].includes(route)) {
    if (!channel || channel === '*') {
      throw createError({ statusCode: 400, statusMessage: 'กรุณาระบุช่องทางเกมสำหรับส่งอีเมล' })
    }
    const [channels] = await getGameDatabase().execute(
      'SELECT `index` FROM channel_list WHERE `index` = ? LIMIT 1',
      [channel],
    )
    if (!(channels as Array<{ index: string }>).length) {
      throw createError({ statusCode: 400, statusMessage: 'ไม่พบช่องทางเกมที่เลือก' })
    }
  }
  if (!allChannels && (!channel || channel !== event.context.adminChannel)) {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์ใช้ช่องทางนี้' })
  }
  if (!allChannels) body.channel = channel
  if (route.startsWith('users/') && route !== 'users/changePsw' && session.authorization !== 'admin') {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์จัดการผู้ใช้หรือประวัติการทำงาน' })
  }
  if (
    ['set/addChannel', 'set/changeChannel', 'set/deleteChannel'].includes(route)
    && !['admin', 'server'].includes(session.authorization)
  ) {
    throw createError({ statusCode: 403, statusMessage: 'ไม่มีสิทธิ์จัดการช่องทาง' })
  }

  if (route === 'email/send') {
    const mailId = String(body.mailId ?? '').trim()
    if (!/^[1-9]\d*$/.test(mailId) || Number(mailId) > 2147483647) {
      throw createError({ statusCode: 400, statusMessage: 'รหัสเทมเพลตต้องเป็นจำนวนเต็มบวกไม่เกิน 2147483647' })
    }
    const rewards = getEmailRewards(body)
    if (rewards.some((item) => item.length > MAX_EMAIL_REWARD_BATCH_LENGTH || !validEmailReward(item))) {
      throw createError({ statusCode: 400, message: 'ข้อมูลรางวัลไม่ถูกต้อง' })
    }
  }

  if (['welfare/searchPlayer', 'welfare/addPlayer', 'welfare/deletePlayer'].includes(route)) {
    const serverId = Number(body.serverId)
    const uidText = body.uid === undefined || body.uid === null ? '' : String(body.uid).trim()
    const uid = uidText ? Number(uidText) : undefined
    const welfareId = Number(body.welfareId)
    if (
      !Number.isSafeInteger(serverId)
      || serverId <= 0
      || (uidText !== '' && (!/^\d{1,10}$/.test(uidText) || uid === undefined || !Number.isSafeInteger(uid) || uid <= 0))
      || (route !== 'welfare/searchPlayer' && (!Number.isSafeInteger(welfareId) || welfareId <= 0))
    ) {
      throw createError({ statusCode: 400, statusMessage: 'รหัสเซิร์ฟเวอร์, UID หรือรหัสสิทธิประโยชน์ไม่ถูกต้อง' })
    }

    const [servers] = await getAccountDatabase().execute(
      'SELECT id FROM server_list WHERE id = ? LIMIT 1',
      [serverId],
    )
    if (!(servers as Array<{ id: number }>).length) {
      throw createError({ statusCode: 404, statusMessage: 'ไม่พบเซิร์ฟเวอร์ที่เลือก' })
    }

    if (route === 'welfare/searchPlayer') {
      const filters = ['ServerId = ?']
      const params: SqlValue[] = [serverId]
      if (uid !== undefined) {
        filters.push('Uid = ?')
        params.push(uid)
      }
      const [rows] = await getAccountDatabase().execute(
        `SELECT ServerId AS serverId, Uid AS uid, WelfareId AS id, Name AS name, LastSend AS LastTime FROM welfare_player WHERE ${filters.join(' AND ')} ORDER BY Uid, WelfareId`,
        params,
      )
      return { result: 1, list: rows }
    }

    if (uid === undefined) {
      throw createError({ statusCode: 400, statusMessage: 'กรุณาระบุ UID ผู้เล่น' })
    }

    if (route === 'welfare/addPlayer') {
      const [result] = await getAccountDatabase().execute(
        'INSERT INTO welfare_player (ServerId, Uid, WelfareId, Name, LastSend) VALUES (?, ?, ?, ?, ?)',
        [serverId, uid, welfareId, '', 0],
      )
      await recordOperation(event, session.username, route, body)
      return { result: affectedRows(result) }
    }

    const [result] = await getAccountDatabase().execute(
      'DELETE FROM welfare_player WHERE ServerId = ? AND Uid = ? AND WelfareId = ?',
      [serverId, uid, welfareId],
    )
    await recordOperation(event, session.username, route, body)
    return { result: affectedRows(result) }
  }

  if (route === 'email/send' && body.emailType === 'allserver') {
    const mailId = typeof body.mailId === 'string' ? body.mailId.trim() : ''
    const serverId = typeof body.serverId === 'string' || typeof body.serverId === 'number'
      ? String(body.serverId)
      : ''
    const rewards = getEmailRewards(body)
    if (
      !mailId
      || !/^\d+$/.test(serverId)
      || !Number.isSafeInteger(Number(serverId))
      || Number(serverId) > 2147483647
    ) {
      throw createError({ statusCode: 400, statusMessage: 'ข้อมูลอีเมลหรือไอเทมไม่ถูกต้อง' })
    }

    const result = await sendEmailRewardBatches(rewards, (batch) => sendGamePacket({
      mailId,
      serverId,
      uid: '0',
      reward: batch.join('|'),
    }, 10020, channel))
    await recordOperation(event, session.username, route, body)
    return result
  }

  if (route === 'email/sendCustom') {
    const emailType = body.emailType
    const title = typeof body.title === 'string' ? body.title.trim() : ''
    const senderName = session.username
    const content = typeof body.content === 'string' ? body.content : ''
    const rewards = getEmailRewards(body)

    if (!title) {
      throw createError({ statusCode: 400, statusMessage: 'กรุณากรอกหัวข้ออีเมล' })
    }
    if (!content.trim()) {
      throw createError({ statusCode: 400, statusMessage: 'กรุณากรอกเนื้อหาอีเมล' })
    }
    if (characterLength(title) > 255 || characterLength(senderName) > 255 || characterLength(content) > 2550) {
      throw createError({
        statusCode: 400,
        statusMessage: 'หัวข้อ/ชื่อผู้ส่งต้องไม่เกิน 255 ตัวอักษร และเนื้อหาต้องไม่เกิน 2550 ตัวอักษร',
      })
    }
    if (rewards.some((item) =>
      item.length > MAX_EMAIL_REWARD_BATCH_LENGTH || !validEmailReward(item),
    )) {
      throw createError({ statusCode: 400, message: 'ข้อมูลรางวัลไม่ถูกต้อง' })
    }
    let targets: Array<{ serverId: number; uid: number }>
    if (emailType === 'allserver') {
      const selectedServer = String(body.serverId ?? '').trim()
      if (selectedServer === '0') {
        targets = [{ serverId: 0, uid: 0 }]
      } else if (/^[1-9]\d*$/.test(selectedServer) && Number.isSafeInteger(Number(selectedServer))) {
        targets = [{ serverId: Number(selectedServer), uid: 0 }]
      } else {
        throw createError({ statusCode: 400, statusMessage: 'กรุณาเลือกเซิร์ฟเวอร์ผู้รับให้ถูกต้อง' })
      }
    } else if (emailType === 'personalemail') {
      targets = getCustomEmailRecipients(body.uidList)
    } else {
      throw createError({ statusCode: 400, statusMessage: 'ประเภทผู้รับอีเมลไม่ถูกต้อง' })
    }

    if (!targets.length) {
      throw createError({ statusCode: 404, statusMessage: 'ไม่พบเซิร์ฟเวอร์ผู้รับ' })
    }
    const nonRingRewards = rewards.filter((reward) => !isSoulRingReward(reward))
    const nonRingRewardBatches = nonRingRewards.length
      ? getEmailRewardBatches(nonRingRewards)
      : rewards.length === 0 ? [[]] : []
    const rewardBatches = [
      ...nonRingRewardBatches.map((batch) => ({ rewards: batch, repeatCount: 1 })),
      ...getSoulRingEmailBatches(rewards),
    ]
    const batchCount = rewardBatches.reduce((total, batch) => total + batch.repeatCount, 0)
    const totalEmailCount = batchCount * targets.length
    if (!Number.isSafeInteger(totalEmailCount)) {
      throw createError({
        statusCode: 400,
        message: 'จำนวนอีเมลในคำขอเกินขีดจำกัดที่ระบบรองรับ',
      })
    }
    const serverIds = [...new Set(targets.map(({ serverId }) => serverId).filter((serverId) => serverId > 0))]
    if (serverIds.length) {
      const placeholders = serverIds.map(() => '?').join(', ')
      const [serverRows] = await getAccountDatabase().execute(
        `SELECT id FROM server_list WHERE id IN (${placeholders})`,
        serverIds,
      )
      const validServerIds = new Set((serverRows as Array<{ id: number }>).map(({ id }) => Number(id)))
      if (serverIds.some((serverId) =>
        !Number.isSafeInteger(serverId)
        || serverId > 2147483647
        || !validServerIds.has(serverId),
      )) {
        throw createError({ statusCode: 404, statusMessage: 'ไม่พบเซิร์ฟเวอร์ของผู้รับบางราย' })
      }
    }

    await recordOperation(event, session.username, route, { ...body, senderName })
    const jobId = enqueueCustomEmail({
      channel,
      username: session.username,
      title,
      senderName,
      content,
      targets,
      rewardBatches,
    })
    return {
      result: 1,
      queued: true,
      jobId,
      totalEmailCount,
      batchCount,
      targetCount: targets.length,
    }
  }

  const gameRoute = gameRoutes[route]
  if (gameRoute) {
    if (route === 'email/send') {
      const rewards = getEmailRewards(body)
      const result = await sendEmailRewardBatches(rewards, (batch) =>
        sendGamePacket(gameRoute.payload({ ...body, rewards: batch }), gameRoute.protocol, channel),
      )
      await recordOperation(event, session.username, route, body)
      return result
    }
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
    return allChannels
      ? rows
      : (rows as Array<{ channel: string }>).filter((row) => row.channel?.includes(channel))
  }
  if (route === 'set/searchChannelOne') {
    if (allChannels && !body.channel) {
      const [rows] = await getGameDatabase().query(
        'SELECT id, name, `index`, ip, url FROM channel_list ORDER BY id',
      )
      return rows
    }
    const [rows] = await getGameDatabase().execute(
      'SELECT id, name, `index`, ip, url FROM channel_list WHERE `index` = ? LIMIT 1',
      [allChannels ? sqlValue(body.channel) : channel],
    )
    return rows
  }
  if (route === 'set/addChannel') {
    const [result] = await getGameDatabase().execute(
      'INSERT INTO channel_list (name, `index`, ip, url) VALUES (?, ?, ?, ?)',
      sqlValues(body.name, body.index, body.ip, body.url),
    )
    await recordOperation(event, session.username, route, body)
    return { result: (result as { insertId: number }).insertId ? 1 : 0 }
  }
  if (route === 'set/changeChannel') {
    const [result] = await getGameDatabase().execute(
      'UPDATE channel_list SET name = ?, `index` = ?, ip = ?, url = ? WHERE id = ?',
      sqlValues(body.name, body.index, body.ip, body.url, body.id),
    )
    await recordOperation(event, session.username, route, body)
    return [affectedRows(result)]
  }
  if (route === 'set/deleteChannel') {
    const [result] = await getGameDatabase().execute(
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

  if (route === 'broadcast/search') return await searchBroadcast(body, allChannels)
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
