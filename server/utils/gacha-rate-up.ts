import { fetchGameAdminApi } from './game-admin-api'

export interface GachaPool {
  id: number
  type: string
  name: string
  beginTime: string
  endTime: string
  active: boolean
  imageUrl?: string
}

const gachaPoolImages: Record<number, string> = {
  3: '/gacha/3.webp',
  4: '/gacha/4.webp',
  5: '/gacha/5.webp',
  7: '/gacha/7.webp',
  11: '/gacha/11.webp',
  12: '/gacha/12.webp',
  17: '/gacha/17.webp',
  19: '/gacha/19.webp',
  23: '/gacha/23.webp',
  24: '/gacha/24.webp',
  25: '/gacha/25.webp',
  26: '/gacha/26.webp',
  27: '/gacha/27.webp',
  28: '/gacha/28.webp',
  40: '/gacha/40.webp',
  41: '/gacha/41.webp',
  42: '/gacha/42.webp',
  44: '/gacha/44.webp',
  98: '/gacha/98.webp',
  99: '/gacha/99.webp',
}

const gachaPoolNames: Record<number, string> = {
  1: 'รับสมัครหายาก',
  2: 'รับสมัครเพื่อน',
  3: 'ฮ่าวเทียนจุติ',
  4: 'รับสมัครธีม — อาหยิน',
  5: 'รับสมัครธีม — เชียนเริ่นเสวี่ย',
  6: 'รับสมัครธีม — แม่มดสมุทร',
  7: 'รับสมัครธีม — ถังเลี่ย',
  8: 'รับสมัครธีม — มังกรสมุทร',
  9: 'รับสมัครธีม — ยูเรเซีย',
  10: 'รับสมัครธีม — หยางอี้อวิ๋น',
  11: 'รับสมัครธีม — ปีศาจทะเล',
  12: 'รับสมัครธีม — ไป๋เฉินเซียง',
  13: 'รับสมัครธีมหลัก — อวี้หยวนเจิ้น',
  15: 'รับสมัครธีมหลัก — ถังเซี่ยว',
  17: 'รับสมัครธีมหลัก — ทะเลมายา',
  18: 'รับสมัครธีมหลัก — ชื่อเซวี่ย',
  19: 'รับสมัครธีมหลัก — หนิง',
  20: 'รับสมัครธีมหลัก — หม่าหงจวิ้น',
  21: 'รับสมัครธีมหลัก — เสวี่ยเปิง',
  23: 'รับสมัครธีมหลัก — อวี้เสี่ยวกัง',
  24: 'รับสมัครธีมหลัก — อาหยิน',
  25: 'รับสมัครธีมหลัก — มุกสีม่วง',
  26: 'รับสมัครธีมหลัก — เฟิงเสี้ยวเทียน',
  27: 'รับสมัครธีมหลัก — นิ่งหรงหรง',
  28: 'รับสมัครธีมหลัก — กู่หรง',
  29: 'รับสมัครธีมหลัก — ไต้เหวยซือ',
  40: 'รับสมัครเทพ — โพไซซี',
  41: 'รับสมัครเทพ — ถังซาน',
  42: 'รับสมัครเทพ — อาหยิน',
  43: 'รับสมัครเทพ — ไต้มู่ไป๋',
  44: 'รับสมัครเทพ — เชียนเริ่นเสวี่ย',
  98: 'รับสมัครธีม — เสียวอู่',
  99: 'รับสมัครธีม — โหลวเกา',
  103: 'พิษสิ้นชีพสงัด',
  10000: 'อัตรา UP',
}

const permanentPoolIds = new Set([1, 2])

function attributes(tag: string) {
  const result: Record<string, string> = {}
  for (const match of tag.matchAll(/([\w:.-]+)\s*=\s*(["'])(.*?)\2/g)) {
    result[match[1]] = match[3]
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&')
  }
  return result
}

export function parseLocalDateTime(value: string) {
  const match = /^(\d{4})-(\d{1,2})-(\d{1,2})[ T](\d{1,2}):(\d{1,2}):(\d{1,2})$/.exec(value)
  if (!match) return null

  const [, yearText, monthText, dayText, hourText, minuteText, secondText] = match
  const parts = [yearText, monthText, dayText, hourText, minuteText, secondText].map(Number)
  const [year, month, day, hour, minute, second] = parts
  const date = new Date(year, month - 1, day, hour, minute, second)
  if (
    date.getFullYear() !== year
    || date.getMonth() !== month - 1
    || date.getDate() !== day
    || date.getHours() !== hour
    || date.getMinutes() !== minute
    || date.getSeconds() !== second
  ) {
    return null
  }
  return date
}

export function formatLocalDateTime(date: Date) {
  const pad = (value: number) => String(value).padStart(2, '0')
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
}

function classTags(xml: string) {
  if (!/<idspace\b[^>]*\bid=(["'])DrawTime\1/.test(xml)) {
    throw createError({ statusCode: 502, statusMessage: 'รูปแบบ DrawTime.xml จาก Game AdminAPI ไม่ถูกต้อง' })
  }

  const tags = [...xml.matchAll(/<class\b[^>]*\/?>/g)]
  if (!tags.length) {
    throw createError({ statusCode: 502, statusMessage: 'ไม่พบรายการตู้กาชาใน DrawTime.xml' })
  }
  const ids = tags.map((match) => attributes(match[0]).id)
  if (ids.some((id) => !id) || new Set(ids).size !== ids.length) {
    throw createError({ statusCode: 502, statusMessage: 'ข้อมูล ID ตู้กาชาใน DrawTime.xml ไม่ถูกต้องหรือซ้ำกัน' })
  }
  return tags
}

function getPoolSchedule(match: RegExpMatchArray, now: Date): GachaPool {
  const values = attributes(match[0])
  const beginTime = values.BeginTime || ''
  const endTime = values.EndTime || ''
  const begin = parseLocalDateTime(beginTime)
  const end = parseLocalDateTime(endTime)
  return {
    id: Number(values.id),
    type: values.Type || '',
    name: gachaPoolNames[Number(values.id)] || `ตู้กาชา ${values.id}`,
    beginTime,
    endTime,
    active: Boolean(begin && end && now >= begin && now <= end),
    imageUrl: gachaPoolImages[Number(values.id)],
  }
}

export function getGachaPools(xml: string, now = new Date()) {
  return classTags(xml)
    .map((match) => getPoolSchedule(match, now))
    .filter((pool) => !permanentPoolIds.has(pool.id))
}

export function getGachaPool(xml: string, poolId: number, now = new Date()) {
  if (permanentPoolIds.has(poolId)) {
    throw createError({ statusCode: 400, statusMessage: 'ตู้มาตรฐานไม่สามารถจัดการสถานะได้' })
  }
  const matches = classTags(xml).filter((match) => Number(attributes(match[0]).id) === poolId)
  if (matches.length !== 1) {
    throw createError({ statusCode: 400, statusMessage: 'ไม่พบตู้กาชาที่เลือก' })
  }
  return getPoolSchedule(matches[0], now)
}

function setAttribute(tag: string, name: string, value: string) {
  const escapedValue = value
    .replaceAll('&', '&amp;')
    .replaceAll('"', '&quot;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
  const attribute = new RegExp(`\\b${name}\\s*=\\s*(["'])(.*?)\\1`)
  if (attribute.test(tag)) {
    return tag.replace(attribute, (_match, quote: string) => `${name}=${quote}${escapedValue}${quote}`)
  }
  return tag.replace(/\/?>$/, (ending) => ` ${name}="${escapedValue}"${ending}`)
}

export function updateGachaPoolSchedule(xml: string, poolId: number, beginTime: string, endTime: string) {
  const matches = classTags(xml).filter((match) => Number(attributes(match[0]).id) === poolId)
  if (matches.length !== 1) {
    throw createError({ statusCode: 400, statusMessage: 'ไม่พบตู้กาชาที่เลือก' })
  }
  const match = matches[0]
  const updatedTag = setAttribute(setAttribute(match[0], 'BeginTime', beginTime), 'EndTime', endTime)
  return `${xml.slice(0, match.index)}${updatedTag}${xml.slice(match.index! + match[0].length)}`
}

export async function fetchDrawTimeXml() {
  const response = await fetchGameAdminApi('/api/gacha/time')
  return await response.text()
}
