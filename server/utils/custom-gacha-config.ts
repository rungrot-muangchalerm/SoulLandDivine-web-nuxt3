export interface CustomGachaConfig {
  singlePrice: number
  continuousPrice: number
  singleItem: number
  continuousItem: number
  blessingMax: number
  ssrWeight: number
  srWeight: number
  rWeight: number
  nWeight: number
}

export const CUSTOM_GACHA_TYPE = 10000
const fields = { singlePrice: 'Single', continuousPrice: 'Continuous', singleItem: 'SingleItem',
  continuousItem: 'ContinuousItem', blessingMax: 'BlessingMax' } as const

function row(xml: string) {
  if (!/<idspace\b[^>]*\bid=["']DrawQualityRatio["']/.test(xml)) {
    throw createError({ statusCode: 502, statusMessage: 'ข้อมูลกติกาตู้กาชาไม่ถูกต้อง' })
  }
  const matches = [...xml.matchAll(/<class\b[^>]*\bid="10000"[^>]*\/>/g)]
  if (matches.length !== 1) throw createError({ statusCode: 409, statusMessage: 'ยังไม่ได้แยกกติกาตู้ Type 10000 ฝั่ง server' })
  return matches[0]
}
function attributes(tag: string) {
  return Object.fromEntries([...tag.matchAll(/(\w+)="([^"]*)"/g)].map((m) => [m[1], m[2]]))
}
function set(tag: string, field: string, value: string | number) {
  const pattern = new RegExp(`\\b${field}="[^"]*"`)
  const attribute = `${field}="${value}"`
  return pattern.test(tag) ? tag.replace(pattern, attribute) : tag.replace('/>', ` ${attribute}/>`)
}
export function getCustomGachaConfig(xml: string): CustomGachaConfig {
  const values = attributes(row(xml)[0])
  const weights = Object.fromEntries((values.CostRatio || '').split('|').map((entry) => entry.split(':')))
  return {
    singlePrice: Number(values.Single), continuousPrice: Number(values.Continuous),
    singleItem: Number(values.SingleItem), continuousItem: Number(values.ContinuousItem),
    blessingMax: Number(values.BlessingMax), ssrWeight: Number(weights['2'] || 0),
    srWeight: Number(weights['3'] || 0), rWeight: Number(weights['4'] || 0), nWeight: Number(weights['5'] || 0),
  }
}
export function updateCustomGachaConfig(xml: string, input: unknown) {
  if (!input || typeof input !== 'object') throw createError({ statusCode: 400, statusMessage: 'กรุณาระบุกติกาตู้' })
  const config = input as Record<string, unknown>
  const limits: Record<keyof CustomGachaConfig, [number, number]> = {
    singlePrice: [1, 1000000], continuousPrice: [1, 1000000], singleItem: [0, 100000000],
    continuousItem: [0, 100000000], blessingMax: [0, 10000],
    ssrWeight: [0, 1000000], srWeight: [0, 1000000], rWeight: [0, 1000000], nWeight: [0, 1000000],
  }
  for (const [key, [min, max]] of Object.entries(limits)) {
    const value = config[key]
    if (typeof value !== 'number' || !Number.isSafeInteger(value) || value < min || value > max) {
      throw createError({ statusCode: 400, statusMessage: `ค่า ${key} ต้องเป็นจำนวนเต็มระหว่าง ${min} ถึง ${max}` })
    }
  }
  const value = config as unknown as CustomGachaConfig
  if (value.ssrWeight + value.srWeight + value.rWeight + value.nWeight <= 0) {
    throw createError({ statusCode: 400, statusMessage: 'น้ำหนักระดับคุณภาพต้องมากกว่า 0 อย่างน้อยหนึ่งระดับ' })
  }
  const knownTickets = new Set([0])
  for (const match of xml.matchAll(/\b(?:SingleItem|ContinuousItem)="(\d+)"/g)) knownTickets.add(Number(match[1]))
  if (!knownTickets.has(value.singleItem) || !knownTickets.has(value.continuousItem)) {
    throw createError({ statusCode: 400, statusMessage: 'เลือก ID ตั๋วที่มีในกติกาเกมอยู่แล้ว หรือใช้ 0 เพื่อปิดการใช้ตั๋ว' })
  }
  const match = row(xml)
  let tag = match[0]
  for (const [key, field] of Object.entries(fields)) tag = set(tag, field, value[key as keyof CustomGachaConfig])
  // Equal prices prevent old discount windows from overriding the custom settings.
  tag = set(tag, 'SingleDiscount', value.singlePrice)
  tag = set(tag, 'ContinuousDiscount', value.continuousPrice)
  tag = set(tag, 'CostType', 503)
  tag = set(tag, 'ContinuousNum', 7)
  const weights = `2:${value.ssrWeight}|3:${value.srWeight}|4:${value.rWeight}|5:${value.nWeight}`
  for (const field of ['CostRatio', 'ItemRatio', 'FreeRatio']) tag = set(tag, field, weights)
  const result = xml.slice(0, match.index) + tag + xml.slice(match.index! + match[0].length)
  return { xml: result, config: getCustomGachaConfig(result) }
}
