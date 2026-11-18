/**
 * Return activity rows sorted by numeric ID, without changing the API response.
 * @template {{id: number}} T
 * @param {readonly T[]} activities
 * @returns {T[]}
 */
export function sortActivitiesById(activities) {
  return [...activities].sort((a, b) => a.id - b.id)
}