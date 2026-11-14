export interface ActivityScheduleBatchRow {
  id: number
  configId: string
  durationDays?: number
}

export interface ActivityScheduleBatchUpdate {
  id: number
  fields?: Record<string, string>
  openForConfiguredDuration?: boolean
}

type ActivityOverrideFields = (
  configId: string,
  active: boolean,
  now: Date,
) => Record<string, string>

export function buildActivityScheduleBatchUpdates(
  rows: readonly ActivityScheduleBatchRow[],
  active: boolean,
  now: Date,
  getOverrideFields: ActivityOverrideFields,
): ActivityScheduleBatchUpdate[] {
  return rows.map((row) => {
    if (
      active
      && row.configId === 'recharge-tabs'
      && Number.isSafeInteger(row.durationDays)
      && (row.durationDays ?? 0) > 0
    ) {
      return { id: row.id, openForConfiguredDuration: true }
    }

    return {
      id: row.id,
      fields: getOverrideFields(row.configId, active, now),
    }
  })
}
