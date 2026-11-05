import { existsSync } from 'node:fs'
import { readdir } from 'node:fs/promises'
import { resolve } from 'node:path'
import equipmentIcons from '../../../data/email-equipment-icons.json'
import heroFragmentIds from '../../../data/email-hero-fragment-ids.json'
import heroFragmentIcons from '../../../data/email-hero-fragment-icons.json'
import itemIconFallbacks from '../../../data/email-item-icon-fallbacks.json'
import hiddenWeaponIcons from '../../../data/email-hidden-weapon-icons.json'
import clientItemNames from '../../../data/email-item-names.json'
import petEggIcons from '../../../data/email-pet-egg-icons.json'
import rewardCatalog from '../../../data/email-reward-catalog.json'
import itemNames from '../../../data/item-names-th.json'
import soulRingNames from '../../../data/soul-ring-names-th.json'
import { getEquipmentQuality } from '../../utils/equipment-quality'
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
  quality?: number
}

const clientItemNamesByType: Record<string, Record<string, string>> = clientItemNames

const rewardTypes: Record<string, string> = {
  '1': 'สกุลเงิน',
  '2': 'ไอเทมทั่วไป',
  '3': 'วงแหวนวิญญาณ',
  '4': 'กระดูกวิญญาณ',
  '5': 'อุปกรณ์',
  '9': 'เศษวิญญาณ',
  '11': 'กรอบแชต',
  '13': 'อาวุธลับ',
  '21': 'ไข่สัตว์เลี้ยง',
  '7': 'ตัวละคร',
}

const equipmentIconById = new Map(Object.entries(equipmentIcons))
const heroFragmentIconById = new Map(Object.entries(heroFragmentIcons))
const itemIconFallbackById = new Map(Object.entries(itemIconFallbacks))
const hiddenWeaponIconById = new Map(Object.entries(hiddenWeaponIcons))
const petEggIconById = new Map(Object.entries(petEggIcons))

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
  const petEggIconDirectory = resolve(iconDirectory, '..', 'icons_pet_eggs')
  if (!existsSync(petEggIconDirectory)) {
    throw createError({ statusCode: 500, statusMessage: 'ไม่พบโฟลเดอร์ public/icons_pet_eggs สำหรับโหลดรูปไข่สัตว์เลี้ยง' })
  }
  const hiddenWeaponIconDirectory = resolve(iconDirectory, '..', 'icons_hidden_weapons')
  if (!existsSync(hiddenWeaponIconDirectory)) {
    throw createError({ statusCode: 500, statusMessage: 'ไม่พบโฟลเดอร์ public/icons_hidden_weapons สำหรับโหลดรูปอาวุธลับ' })
  }
  const heroFragmentIconDirectory = resolve(iconDirectory, '..', 'icons_hero_fragments')
  if (!existsSync(heroFragmentIconDirectory)) {
    throw createError({ statusCode: 500, statusMessage: 'ไม่พบโฟลเดอร์ public/icons_hero_fragments สำหรับโหลดรูปเศษวิญญาณและตราวิญญาณเทพ' })
  }

  const iconFiles = await readdir(iconDirectory)
  const equipmentIconFiles = new Set(await readdir(equipmentIconDirectory))
  const hiddenWeaponIconFiles = new Set(await readdir(hiddenWeaponIconDirectory))
  const petEggIconFiles = new Set(await readdir(petEggIconDirectory))
  const heroFragmentIconFiles = new Set(await readdir(heroFragmentIconDirectory))
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

  const getIconUrl = (id: string, rewardType: string) => {
    if (rewardType === '13') {
      const hiddenWeaponIcon = hiddenWeaponIconById.get(id)
      const hiddenWeaponFilename = hiddenWeaponIcon && `${hiddenWeaponIcon}.png`
      if (hiddenWeaponFilename && hiddenWeaponIconFiles.has(hiddenWeaponFilename)) {
        return `/icons_hidden_weapons/${encodeURIComponent(hiddenWeaponFilename)}`
      }
    }

    if (rewardType === '21') {
      const petEggIcon = petEggIconById.get(id)
      const petEggFilename = petEggIcon && `${petEggIcon}.png`
      if (petEggFilename && petEggIconFiles.has(petEggFilename)) {
        return `/icons_pet_eggs/${encodeURIComponent(petEggFilename)}`
      }
    }

    const numericIconUrl = iconUrls.get(id)
    if (numericIconUrl) return numericIconUrl

    if (rewardType === '2' || rewardType === '9') {
      const heroFragmentIcon = heroFragmentIconById.get(id)
      if (heroFragmentIcon && heroFragmentIconFiles.has(heroFragmentIcon)) {
        return `/icons_hero_fragments/${encodeURIComponent(heroFragmentIcon)}`
      }

      const numericId = Number(id)
      const heroId = (
        (numericId >= 9021 && numericId <= 9092)
        || numericId === 9191
        || numericId === 9192
      )
        ? String(numericId - 9000)
        : numericId >= 19021 && numericId <= 19089
          ? String(numericId - 19000)
          : undefined
      const heroIconUrl = heroId && iconUrls.get(heroId)
      if (heroIconUrl) return heroIconUrl

      const fallbackId = itemIconFallbackById.get(id)
      const fallbackIconUrl = fallbackId && iconUrls.get(fallbackId)
      if (fallbackIconUrl) return fallbackIconUrl
    }

    const equipmentIcon = equipmentIconById.get(id)
    const filename = equipmentIcon && `${equipmentIcon}.png`
    if (filename && equipmentIconFiles.has(filename)) {
      return `/icons_equipment/${encodeURIComponent(filename)}`
    }

    return null
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
        iconUrl: getIconUrl(match[1], match[2]),
        name: getItemName(match[1], match[2]),
        quality: match[2] === '5' ? getEquipmentQuality(match[1]) : undefined,
      })
    }
  }

  for (const reward of rewardCatalog) {
    items.set(`${reward.rewardType}:${reward.id}`, {
      ...reward,
      iconUrl: getIconUrl(reward.id, reward.rewardType),
      name: getClientItemName(reward.id, reward.rewardType)
        || getThaiName(reward.name)
        || getThaiName(soulRingNames[reward.id as keyof typeof soulRingNames])
        || getThaiName(itemNames[reward.id as keyof typeof itemNames]),
      quality: reward.rewardType === '5' ? getEquipmentQuality(reward.id) : undefined,
    })
  }

  for (const [rewardType, names] of Object.entries(clientItemNamesByType)) {
    if (!rewardTypes[rewardType]) continue

    for (const [id, name] of Object.entries(names)) {
      items.set(`${rewardType}:${id}`, {
        id,
        rewardType,
        iconUrl: getIconUrl(id, rewardType),
        name,
        quality: rewardType === '5' ? getEquipmentQuality(id) : undefined,
      })
    }
  }

  for (const id of heroFragmentIds) {
    const name = getClientItemName(id, '9')
    if (!name) {
      throw new Error(`ไม่พบชื่อภาษาไทยสำหรับเศษวิญญาณ ${id}`)
    }

    items.set(`9:${id}`, {
      id,
      rewardType: '9',
      iconUrl: getIconUrl(id, '9'),
      name,
    })
  }

  return [...items.values()].sort((first, second) =>
    Number(first.rewardType) - Number(second.rewardType)
    || Number(first.id) - Number(second.id),
  )
})
