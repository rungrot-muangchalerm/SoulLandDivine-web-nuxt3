import assert from 'node:assert/strict'
import test from 'node:test'
import { getEquipmentQuality } from '../server/utils/equipment-quality.ts'

test('maps equipment grades to their configured quality color', () => {
  const equipment = [
    ['3330111', 1],
    ['3330211', 2],
    ['3330311', 2],
    ['3330411', 3],
    ['3330711', 4],
    ['3331111', 5],
    ['3341511', 6],
    ['3352011', 7],
    ['3362511', 8],
    ['3363011', 9],
  ]

  for (const [id, quality] of equipment) {
    assert.equal(getEquipmentQuality(id), quality, `unexpected quality for equipment ${id}`)
  }
})

test('returns no quality for IDs outside the equipment ID format', () => {
  assert.equal(getEquipmentQuality('12345'), undefined)
  assert.equal(getEquipmentQuality('3333511'), undefined)
})
