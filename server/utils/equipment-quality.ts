const MAX_GRADES_BY_EQUIPMENT_QUALITY = [1, 3, 6, 10, 14, 19, 24, 29, 34]

export function getEquipmentQuality(itemId: string) {
  const match = /^33\d(\d{2})\d{2}$/.exec(itemId)
  if (!match) return undefined

  const grade = Number(match[1])
  const qualityIndex = MAX_GRADES_BY_EQUIPMENT_QUALITY.findIndex((maxGrade) => grade <= maxGrade)
  return qualityIndex === -1 ? undefined : qualityIndex + 1
}
