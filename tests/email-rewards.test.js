import assert from 'node:assert/strict'
import test from 'node:test'
import { getEmailRewardBatches } from '../server/utils/email-rewards.ts'

test('splits reward strings into batches no longer than 255 characters', () => {
  const rewards = Array.from({ length: 5000 }, (_, index) => `${index + 1}:1:1`)
  const batches = getEmailRewardBatches(rewards)

  assert.ok(batches.length > 1)
  assert.deepEqual(batches.flat(), rewards)
  for (const batch of batches) {
    assert.ok(batch.join('|').length <= 255)
  }
})

test('keeps an empty reward list as one empty batch', () => {
  assert.deepEqual(getEmailRewardBatches([]), [[]])
})

test('rejects a reward that cannot fit in a packet batch', () => {
  assert.throws(
    () => getEmailRewardBatches(['x'.repeat(256)]),
    /maximum batch length/,
  )
})
