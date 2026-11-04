import { existsSync } from 'node:fs'
import { readdir } from 'node:fs/promises'
import { resolve } from 'node:path'
import equipmentIcons from '../../../data/email-equipment-icons.json'
import clientItemNames from '../../../data/email-item-names.json'
import rewardCatalog from '../../../data/email-reward-catalog.json'
import itemNames from '../../../data/item-names-th.json'
import soulRingNames from '../../../data/soul-ring-names-th.json'
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

const clientItemNamesByType: Record<string, Record<string, string>> = clientItemNames

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

const equipmentIconById = new Map(Object.entries(equipmentIcons))

function getThaiName(value: unknown): string | undefined {
  return typeof value === 'string' && /[\u0E00-\u0E7F]/.test(value)
    ? value
    : undefined
}

function getClientItemName(id: string, rewardType: string) {
  return clientItemNamesByType[rewardType]?.[id]
    || clientItemNamesByType['2']?.[id]
}

function getItemName(id: string, rewardType: string) {
  return getClientItemName(id, rewardType)
    || getThaiName(soulRingNames[id as keyof typeof soulRingNames])
    || getThaiName(itemNames[id as keyof typeof itemNames])
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
  const equipmentIconDirectory = resolve(iconDirectory, '..', 'icons_equipment')
  if (!existsSync(equipmentIconDirectory)) {
    throw createError({ statusCode: 500, statusMessage: 'ไม่พบโฟลเดอร์ public/icons_equipment สำหรับโหลดรูปอุปกรณ์' })
  }

  const iconFiles = await readdir(iconDirectory)
  const equipmentIconFiles = new Set(await readdir(equipmentIconDirectory))
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

  const getIconUrl = (id: string) => {
    const numericIconUrl = iconUrls.get(id)
    if (numericIconUrl) return numericIconUrl

    const equipmentIcon = equipmentIconById.get(id)
    const filename = equipmentIcon && `${equipmentIcon}.png`
    return filename && equipmentIconFiles.has(filename)
      ? `/icons_equipment/${encodeURIComponent(filename)}`
      : null
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
        iconUrl: getIconUrl(match[1]),
        name: getItemName(match[1], match[2]),
      })
    }
  }

  for (const reward of rewardCatalog) {
    items.set(`${reward.rewardType}:${reward.id}`, {
      ...reward,
      iconUrl: getIconUrl(reward.id),
      name: getClientItemName(reward.id, reward.rewardType)
        || getThaiName(reward.name)
        || getThaiName(soulRingNames[reward.id as keyof typeof soulRingNames])
        || getThaiName(itemNames[reward.id as keyof typeof itemNames]),
    })
  }

  for (const [rewardType, names] of Object.entries(clientItemNamesByType)) {
    if (!rewardTypes[rewardType]) continue

    for (const [id, name] of Object.entries(names)) {
      items.set(`${rewardType}:${id}`, {
        id,
        rewardType,
        iconUrl: getIconUrl(id),
        name,
      })
    }
  }

  return [...items.values()].sort((first, second) =>
    Number(first.rewardType) - Number(second.rewardType)
    || Number(first.id) - Number(second.id),
  )
})
