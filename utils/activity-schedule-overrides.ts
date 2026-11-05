const permanentEnd = '9999-12-31 23:59:59'
const closedCampTime = '0:00:00:00'

export function getActivityOverrideFields(
  configId: string,
  active: boolean,
  now: Date,
): Record<string, string> {
  const nowText = formatDateTime(now)
  switch (configId) {
    case 'recharge-tabs':
    case 'recharge-time':
    case 'direct-purchase-time':
      return {
        ShowStart: active ? nowText : permanentEnd,
        ShowEnd: permanentEnd,
        ShowWeekStart: '',
        ShowWeekEnd: '',
        TabShowEnd: active ? permanentEnd : nowText,
        GiveReward: active ? permanentEnd : nowText,
        ...(configId === 'recharge-tabs' ? { OpenStart: '-1', OpenEnd: '0' } : {}),
      }
    case 'activity-info':
      return {
        OpenStart: '-1',
        OpenEnd: '0',
        StartDate: active ? nowText : permanentEnd,
        EndDate: permanentEnd,
        StartTime: '00:00:00',
        EndTime: '24:00:00',
      }
    case 'special-activity':
      return { OpenStart: active ? nowText : permanentEnd, OpenEnd: permanentEnd }
    case 'special-activity-table':
      return { ShowStart: active ? nowText : permanentEnd, ShowEnd: permanentEnd }
    case 'overseas-activity':
      return {
        ActivityStart: active ? nowText : permanentEnd,
        ActivityEnd: permanentEnd,
        TabShowEnd: permanentEnd,
      }
    case 'camp-timers':
      return {
        BeginTime: active ? '0:00:00:00' : closedCampTime,
        EndTime: active ? '8:00:00:00' : closedCampTime,
      }
    case 'integral-boss':
      return active
        ? { Opentime: '00:00', PreStartTime: '0', Lastime: '1440' }
        : { Opentime: '' }
    case 'theme-boss-time':
      return active
        ? { StartTime: '00:00', EndTime: '24:00' }
        : { StartTime: '23:59', EndTime: '23:59' }
    case 'hunting-unlocks':
      return { OpenTime: active ? '2000-01-01 00:00:00' : permanentEnd }
    case 'wish-pool':
      return { OpenTime: active ? '0:0' : '36500:23' }
    default:
      throw new Error(`Unsupported activity schedule: ${configId}`)
  }
}

export function isActivityAlwaysOpen(configId: string, fields: Record<string, string>) {
  switch (configId) {
    case 'recharge-tabs':
    case 'recharge-time':
    case 'direct-purchase-time':
      return fields.ShowStart !== undefined
        && fields.ShowStart !== ''
        && fields.ShowStart !== permanentEnd
        && fields.ShowEnd === permanentEnd
        && fields.ShowWeekStart === ''
        && fields.ShowWeekEnd === ''
    case 'activity-info':
      return fields.OpenStart === '-1'
        && fields.OpenEnd === '0'
        && fields.EndDate === permanentEnd
        && fields.StartTime === '00:00:00'
        && fields.EndTime === '24:00:00'
        && fields.StartDate !== permanentEnd
    case 'special-activity':
      return fields.OpenStart !== undefined
        && fields.OpenStart !== permanentEnd
        && fields.OpenEnd === permanentEnd
    case 'special-activity-table':
      return fields.ShowStart !== undefined
        && fields.ShowStart !== permanentEnd
        && fields.ShowEnd === permanentEnd
    case 'overseas-activity':
      return fields.ActivityStart !== undefined
        && fields.ActivityStart !== permanentEnd
        && fields.ActivityEnd === permanentEnd
        && fields.TabShowEnd === permanentEnd
    case 'camp-timers':
      return fields.BeginTime === '0:00:00:00' && fields.EndTime === '8:00:00:00'
    case 'integral-boss':
      return fields.Opentime === '00:00' && fields.PreStartTime === '0' && fields.Lastime === '1440'
    case 'theme-boss-time':
      return fields.StartTime === '00:00' && fields.EndTime === '24:00'
    case 'hunting-unlocks':
      return fields.OpenTime === '2000-01-01 00:00:00'
    case 'wish-pool':
      return fields.OpenTime === '0:0'
    default:
      return false
  }
}

export function isActivityForceClosed(configId: string, fields: Record<string, string>) {
  switch (configId) {
    case 'recharge-tabs':
    case 'recharge-time':
    case 'direct-purchase-time':
      return fields.ShowStart === permanentEnd && fields.ShowEnd === permanentEnd
    case 'activity-info':
      return fields.StartDate === permanentEnd && fields.EndDate === permanentEnd
    case 'special-activity':
      return fields.OpenStart === permanentEnd && fields.OpenEnd === permanentEnd
    case 'special-activity-table':
      return fields.ShowStart === permanentEnd && fields.ShowEnd === permanentEnd
    case 'overseas-activity':
      return fields.ActivityStart === permanentEnd && fields.ActivityEnd === permanentEnd
    case 'camp-timers':
      return fields.BeginTime === closedCampTime && fields.EndTime === closedCampTime
    case 'integral-boss':
      return fields.Opentime === ''
    case 'theme-boss-time':
      return fields.StartTime === '23:59' && fields.EndTime === '23:59'
    case 'hunting-unlocks':
      return fields.OpenTime === permanentEnd
    case 'wish-pool':
      return fields.OpenTime === '36500:23'
    default:
      return false
  }
}

function formatDateTime(date: Date) {
  const pad = (part: number) => String(part).padStart(2, '0')
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
}
