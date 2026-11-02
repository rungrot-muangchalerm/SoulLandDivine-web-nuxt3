export interface GachaCharacterRate {
  id: number
  name: string
  quality: number
  ratio: number
  openWeek: number
  openDay: number
}

export const MAX_CHARACTER_RATIO = 1_000_000

function classTags(xml: string) {
  if (!/<idspace\b[^>]*\bid=(["'])DrawHeroRatio\1/.test(xml)) {
    throw createError({ statusCode: 502, statusMessage: 'รูปแบบ DrawHeroRatio.xml จาก Game AdminAPI ไม่ถูกต้อง' })
  }

  const tags = [...xml.matchAll(/<class\b[^>]*\/?>/g)]
  if (!tags.length) {
    throw createError({ statusCode: 502, statusMessage: 'ไม่พบข้อมูลเรทตัวละครใน DrawHeroRatio.xml' })
  }

  const ids = tags.map((match) => attributes(match[0]).id)
  if (ids.some((id) => !id) || new Set(ids).size !== ids.length) {
    throw createError({ statusCode: 502, statusMessage: 'ข้อมูล ID ตัวละครใน DrawHeroRatio.xml ไม่ถูกต้องหรือซ้ำกัน' })
  }

  return tags
}

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

function parseInteger(value: string | undefined, field: string, heroId: string) {
  if (!value || !/^\d+$/.test(value)) {
    throw createError({
      statusCode: 502,
      statusMessage: `ค่า ${field} ของตัวละคร ID ${heroId} ใน DrawHeroRatio.xml ไม่ถูกต้อง`,
    })
  }
  return Number(value)
}

function validateDrawType(drawType: number) {
  if (!Number.isSafeInteger(drawType) || drawType < 1) {
    throw createError({ statusCode: 400, statusMessage: 'ประเภทตู้กาชาไม่ถูกต้อง' })
  }
}

export function getGachaCharacterRates(xml: string, drawType: number): GachaCharacterRate[] {
  validateDrawType(drawType)
  const ratioKey = `Ratio${drawType}`
  const qualityKey = `Quality${drawType}`

  const characters = classTags(xml).flatMap((match) => {
    const values = attributes(match[0])
    if (!(ratioKey in values) || !(qualityKey in values)) return []

    const id = parseInteger(values.id, 'ID', values.id || '?')
    return [{
      id,
      name: values.CEHUA || `ตัวละคร ${id}`,
      quality: parseInteger(values[qualityKey], qualityKey, String(id)),
      ratio: parseInteger(values[ratioKey], ratioKey, String(id)),
      openWeek: values.OpenWeek ? parseInteger(values.OpenWeek, 'OpenWeek', String(id)) : 0,
      openDay: values.OpenDay ? parseInteger(values.OpenDay, 'OpenDay', String(id)) : 0,
    }]
  })

  if (!characters.length) {
    throw createError({ statusCode: 502, statusMessage: `ไม่พบเรทตัวละครสำหรับตู้ประเภท ${drawType}` })
  }
  return characters
}

export function updateGachaCharacterRate(xml: string, drawType: number, heroId: number, ratio: number) {
  validateDrawType(drawType)
  if (!Number.isSafeInteger(heroId) || heroId < 1) {
    throw createError({ statusCode: 400, statusMessage: 'ID ตัวละครไม่ถูกต้อง' })
  }
  if (!Number.isSafeInteger(ratio) || ratio < 0 || ratio > MAX_CHARACTER_RATIO) {
    throw createError({ statusCode: 400, statusMessage: `เรทตัวละครต้องเป็นจำนวนเต็มระหว่าง 0 ถึง ${MAX_CHARACTER_RATIO}` })
  }

  const characters = getGachaCharacterRates(xml, drawType)
  const character = characters.find((item) => item.id === heroId)
  if (!character) {
    throw createError({ statusCode: 404, statusMessage: `ไม่พบข้อมูลเรทของตัวละคร ID ${heroId} ในตู้ประเภท ${drawType}` })
  }

  let updated = false
  const updatedXml = xml.replace(/<class\b[^>]*\/?>/g, (tag) => {
    if (attributes(tag).id !== String(heroId)) return tag

    const ratioAttribute = new RegExp(`(\\bRatio${drawType}\\s*=\\s*)(["'])\\d+\\2`)
    if (!ratioAttribute.test(tag)) {
      throw createError({ statusCode: 502, statusMessage: `ไม่พบค่า Ratio${drawType} ของตัวละคร ID ${heroId}` })
    }
    updated = true
    return tag.replace(ratioAttribute, (_match, prefix: string, quote: string) => `${prefix}${quote}${ratio}${quote}`)
  })

  if (!updated) {
    throw createError({ statusCode: 502, statusMessage: `ไม่สามารถอัปเดตเรทตัวละคร ID ${heroId} ได้` })
  }

  return {
    xml: updatedXml,
    previousRatio: character.ratio,
    characters: getGachaCharacterRates(updatedXml, drawType),
  }
}
