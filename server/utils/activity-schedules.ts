import { fetchGameAdminApi } from './game-admin-api'

export interface ActivityScheduleField {
  key: string
  label: string
  format: string
}

export interface ActivityScheduleConfig {
  id: string
  rootId: string
  title: string
  description: string
  fields: ActivityScheduleField[]
}

export interface ActivityScheduleRow {
  id: number
  name: string
  configId: string
  configTitle: string
  fields: Record<string, string>
  imageUrl: string
  canOpenImmediately: boolean
}

const activityGiftTypeBanners: Record<number, number> = {
  1: 1,
  2: 4,
  3: 4,
  5: 11,
  8: 7,
  9: 3,
  11: 9,
  12: 2,
  13: 1,
  14: 15,
  15: 11,
  17: 55,
  18: 7,
  19: 5,
  20: 4,
  21: 3,
  22: 12,
  23: 14,
  24: 14,
  25: 15,
  26: 16,
  27: 31,
  28: 28,
  29: 4,
  30: 22,
  31: 28,
  32: 86,
  33: 12,
  34: 16,
  35: 53,
  36: 36,
  37: 52,
  38: 5,
  39: 7,
  40: 55,
  41: 41,
  42: 54,
  43: 81,
  44: 86,
  45: 42,
  46: 93,
  47: 16,
}

const activityTypeBanners: Record<number, number> = {
  101: 12,
  102: 7,
  103: 3,
  104: 3,
  105: 11,
  107: 12,
  110: 5,
  111: 7,
  113: 2,
  115: 7,
}

const activityFallbackBanners: Record<string, number> = {
  'recharge-tabs': 4,
  'recharge-time': 4,
  'direct-purchase-time': 4,
  'activity-info': 3,
  'special-activity': 7,
  'special-activity-table': 7,
  'overseas-activity': 4,
  'camp-timers': 16,
  'integral-boss': 9,
  'theme-boss-time': 9,
  'hunting-unlocks': 9,
  'wish-pool': 54,
}

function activityBannerId(configId: string, values: Record<string, string>) {
  const giftType = Number(values.GiftType)
  if (giftType && activityGiftTypeBanners[giftType]) return activityGiftTypeBanners[giftType]

  const activityType = Number(values.Type || values.SpecialType)
  if (activityType && activityTypeBanners[activityType]) return activityTypeBanners[activityType]

  return activityFallbackBanners[configId] || 4
}

export const activityScheduleConfigs: ActivityScheduleConfig[] = [
  {
    id: 'recharge-tabs',
    rootId: 'RechargeGiftTab',
    title: 'แท็บกิจกรรมและแพ็กเกจ',
    description: 'ช่วงแสดงแท็บ รวมถึงกิจกรรมเรือมังกรและเรือพาย',
    fields: [
      { key: 'ShowStart', label: 'เริ่มแสดง', format: 'วันที่และเวลา: YYYY-M-D HH:mm:ss' },
      { key: 'ShowEnd', label: 'หยุดแสดง', format: 'วันที่และเวลา: YYYY-M-D HH:mm:ss' },
      { key: 'ShowWeekStart', label: 'เริ่มตามวันในสัปดาห์', format: 'วันเริ่ม|วันจบ|HH:mm:ss (เว้นว่างเพื่อไม่ใช้)' },
      { key: 'ShowWeekEnd', label: 'จบตามวันในสัปดาห์', format: 'วันเริ่ม|วันจบ|HH:mm:ss (เว้นว่างเพื่อไม่ใช้)' },
      { key: 'OpenStart', label: 'วันเปิดเซิร์ฟเวอร์เริ่ม', format: 'จำนวนวันหลังเปิดเซิร์ฟเวอร์ หรือ -1' },
      { key: 'OpenEnd', label: 'วันเปิดเซิร์ฟเวอร์จบ', format: 'จำนวนวันหลังเปิดเซิร์ฟเวอร์' },
      { key: 'TabShowEnd', label: 'เวลาซ่อนแท็บ', format: 'วันที่และเวลา: YYYY-M-D HH:mm:ss' },
      { key: 'GiveReward', label: 'เวลาสิ้นสุดรับรางวัล', format: 'วันที่และเวลา: YYYY-M-D HH:mm:ss' },
    ],
  },
  {
    id: 'recharge-time',
    rootId: 'RechargeGiftTime',
    title: 'กิจกรรมเติมเงิน',
    description: 'กำหนดช่วงเวลาของกิจกรรมเติมเงินตาม XML เกม',
    fields: [
      { key: 'ShowStart', label: 'เริ่มกิจกรรม', format: 'วันที่และเวลา: YYYY-M-D HH:mm:ss' },
      { key: 'ShowEnd', label: 'จบกิจกรรม', format: 'วันที่และเวลา: YYYY-M-D HH:mm:ss' },
      { key: 'ShowWeekStart', label: 'เริ่มตามวันในสัปดาห์', format: 'วันเริ่ม|วันจบ|HH:mm:ss' },
      { key: 'ShowWeekEnd', label: 'จบตามวันในสัปดาห์', format: 'วันเริ่ม|วันจบ|HH:mm:ss' },
      { key: 'TabShowEnd', label: 'เวลาซ่อนแท็บ', format: 'วันที่และเวลา: YYYY-M-D HH:mm:ss' },
      { key: 'GiveReward', label: 'เวลาสิ้นสุดรับรางวัล', format: 'วันที่และเวลา: YYYY-M-D HH:mm:ss' },
    ],
  },
  {
    id: 'direct-purchase-time',
    rootId: 'DirectPurchaseTime',
    title: 'กิจกรรมซื้อโดยตรง',
    description: 'กำหนดช่วงเวลาขายแพ็กเกจซื้อโดยตรง',
    fields: [
      { key: 'ShowStart', label: 'เริ่มกิจกรรม', format: 'วันที่และเวลา: YYYY-M-D HH:mm:ss' },
      { key: 'ShowEnd', label: 'จบกิจกรรม', format: 'วันที่และเวลา: YYYY-M-D HH:mm:ss' },
      { key: 'ShowWeekStart', label: 'เริ่มตามวันในสัปดาห์', format: 'วันเริ่ม|วันจบ|HH:mm:ss' },
      { key: 'ShowWeekEnd', label: 'จบตามวันในสัปดาห์', format: 'วันเริ่ม|วันจบ|HH:mm:ss' },
      { key: 'TabShowEnd', label: 'เวลาซ่อนแท็บ', format: 'วันที่และเวลา: YYYY-M-D HH:mm:ss' },
      { key: 'GiveReward', label: 'เวลาสิ้นสุดรับรางวัล', format: 'วันที่และเวลา: YYYY-M-D HH:mm:ss' },
    ],
  },
  {
    id: 'activity-info',
    rootId: 'ActivityInfo',
    title: 'กิจกรรมหลักในเกม',
    description: 'วันเปิดเซิร์ฟเวอร์และช่วงเวลาในกิจกรรมหลัก',
    fields: [
      { key: 'OpenStart', label: 'วันเปิดเซิร์ฟเวอร์เริ่ม', format: 'จำนวนวันหลังเปิดเซิร์ฟเวอร์' },
      { key: 'OpenEnd', label: 'วันเปิดเซิร์ฟเวอร์จบ', format: 'จำนวนวันหลังเปิดเซิร์ฟเวอร์' },
      { key: 'StartDate', label: 'วันที่เริ่ม', format: 'วันที่: YYYY-MM-DD HH:mm:ss' },
      { key: 'EndDate', label: 'วันที่จบ', format: 'วันที่: YYYY-MM-DD HH:mm:ss' },
      { key: 'StartTime', label: 'เวลาเริ่มประจำวัน', format: 'HH:mm:ss' },
      { key: 'EndTime', label: 'เวลาจบประจำวัน', format: 'HH:mm:ss' },
    ],
  },
  {
    id: 'special-activity',
    rootId: 'SpecialActivityInfo',
    title: 'กิจกรรมพิเศษ',
    description: 'กำหนดวันเปิดและปิดของกิจกรรมพิเศษ',
    fields: [
      { key: 'OpenStart', label: 'เริ่มกิจกรรม', format: 'วันที่และเวลา: YYYY-MM-DD HH:mm:ss' },
      { key: 'OpenEnd', label: 'จบกิจกรรม', format: 'วันที่และเวลา: YYYY-MM-DD HH:mm:ss' },
    ],
  },
  {
    id: 'special-activity-table',
    rootId: 'SpecialActivityTable',
    title: 'กิจกรรมคืนเงินเติมเซิร์ฟใหม่',
    description: 'ช่วงแสดงกิจกรรมพิเศษจากตารางกิจกรรมของเกม',
    fields: [
      { key: 'ShowStart', label: 'เริ่มกิจกรรม', format: 'วันที่และเวลา: YYYY-MM-DD HH:mm:ss' },
      { key: 'ShowEnd', label: 'จบกิจกรรม', format: 'วันที่และเวลา: YYYY-MM-DD HH:mm:ss' },
    ],
  },
  {
    id: 'overseas-activity',
    rootId: 'OverSeasActivityTable',
    title: 'กิจกรรมเติมเงินผ่านเว็บ',
    description: 'กำหนดช่วงกิจกรรมและเวลาซ่อนแท็บของกิจกรรมภูมิภาค',
    fields: [
      { key: 'ActivityStart', label: 'เริ่มกิจกรรม', format: 'วันที่และเวลา: YYYY-MM-DD HH:mm:ss' },
      { key: 'ActivityEnd', label: 'จบกิจกรรม', format: 'วันที่และเวลา: YYYY-MM-DD HH:mm:ss' },
      { key: 'TabShowEnd', label: 'เวลาซ่อนแท็บ', format: 'วันที่และเวลา: YYYY-MM-DD HH:mm:ss' },
    ],
  },
  {
    id: 'camp-timers',
    rootId: 'CampActivityTimer',
    title: 'กิจกรรมแคมป์',
    description: 'เวลาเริ่มและจบเป็นวันในสัปดาห์:ชั่วโมง:นาที:วินาที (1 คือวันจันทร์, 0/7 คือวันอาทิตย์)',
    fields: [
      { key: 'BeginTime', label: 'เวลาเริ่ม', format: 'วัน:HH:mm:ss' },
      { key: 'EndTime', label: 'เวลาจบ', format: 'วัน:HH:mm:ss' },
    ],
  },
  {
    id: 'integral-boss',
    rootId: 'IntegralBossConfig',
    title: 'บอสแต้มสะสม',
    description: 'เวลารายชั่วโมงใช้รูปแบบ HH:mm คั่นด้วย |; ระยะเวลาก่อนเปิด/เวลาต่อรอบใช้หน่วยนาที',
    fields: [
      { key: 'Opentime', label: 'เวลาเปิดแต่ละรอบ', format: 'HH:mm|HH:mm|... เช่น 00:00|06:00|12:00' },
      { key: 'PreStartTime', label: 'เวลาแจ้งเตือนก่อนเปิด (นาที)', format: 'จำนวนเต็ม 0–1440' },
      { key: 'Lastime', label: 'ระยะเวลาเปิด (นาที)', format: 'จำนวนเต็ม 1–1440' },
    ],
  },
  {
    id: 'theme-boss-time',
    rootId: 'ThemeBossBuffTime',
    title: 'เวลาบัฟบอสธีม',
    description: 'เวลาเริ่มและจบของแต่ละรอบบัฟในแต่ละวัน',
    fields: [
      { key: 'StartTime', label: 'เวลาเริ่ม', format: 'HH:mm' },
      { key: 'EndTime', label: 'เวลาจบ', format: 'HH:mm' },
    ],
  },
  {
    id: 'hunting-unlocks',
    rootId: 'HuntingActivity',
    title: 'ปลดล็อกล่าบอส',
    description: 'กำหนดเวลาปลดล็อกบอสล่า; ไม่มีเวลาปิดใน config นี้',
    fields: [
      { key: 'OpenTime', label: 'เวลาเปิดปลดล็อก', format: 'วันที่และเวลา: YYYY-M-D HH:mm:ss' },
    ],
  },
  {
    id: 'wish-pool',
    rootId: 'WishPoolItem2',
    title: 'ปลดล็อกบ่ออธิษฐาน',
    description: 'เวลาเปิดเฟสที่ 2 นับจากวันและชั่วโมงตามรูปแบบ config',
    fields: [
      { key: 'OpenTime', label: 'เวลาเปิดเฟส', format: 'วัน:ชั่วโมง เช่น 5:20' },
    ],
  },
]

const giftTypeNames: Record<number, string> = {
  1: 'แพ็กเกจทั่วไป',
  2: 'เติมเงินครั้งแรก',
  3: 'แพ็กเกจจำกัดเวลา',
  5: 'บัตรรายเดือน',
  8: 'บัตรวิญญาจารย์',
  9: 'บัตรธีม',
  11: 'บอสธีม',
  12: 'กองทุนเติบโต',
  13: 'แพ็กเกจ 1 หยวน',
  14: 'อาวุธลับ',
  15: 'เติมเงินรายวัน',
  17: 'ขุมทรัพย์เกาะ',
  18: 'โปรโมชันเซิร์ฟใหม่',
  19: 'สวนหญ้าหอม',
  20: 'ซื้อแพ็กเกจโดยตรง',
  21: 'ถามรักเฉียนคุน',
  22: 'พลิกการ์ดนำโชค',
  23: 'ปีนเกาะ',
  24: 'แพ็กเกจปีนเกาะ',
  25: 'แพ็กเกจตรีศูล',
  26: 'กิจกรรมเรือมังกร',
  27: 'กำแพงห่าวเทียน',
  28: 'บอสคาร์นิวัล',
  29: 'เติมเงินคาร์นิวัล',
  30: 'ไมโครมอลล์',
  31: 'ร้านค้าคาร์นิวัล',
  32: 'คำเชิญเชร็ค',
  33: 'รูเล็ตต์',
  34: 'กิจกรรมเรือพาย',
  35: 'เทศกาลไหว้พระจันทร์',
  36: 'เทศกาลดอกไม้ไฟ',
  37: 'บททดสอบเก้าประการ',
  38: 'คืนเพชร',
  39: 'แพ็กเกจเติมเงินใหม่',
  40: 'กล่องเสวียนเทียน',
  41: 'เติมเงินต่อเนื่อง',
  42: 'โคมอธิษฐานเก้ามังกร',
  43: 'พลิกการ์ดชิงสมบัติ',
  44: 'สวนสนุกเชร็ค',
  45: 'ฝึกฝนปีศาจ',
  46: 'พรแห่งแดนเทพ',
  47: 'สำรวจขุมทรัพย์ล่องแพ',
}

function decodeAttribute(value: string) {
  return value
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'")
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&amp;', '&')
}

function parseAttributes(tag: string) {
  const result: Record<string, string> = {}
  for (const match of tag.matchAll(/([\w:.-]+)\s*=\s*(["'])(.*?)\2/g)) {
    result[match[1]] = decodeAttribute(match[3])
  }
  return result
}

function rowName(configId: string, values: Record<string, string>) {
  if (configId === 'hunting-unlocks') {
    const names: Record<string, string> = {
      '深海魔鲸': 'วาฬปีศาจทะเลลึก',
      '泰坦巨猿': 'วานรยักษ์ไททัน',
      '天青牛蟒': 'อสรพิษกระทิงฟ้าคราม',
      '蓝电霸王龙': 'มังกรอัสนีคราม',
      '迦楼罗': 'ครุฑ',
      '火木树妖': 'ภูตพฤกษาเพลิง',
      '蝶翼幻龙': 'มังกรมายาปีกผีเสื้อ',
      '金角神牦': 'จามรีเทพเขาทอง',
      '崩岩晶魔': 'อสูรผลึกศิลา',
      '年兽': 'สัตว์อสูรเหนียน',
      '地灵袋鹿': 'กวางถุงวิญญาณปฐพี',
    }
    return names[values.name] || `บอสล่า ${values.id}`
  }
  if (configId === 'camp-timers') {
    return ({
      1: 'ควบคุมกิจกรรมแคมป์',
      2: 'สร้างแคมป์',
      3: 'สงครามแคมป์ — ช่วงเปิดศึก',
      4: 'สงครามแคมป์ — ช่วงตัดสิน',
    } as Record<string, string>)[values.CampActivityType] || `กิจกรรมแคมป์ ${values.id}`
  }
  if (configId === 'wish-pool') return 'บ่ออธิษฐาน — เฟส 2'
  if (configId === 'integral-boss') return 'บอสแต้มสะสม — ตารางเปิดรายวัน'
  if (configId === 'theme-boss-time') return `เวลาบัฟบอสธีม รอบ ${values.id}`
  if (configId === 'special-activity') {
    const names: Record<string, string> = {
      100: 'ล็อกอินครบ 7 วัน',
      101: 'กิจกรรมเติมเงิน',
      102: 'เติมเงินตามยอดที่กำหนด',
    }
    return `${names[values.SpecialType] || 'กิจกรรมพิเศษ'} (ID ${values.id})`
  }
  if (configId === 'special-activity-table') {
    return `กิจกรรมคืนเงินเติมเซิร์ฟใหม่ — รอบ ${values.SubType || values.id}`
  }
  if (configId === 'overseas-activity') {
    return `กิจกรรมเติมเงินผ่านเว็บ — รอบ ${values.SubType || values.id}`
  }

  const giftType = Number(values.GiftType)
  if (giftType && giftTypeNames[giftType]) {
    const detail = values.SubType ? ` · ชุด ${values.SubType}` : ''
    return `${giftTypeNames[giftType]}${detail} (ID ${values.id})`
  }
  const activityTypeNames: Record<string, string> = {
    101: 'เช็คอินกิจกรรม',
    102: 'เช็คอินเซิร์ฟใหม่',
    103: 'รางวัลพลังรบ',
    104: 'รางวัลเลเวล',
    105: 'รับพลังกายรายวัน',
    107: 'เช็คอินรายวัน',
    110: 'การ์ดรายสัปดาห์',
    111: 'การ์ดสิทธิพิเศษ',
    113: 'กองทุนเติบโต',
    115: 'รางวัลออนไลน์',
  }
  if (activityTypeNames[values.Type]) {
    return `${activityTypeNames[values.Type]} (ID ${values.id})`
  }
  const description = values.name || values.CEHUA || values.beizhu
  return description ? `${description.trim()} (ID ${values.id})` : `กิจกรรม ${values.id}`
}

function isRelevantRow(config: ActivityScheduleConfig, values: Record<string, string>) {
  const hasSchedule = config.fields.some((field) => Object.hasOwn(values, field.key))
  if (!hasSchedule) return false
  if (
    ['recharge-tabs', 'activity-info'].includes(config.id)
    && !['ShowStart', 'ShowEnd', 'OpenStart', 'OpenEnd', 'StartDate', 'EndDate', 'StartTime', 'EndTime']
      .some((key) => Object.hasOwn(values, key))
  ) {
    return false
  }
  return true
}

export function parseActivitySchedule(config: ActivityScheduleConfig, xml: string): ActivityScheduleRow[] {
  const escapedRootId = config.rootId.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  if (!new RegExp(`<idspace\\b[^>]*\\bid=(["'])${escapedRootId}\\1`).test(xml)) {
    throw createError({ statusCode: 502, statusMessage: `รูปแบบ XML ของ ${config.title} จาก Game AdminAPI ไม่ถูกต้อง` })
  }

  const matches = [...xml.matchAll(/<class\b[^>]*\/?>/g)]
  const rows = matches.map((match) => parseAttributes(match[0]))
    .filter((values) => isRelevantRow(config, values))
  const ids = rows.map((row) => row.id)
  if (ids.some((id) => !id || !/^\d+$/.test(id)) || new Set(ids).size !== ids.length) {
    throw createError({ statusCode: 502, statusMessage: `ID ใน ${config.title} ไม่ถูกต้องหรือซ้ำกัน` })
  }

  return rows.map((values) => ({
    id: Number(values.id),
    name: rowName(config.id, values),
    configId: config.id,
    configTitle: config.title,
    imageUrl: `/activity-banners/${activityBannerId(config.id, values)}.webp`,
    canOpenImmediately: config.id === 'recharge-tabs'
      && Number(values.GiftType) === 9
      && Object.hasOwn(values, 'ShowStart')
      && Object.hasOwn(values, 'ShowEnd'),
    fields: Object.fromEntries(config.fields
      .filter((field) => Object.hasOwn(values, field.key))
      .map((field) => [field.key, values[field.key]])),
  }))
}

export async function fetchActivitySchedules() {
  return (await Promise.all(activityScheduleConfigs.map(async (config) => {
    const response = await fetchGameAdminApi(`/api/activities/config/${config.id}`)
    return parseActivitySchedule(config, await response.text())
  }))).flat()
}

export async function saveActivitySchedule(configId: string, rowId: number, fields: Record<string, string>) {
  const config = activityScheduleConfigs.find((item) => item.id === configId)
  if (!config) {
    throw createError({ statusCode: 400, statusMessage: 'ไม่พบประเภทกิจกรรมที่ต้องการแก้ไข' })
  }
  const allowedFields = new Set(config.fields.map((field) => field.key))
  const keys = Object.keys(fields)
  if (!Number.isSafeInteger(rowId) || rowId < 1 || keys.length === 0 || keys.some((key) => !allowedFields.has(key))) {
    throw createError({ statusCode: 400, statusMessage: 'ข้อมูลตารางเวลากิจกรรมไม่ถูกต้อง' })
  }
  for (const [key, value] of Object.entries(fields)) {
    if (typeof value !== 'string' || value.length > 128 || /[\u0000-\u001f]/.test(value)) {
      throw createError({ statusCode: 400, statusMessage: `ค่า ${key} ไม่ถูกต้อง` })
    }
    if (value === '' && !isOptionalScheduleField(configId, key)) {
      throw createError({ statusCode: 400, statusMessage: `ไม่สามารถเว้นค่า ${key} ว่างได้` })
    }
    if (value !== '' && !isValidScheduleValue(configId, key, value)) {
      throw createError({ statusCode: 400, statusMessage: `รูปแบบค่า ${key} ไม่ถูกต้อง` })
    }
  }

  const response = await fetchGameAdminApi(`/api/activities/config/${configId}/${rowId}`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(fields),
  })
  const result = await response.json() as { code?: unknown; message?: unknown }
  if (result.code !== 1) {
    throw createError({
      statusCode: 502,
      statusMessage: typeof result.message === 'string' ? result.message : 'Game AdminAPI บันทึกตารางเวลาไม่สำเร็จ',
    })
  }
}

function isValidScheduleValue(configId: string, key: string, value: string) {
  if (configId === 'integral-boss' && key === 'Opentime') {
    const times = value.split('|')
    return times.length > 0 && times.every((time) => {
      const match = /^(2[0-4]|[01]?\d):([0-5]\d)$/.exec(time)
      return Boolean(match && (Number(match[1]) < 24 || Number(match[2]) === 0))
    })
  }
  if (configId === 'integral-boss' && (key === 'PreStartTime' || key === 'Lastime')) {
    const minutes = Number(value)
    return /^\d+$/.test(value) && minutes >= (key === 'Lastime' ? 1 : 0) && minutes <= 1440
  }
  if (configId === 'theme-boss-time' && (key === 'StartTime' || key === 'EndTime')) {
    const match = /^([01]?\d|2[0-4]):([0-5]\d)$/.exec(value)
    return Boolean(match && (Number(match[1]) < 24 || Number(match[2]) === 0))
  }
  if (key === 'ShowWeekStart' || key === 'ShowWeekEnd') {
    const match = /^([1-7])\|([1-7])\|(\d{1,2}):(\d{2}):(\d{2})$/.exec(value)
    return Boolean(match && Number(match[3]) < 24 && Number(match[4]) < 60 && Number(match[5]) < 60)
  }
  if (configId === 'camp-timers' && (key === 'BeginTime' || key === 'EndTime')) {
    const match = /^([0-7]):(\d{1,2}):(\d{2}):(\d{2})$/.exec(value)
    return Boolean(match && Number(match[2]) < 24 && Number(match[3]) < 60 && Number(match[4]) < 60)
  }
  if (configId === 'wish-pool') {
    return /^\d+:\d{1,2}$/.test(value) && Number(value.split(':')[1]) < 24
  }
  if (key === 'OpenStart' || key === 'OpenEnd') {
    if (configId === 'activity-info' || configId === 'recharge-tabs') return /^-?\d+$/.test(value)
    return isValidDateTime(value)
  }
  if (key === 'StartTime' || key === 'EndTime') {
    const match = /^(\d{1,2}):(\d{2}):(\d{2})$/.exec(value)
    return Boolean(match && Number(match[1]) < 24 && Number(match[2]) < 60 && Number(match[3]) < 60)
  }
  if (key === 'ShowStart' || key === 'ShowEnd' || key === 'TabShowEnd' || key === 'GiveReward'
    || key === 'ActivityStart' || key === 'ActivityEnd'
    || key === 'StartDate' || key === 'EndDate' || key === 'OpenTime') {
    return isValidDateTime(value)
  }
  return false
}

function isOptionalScheduleField(configId: string, key: string) {
  if (['recharge-tabs', 'recharge-time', 'direct-purchase-time'].includes(configId)) {
    return ['ShowStart', 'ShowEnd', 'ShowWeekStart', 'ShowWeekEnd', 'TabShowEnd', 'GiveReward'].includes(key)
  }
  return configId === 'overseas-activity' && key === 'TabShowEnd'
}

function isValidDateTime(value: string) {
  const match = /^(\d{4})-(\d{1,2})-(\d{1,2})[ T](\d{1,2}):(\d{2}):(\d{2})$/.exec(value)
  if (!match) return false
  const [, yearText, monthText, dayText, hourText, minuteText, secondText] = match
  const [year, month, day, hour, minute, second] = [yearText, monthText, dayText, hourText, minuteText, secondText].map(Number)
  const date = new Date(year, month - 1, day, hour, minute, second)
  return date.getFullYear() === year
    && date.getMonth() === month - 1
    && date.getDate() === day
    && date.getHours() === hour
    && date.getMinutes() === minute
    && date.getSeconds() === second
}
