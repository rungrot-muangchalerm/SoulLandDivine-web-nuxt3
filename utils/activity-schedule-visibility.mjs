const hiddenActivityManagementRows = new Set([
  'recharge-tabs:9',
])

/**
 * The WeChat Official Account row only copies an external account name.
 * It has no in-game reward or schedule-management action, so keep it out
 * of the Activities management page without changing the game XML.
 *
 * @param {{ configId: string, id: number }} activity
 */
export function isVisibleInActivityManagement(activity) {
  return !hiddenActivityManagementRows.has(activity.configId + ':' + activity.id)
}
