const scheduleControllerByPoolId: Record<number, number> = {
  4: 24,
}

const scheduleFollowersByControllerId: Record<number, number[]> = {
  24: [4],
}

export function getGachaScheduleControllerId(poolId: number) {
  return scheduleControllerByPoolId[poolId] ?? poolId
}

export function getGachaScheduleFollowers(poolId: number) {
  return scheduleFollowersByControllerId[poolId] ?? []
}

export function isGachaScheduleFollower(poolId: number) {
  return getGachaScheduleControllerId(poolId) !== poolId
}
