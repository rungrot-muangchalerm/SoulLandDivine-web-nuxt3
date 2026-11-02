import { existsSync } from 'node:fs'
import { readdir } from 'node:fs/promises'
import { resolve } from 'node:path'
import rewardCatalog from '../../../data/email-reward-catalog.json'
import { getAdminSession } from '../../utils/admin-session'
import { getGameDatabase } from '../../utils/database'

interface ShopItemRow {
  itemInfo: string
}

interface EmailItem {
  id: string
  rewardType: string
  iconUrl: string | null
  name?: string
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
  '7': 'ตัวละคร',
}

export default defineEventHandler(async (event) => {
  await getAdminSession(event)

  const iconDirectories = [
    resolve(process.cwd(), 'public', 'icons_renamed'),
    resolve(process.cwd(), '.output', 'public', 'icons_renamed'),
    resolve(process.cwd(), 'icons_renamed'),
  ]
  const iconDirectory = iconDirectories.find((directory) => existsSync(directory))
  if (!iconDirectory) {
    throw createError({ statusCode: 500, statusMessage: 'ไม่พบโฟลเดอร์ public/icons_renamed สำหรับโหลดรูปไอเทม' })
  }
  const iconFiles = await readdir(iconDirectory)
  const iconUrls = new Map<string, string>()
  for (const filename of iconFiles) {
    const match = /^(\d+)_.*\.png$/i.exec(filename)
    if (match && (
      !iconUrls.has(match[1])
      || filename.startsWith(`${match[1]}_gameclient_`)
    )) {
      iconUrls.set(match[1], `/icons_renamed/${encodeURIComponent(filename)}`)
    }
  }

  const [rows] = await getGameDatabase().query(
    "SELECT itemInfo FROM shop_item WHERE itemInfo <> '' ORDER BY uid, shopType",
  )

  const items = new Map<string, EmailItem>()
  for (const { itemInfo } of rows as ShopItemRow[]) {
    for (const reward of itemInfo.split('|')) {
      const match = /^(\d+):(\d+):\d+(?:@.*)?$/.exec(reward.trim())
      if (!match || !rewardTypes[match[2]]) continue

      const key = `${match[2]}:${match[1]}`
      items.set(key, {
        id: match[1],
        rewardType: match[2],
        iconUrl: iconUrls.get(match[1]) || null,
      })
    }
  }

  for (const reward of rewardCatalog) {
    items.set(`${reward.rewardType}:${reward.id}`, {
      ...reward,
      iconUrl: iconUrls.get(reward.id) || null,
    })
  }

  return [...items.values()].sort((first, second) =>
    Number(first.rewardType) - Number(second.rewardType)
    || Number(first.id) - Number(second.id),
  )
})
