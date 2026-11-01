import { getAdminSession } from '../../utils/admin-session'
import { getGameDatabase } from '../../utils/database'

interface ShopItemRow {
  itemInfo: string
}

interface EmailItem {
  id: string
  rewardType: string
}

const rewardTypes: Record<string, string> = {
  '1': 'สกุลเงิน',
  '2': 'ไอเทมทั่วไป',
  '3': 'วงแหวนวิญญาณ',
  '4': 'กระดูกวิญญาณ',
  '5': 'อุปกรณ์',
  '9': 'แก่นวิญญาณ',
  '11': 'กรอบแชต',
  '13': 'อาวุธลับ',
  '21': 'ไข่สัตว์เลี้ยง',
}

export default defineEventHandler(async (event) => {
  await getAdminSession(event)

  const [rows] = await getGameDatabase().query(
    "SELECT itemInfo FROM shop_item WHERE itemInfo <> '' ORDER BY uid, shopType",
  )

  const items = new Map<string, EmailItem>()
  for (const { itemInfo } of rows as ShopItemRow[]) {
    for (const reward of itemInfo.split('|')) {
      const match = /^(\d+):(\d+):\d+(?:@.*)?$/.exec(reward.trim())
      if (!match || !rewardTypes[match[2]]) continue

      const key = `${match[2]}:${match[1]}`
      items.set(key, { id: match[1], rewardType: match[2] })
    }
  }

  return [...items.values()].sort((first, second) =>
    Number(first.rewardType) - Number(second.rewardType)
    || Number(first.id) - Number(second.id),
  )
})
