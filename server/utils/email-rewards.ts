export const MAX_EMAIL_REWARD_BATCH_LENGTH = 255

export function getEmailRewardBatches(rewards: string[]) {
  const batches: string[][] = []
  let batch: string[] = []
  let batchLength = 0

  for (const reward of rewards) {
    if (reward.length > MAX_EMAIL_REWARD_BATCH_LENGTH) {
      throw new RangeError('Email reward exceeds the maximum batch length')
    }

    const nextLength = batchLength + (batch.length ? 1 : 0) + reward.length
    if (nextLength > MAX_EMAIL_REWARD_BATCH_LENGTH) {
      batches.push(batch)
      batch = [reward]
      batchLength = reward.length
    } else {
      batch.push(reward)
      batchLength = nextLength
    }
  }

  if (batch.length || batches.length === 0) {
    batches.push(batch)
  }
  return batches
}
