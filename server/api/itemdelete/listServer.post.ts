import { getAdminSession } from '../../utils/admin-session'
import { getAccountDatabase, getGameDatabase } from '../../utils/database'
import { recordOperationLog } from '../../utils/operation-log'

interface InventoryListBody {
  serverId?: number | string
  page?: number | string
}

interface InventoryRow {
  UserId: number
  AccountName: string
  CharacterName: string
  ItemCategory: string
  RewardType: string
  ItemId: number | string
  ItemUid: string
  ItemNum: number
  CanDeduct: boolean
  Year: number | null
  MainNature: number | null
  SpecNature1: number | null
  SpecNature2: number | null
  SpecNature3: number | null
  SpecNature4: number | null
  Level: number | null
}

const pageSize = 50
const inventoryTables = [
  `SELECT c.uid AS UserId, c.accountName AS AccountName, c.charName AS CharacterName,
    'ไอเทมทั่วไป' AS ItemCategory, '2' AS RewardType, i.typeId AS ItemId,
    CAST(i.uid AS CHAR) AS ItemUid, i.pileNum AS ItemNum, TRUE AS CanDeduct,
    NULL AS Year, NULL AS MainNature, NULL AS SpecNature1, NULL AS SpecNature2,
    NULL AS SpecNature3, NULL AS SpecNature4, NULL AS Level
  FROM items i JOIN \`character\` c ON c.uid = i.ownerUid
  WHERE c.uid >= ? AND c.uid < ?`,
  `SELECT c.uid AS UserId, c.accountName AS AccountName, c.charName AS CharacterName,
    'วงแหวนวิญญาณ' AS ItemCategory, '3' AS RewardType, i.typeId AS ItemId,
    CAST(i.uid AS CHAR) AS ItemUid, 1 AS ItemNum, TRUE AS CanDeduct,
    i.year AS Year, NULL AS MainNature, NULL AS SpecNature1, NULL AS SpecNature2,
    NULL AS SpecNature3, NULL AS SpecNature4, i.level AS Level
  FROM soul_ring i JOIN \`character\` c ON c.uid = i.ownerUid
  WHERE c.uid >= ? AND c.uid < ?`,
  `SELECT c.uid AS UserId, c.accountName AS AccountName, c.charName AS CharacterName,
    'กระดูกวิญญาณ' AS ItemCategory, '4' AS RewardType, i.typeId AS ItemId,
    CAST(i.uid AS CHAR) AS ItemUid, 1 AS ItemNum, TRUE AS CanDeduct,
    NULL AS Year, i.mainNatureType AS MainNature, i.specId1 AS SpecNature1,
    i.specId2 AS SpecNature2, i.specId3 AS SpecNature3, i.specId4 AS SpecNature4, NULL AS Level
  FROM soul_bone i JOIN \`character\` c ON c.uid = i.ownerUid
  WHERE c.uid >= ? AND c.uid < ?`,
  `SELECT c.uid AS UserId, c.accountName AS AccountName, c.charName AS CharacterName,
    'อุปกรณ์' AS ItemCategory, '5' AS RewardType, i.typeId AS ItemId,
    CAST(i.uid AS CHAR) AS ItemUid, 1 AS ItemNum, TRUE AS CanDeduct,
    NULL AS Year, NULL AS MainNature, NULL AS SpecNature1, NULL AS SpecNature2,
    NULL AS SpecNature3, NULL AS SpecNature4, NULL AS Level
  FROM equipment i JOIN \`character\` c ON c.uid = i.ownerUid
  WHERE c.uid >= ? AND c.uid < ?`,
  `SELECT c.uid AS UserId, c.accountName AS AccountName, c.charName AS CharacterName,
    'อาวุธลับ' AS ItemCategory, '13' AS RewardType, i.typeId AS ItemId,
    CAST(i.uid AS CHAR) AS ItemUid, 1 AS ItemNum, TRUE AS CanDeduct,
    NULL AS Year, NULL AS MainNature, NULL AS SpecNature1, NULL AS SpecNature2,
    NULL AS SpecNature3, NULL AS SpecNature4, i.level AS Level
  FROM hidden_weapon i JOIN \`character\` c ON c.uid = i.ownerUid
  WHERE c.uid >= ? AND c.uid < ?`,
  `SELECT c.uid AS UserId, c.accountName AS AccountName, c.charName AS CharacterName,
    'ชิ้นส่วนตัวละคร' AS ItemCategory, '9' AS RewardType, i.typeId AS ItemId,
    CAST(i.uid AS CHAR) AS ItemUid, i.pileNum AS ItemNum, TRUE AS CanDeduct,
    NULL AS Year, NULL AS MainNature, NULL AS SpecNature1, NULL AS SpecNature2,
    NULL AS SpecNature3, NULL AS SpecNature4, NULL AS Level
  FROM items_herofragment i JOIN \`character\` c ON c.uid = i.ownerUid
  WHERE c.uid >= ? AND c.uid < ?`,
  `SELECT c.uid AS UserId, c.accountName AS AccountName, c.charName AS CharacterName,
    'กรอบแชต' AS ItemCategory, '11' AS RewardType, i.typeId AS ItemId,
    CAST(i.uid AS CHAR) AS ItemUid, i.pileNum AS ItemNum, TRUE AS CanDeduct,
    NULL AS Year, NULL AS MainNature, NULL AS SpecNature1, NULL AS SpecNature2,
    NULL AS SpecNature3, NULL AS SpecNature4, NULL AS Level
  FROM items_chatframe i JOIN \`character\` c ON c.uid = i.ownerUid
  WHERE c.uid >= ? AND c.uid < ?`,
  `SELECT c.uid AS UserId, c.accountName AS AccountName, c.charName AS CharacterName,
    'ไข่สัตว์เลี้ยง' AS ItemCategory, '21' AS RewardType, i.id AS ItemId,
    CAST(i.uid AS CHAR) AS ItemUid, 1 AS ItemNum, TRUE AS CanDeduct,
    NULL AS Year, NULL AS MainNature, NULL AS SpecNature1, NULL AS SpecNature2,
    NULL AS SpecNature3, NULL AS SpecNature4, NULL AS Level
  FROM pet_egg i JOIN \`character\` c ON c.uid = i.ownerUid
  WHERE c.uid >= ? AND c.uid < ?`,
]
const readOnlyInventoryTables = [
  `SELECT c.uid AS UserId, c.accountName AS AccountName, c.charName AS CharacterName,
    'กรอบรูป' AS ItemCategory, '' AS RewardType, i.typeId AS ItemId,
    CAST(i.uid AS CHAR) AS ItemUid, i.pileNum AS ItemNum, FALSE AS CanDeduct,
    NULL AS Year, NULL AS MainNature, NULL AS SpecNature1, NULL AS SpecNature2,
    NULL AS SpecNature3, NULL AS SpecNature4, NULL AS Level
  FROM items_faceframe i JOIN \`character\` c ON c.uid = i.ownerUid
  WHERE c.uid >= ? AND c.uid < ?`,
  `SELECT c.uid AS UserId, c.accountName AS AccountName, c.charName AS CharacterName,
    'แฟชั่น' AS ItemCategory, '' AS RewardType, i.typeId AS ItemId,
    CAST(i.uid AS CHAR) AS ItemUid, i.pileNum AS ItemNum, FALSE AS CanDeduct,
    NULL AS Year, NULL AS MainNature, NULL AS SpecNature1, NULL AS SpecNature2,
    NULL AS SpecNature3, NULL AS SpecNature4, NULL AS Level
  FROM items_fashion i JOIN \`character\` c ON c.uid = i.ownerUid
  WHERE c.uid >= ? AND c.uid < ?`,
]
const currencyFields = [
  'exp', 'gold', 'diamond', 'soulCrystal', 'passcardExp', 'soulPower', 'soulDust',
  'soulBreath', 'friendlyHeart', 'arenaCoin', 'secretAreaCoin', 'spaceTimePower',
  'smeltCoin', 'militaryCoin', 'sotoCoin', 'resonanceCrystal', 'shellCoin',
  'activityCoin', 'campCoin', 'equipReturnItem', 'equipReturnGold', 'travelAffinity',
  'crossChallengeCoin', 'schoolCoin', 'spaceTimeCoin', 'prayCoin', 'driftExploreCoin',
]
const currencyInventoryTables = currencyFields.map(field => `SELECT
    c.uid AS UserId, c.accountName AS AccountName, c.charName AS CharacterName,
    'สกุลเงิน/ทรัพยากร' AS ItemCategory, '1' AS RewardType,
    '${field}' AS ItemId, '0' AS ItemUid, r.\`${field}\` AS ItemNum, FALSE AS CanDeduct,
    NULL AS Year, NULL AS MainNature, NULL AS SpecNature1, NULL AS SpecNature2,
    NULL AS SpecNature3, NULL AS SpecNature4, NULL AS Level
  FROM character_resource r JOIN \`character\` c ON c.uid = r.uid
  WHERE c.uid >= ? AND c.uid < ? AND r.\`${field}\` > 0`)
const allInventoryTables = [...inventoryTables, ...readOnlyInventoryTables, ...currencyInventoryTables]
const inventoryQuery = allInventoryTables.join('\nUNION ALL\n')

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)

  const body = await readBody<InventoryListBody>(event)
  const serverId = Number(body.serverId)
  const page = Number(body.page ?? 1)
  if (!Number.isSafeInteger(serverId) || serverId <= 0 || serverId > 21_474) {
    throw createError({ statusCode: 400, statusMessage: 'รหัสเซิร์ฟเวอร์ไม่ถูกต้อง' })
  }
  if (!Number.isSafeInteger(page) || page <= 0 || !Number.isSafeInteger((page - 1) * pageSize)) {
    throw createError({ statusCode: 400, statusMessage: 'เลขหน้าไม่ถูกต้อง' })
  }

  const database = getGameDatabase()
  const [serverRows] = await getAccountDatabase().execute(
    'SELECT id FROM server_list WHERE id = ? LIMIT 1',
    [serverId],
  )
  if (!(serverRows as Array<{ id: number }>).length) {
    throw createError({ statusCode: 404, statusMessage: 'ไม่พบเซิร์ฟเวอร์ที่เลือก' })
  }

  const serverUidStart = serverId * 100_000
  const serverUidEnd = (serverId + 1) * 100_000
  const rangeValues = allInventoryTables.flatMap(() => [serverUidStart, serverUidEnd])
  const [countRows] = await database.execute(
    `SELECT COUNT(*) AS total FROM (${inventoryQuery}) inventory`,
    rangeValues,
  )
  const total = Number((countRows as Array<{ total: number }>)[0]?.total || 0)
  const [rows] = await database.execute(
    `SELECT * FROM (${inventoryQuery}) inventory
    ORDER BY UserId, RewardType, ItemId, ItemUid
    LIMIT ? OFFSET ?`,
    [...rangeValues, pageSize, (page - 1) * pageSize],
  )

  await recordOperationLog({
    username: session.username,
    ip: event.node.req.socket.remoteAddress || '',
    content: JSON.stringify({ serverId, page, pageSize }),
    type: '/itemdelete/listServer',
  })

  return { data: rows as InventoryRow[], page, pageSize, total }
})
