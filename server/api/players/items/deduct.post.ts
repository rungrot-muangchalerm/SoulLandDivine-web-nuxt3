import { getAdminSession } from '../../../utils/admin-session'
import { getGameDatabase } from '../../../utils/database'
import { recordOperationLog } from '../../../utils/operation-log'

interface DeductItemBody {
  serverId?: number | string
  userId?: number | string
  rewardType?: number | string
  itemId?: number | string
  itemUid?: number | string
  amount?: number | string
}

const stackTables: Record<string, string> = {
  '2': 'items',
  '9': 'items_herofragment',
  '11': 'items_chatframe',
}

const uniqueTables: Record<string, string> = {
  '3': 'soul_ring',
  '4': 'soul_bone',
  '5': 'equipment',
  '13': 'hidden_weapon',
  '21': 'pet_egg',
}

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  const body = await readBody<DeductItemBody>(event)
  const serverId = Number(body.serverId)
  const userId = Number(body.userId)
  const rewardType = String(body.rewardType ?? '')
  const itemId = Number(body.itemId)
  const itemUid = String(body.itemUid ?? '')
  const amount = Number(body.amount)
  const table = stackTables[rewardType] || uniqueTables[rewardType]

  if (!Number.isSafeInteger(serverId) || serverId <= 0
    || !Number.isSafeInteger(userId) || userId <= 0
    || !Number.isSafeInteger(itemId) || itemId < 0
    || !/^\d+$/.test(itemUid)
    || !table
  ) {
    throw createError({ statusCode: 400, statusMessage: 'ข้อมูลไอเทมไม่ถูกต้องหรือยังไม่รองรับการหัก' })
  }
  if (stackTables[rewardType] && (!Number.isSafeInteger(amount) || amount <= 0)) {
    throw createError({ statusCode: 400, statusMessage: 'จำนวนไอเทมที่ต้องการหักไม่ถูกต้อง' })
  }

  const startUid = serverId * 100_000
  const endUid = (serverId + 1) * 100_000
  if (userId < startUid || userId >= endUid) {
    throw createError({ statusCode: 403, statusMessage: 'ผู้เล่นไม่ได้อยู่ในเซิร์ฟเวอร์ที่เลือก' })
  }

  const database = getGameDatabase()
  const [serverRows] = await database.execute(
    'SELECT id FROM server_list WHERE id = ? LIMIT 1',
    [serverId],
  )
  if (!(serverRows as Array<{ id: number }>).length) {
    throw createError({ statusCode: 404, statusMessage: 'ไม่พบเซิร์ฟเวอร์ที่เลือก' })
  }

  const connection = await database.getConnection()
  try {
    await connection.beginTransaction()
    const [characters] = await connection.execute(
      'SELECT uid FROM `character` WHERE uid = ? AND uid >= ? AND uid < ? LIMIT 1 FOR UPDATE',
      [userId, startUid, endUid],
    )
    if (!(characters as Array<{ uid: number }>).length) {
      throw createError({ statusCode: 404, statusMessage: 'ไม่พบผู้เล่นในเซิร์ฟเวอร์ที่เลือก' })
    }

    let result: unknown
    if (stackTables[rewardType]) {
      ;[result] = await connection.execute(
        `UPDATE \`${table}\` SET pileNum = pileNum - ? WHERE uid = ? AND ownerUid = ? AND typeId = ? AND pileNum >= ?`,
        [amount, itemUid, userId, itemId, amount],
      )
      if (!Number((result as { affectedRows?: number }).affectedRows || 0)) {
        throw createError({ statusCode: 409, statusMessage: 'ไอเทมหายไปหรือมีจำนวนไม่เพียงพอ' })
      }
      await connection.execute(
        `DELETE FROM \`${table}\` WHERE uid = ? AND ownerUid = ? AND pileNum = 0`,
        [itemUid, userId],
      )
    } else {
      const itemIdColumn = rewardType === '21' ? 'id' : 'typeId'
      ;[result] = await connection.execute(
        `DELETE FROM \`${table}\` WHERE uid = ? AND ownerUid = ? AND \`${itemIdColumn}\` = ?`,
        [itemUid, userId, itemId],
      )
      if (!Number((result as { affectedRows?: number }).affectedRows || 0)) {
        throw createError({ statusCode: 404, statusMessage: 'ไม่พบไอเทมในตัวละครที่เลือก' })
      }
    }
    await connection.commit()
  } catch (error) {
    await connection.rollback()
    throw error
  } finally {
    connection.release()
  }

  await recordOperationLog({
    username: session.username,
    ip: event.node.req.socket.remoteAddress || '',
    content: JSON.stringify({ serverId, userId, rewardType, itemId, itemUid, amount }),
    type: '/players/items/deduct',
  })
  return { result: 1 }
})
