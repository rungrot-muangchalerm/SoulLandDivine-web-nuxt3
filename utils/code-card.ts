export interface CardDefinition {
  name: string
  heroId: string
  talent: 'strength' | 'body' | 'agility' | 'skill'
  talentValue: number
  boneAffixes: string[]
  equipment: Array<{ id: string; stars: number; level: number }>
  rings: Array<{ id: string; year: number; elementId?: string }>
}
// Job values are sourced from Server/Hero/HeroCard.xml and Server/Equipment/Equipment.xml.
// Unknown or unverified jobs are never treated as universally compatible.
export function matchesHeroEquipmentJob(heroJob: number | null | undefined, equipmentJob: number | null | undefined): boolean {
  return Number.isInteger(heroJob) && Number.isInteger(equipmentJob) && heroJob === equipmentJob
}
// Card definitions contain only JSON fields. JSON serialization unwraps
// nested Vue reactive proxies, which structuredClone(toRaw(...)) cannot do.
export function cloneCardDefinition(value: CardDefinition): CardDefinition {
  return JSON.parse(JSON.stringify(value)) as CardDefinition
}

export const CARD_TALENTS = { strength: 'พลัง', body: 'ร่างกาย', agility: 'ว่องไว', skill: 'ชำนาญ' }
function integer(value: unknown, min: number, max: number, label: string) {
  if (typeof value !== 'number' || !Number.isSafeInteger(value) || value < min || value > max) throw new Error(`${label}: ${min}–${max}`)
  return value
}
function itemId(value: unknown, optional = false) {
  if (optional && value === '') return ''
  if (typeof value !== 'string' || !/^[1-9]\d{0,8}$/.test(value)) throw new Error('Invalid item ID')
  return value
}
export function validateCard(input: unknown): CardDefinition {
  if (!input || typeof input !== 'object') throw new Error('Invalid card')
  const data = input as CardDefinition
  if (typeof data.name !== 'string' || !data.name.trim() || data.name.length > 100) throw new Error('Card name: 1–100 characters')
  if (!Object.hasOwn(CARD_TALENTS, data.talent)) throw new Error('Invalid talent')
  if (!Array.isArray(data.equipment) || data.equipment.length !== 5) throw new Error('ต้องมีช่องอุปกรณ์ 5 ช่อง')
  if (!Array.isArray(data.rings) || data.rings.length !== 10) throw new Error('ต้องมีวงแหวน 10 วง')
  if (!Array.isArray(data.boneAffixes) || data.boneAffixes.length > 6 || data.boneAffixes.some(x => typeof x !== 'string' || x.length > 200 || /[\x00-\x1f]/.test(x))) throw new Error('Invalid bone affix (maximum 6 lines, 200 characters each)')
  return {
    name: data.name.trim(), heroId: itemId(data.heroId, true), talent: data.talent,
    talentValue: integer(data.talentValue, 0, 35, 'talent 35'), boneAffixes: data.boneAffixes.filter(Boolean),
    equipment: data.equipment.map(x => ({ id: itemId(x.id, true), stars: integer(x.stars, 0, 5, 'stars'), level: integer(x.level, 0, 100, 'level') })),
    rings: data.rings.map(x => ({
      id: itemId(x.id, true),
      year: integer(x.year, 1, 1000000, 'ring year'),
      ...(x.elementId ? { elementId: /^[1-9]\d{0,3}$/.test(x.elementId) ? x.elementId : (() => { throw new Error('Invalid ring element') })() } : {}),
    })),
  }
}
// Equipment XML defines the star count per item ID. Keep the legacy
// snapshot field for backwards compatibility, but never trust manual stars.
export function normalizeCardEquipmentStars(card: CardDefinition, items: ReadonlyArray<{ id: string; star: number }>): CardDefinition {
  const stars = new Map(items.map(item => [item.id, item.star]))
  return {
    ...card,
    equipment: card.equipment.map((slot, index) => ({
      ...slot,
      stars: index === 0 ? 0 : (stars.get(slot.id) ?? 0),
    })),
  }
}

export function buildCardRewards(card: CardDefinition): string {
  if (!card.heroId) throw new Error('กรุณาเลือกตัวละคร / hero')
  if (card.equipment.some(x => !x.id)) throw new Error('กรุณาเลือกอุปกรณ์ครบ 5 ช่อง / equipment')
  if (card.rings.some(x => !x.id)) throw new Error('กรุณาเลือกวงแหวนครบ 10 วง / rings')
  return [`${card.heroId}:7:1`, ...card.equipment.map((x, i) => `${x.id}:${i === 0 ? 13 : 5}:1`), ...card.rings.map(x => `${x.id}:3:1@${x.year}`)].join('|')
}
export function normalizeCardCode(value: string) {
  const normalized = value.toUpperCase().replaceAll('-', '').trim()
  if (!/^SLC[0-9A-F]{24}$/.test(normalized)) throw new Error('Invalid card code')
  return normalized
}
