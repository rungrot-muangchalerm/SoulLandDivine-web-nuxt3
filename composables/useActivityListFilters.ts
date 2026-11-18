export type ActivityKind = 'all' | 'permanent' | 'scheduled'

export interface ActivityFilterConfig {
  id: string
  title: string
  description: string
  fields: Array<{ key: string; label: string; format: string }>
}

// Shared per-request Nuxt state keeps filters in the header synchronized
// with the Activities list without putting controls on the list twice.
export function useActivityListFilters() {
  const activityKind = useState<ActivityKind>('activity-list-kind', () => 'all')
  const selectedConfigId = useState<string>('activity-list-config-id', () => 'all')
  const configs = useState<ActivityFilterConfig[]>('activity-list-configs', () => [])
  const loading = useState<boolean>('activity-list-loading', () => true)

  return { activityKind, selectedConfigId, configs, loading }
}
