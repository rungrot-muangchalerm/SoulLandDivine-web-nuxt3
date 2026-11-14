const permanentEnd = '9999-12-31 23:59:59'
const closedCampTime = '0:00:00:00'

export const PROTECTED_RECHARGE_ACTIVITY_IDS = [1, 6, 7, 13, 22]
export const GACHA_LINKED_RECHARGE_ACTIVITY_IDS = [
  18, 19, 24, 25, 27, 32, 34, 46, 53, 56, 109, 121, 126, 128, 131, 132, 137, 141,
  144, 146, 148, 149, 151, 158, 160, 161, 164, 166, 901, 902, 903, 999,
]

const gachaLinkedRechargeActivityInfo: Record<number, { gachaId: number; activityName: string; gachaName: string }> = {
  18: { gachaId: 24, activityName: 'กิจกรรมเงินคราม', gachaName: 'อาหยินร่างเทพ' },
  19: { gachaId: 24, activityName: 'กิจกรรมเงินคราม', gachaName: 'อาหยินร่างเทพ' },
  25: { gachaId: 5, activityName: 'กิจกรรมเซียนเริ่นเสวี่ย', gachaName: 'เซียนเริ่นเสวี่ย' },
  34: { gachaId: 7, activityName: 'เติมเงินรายวันชุด 5', gachaName: 'ถังเลี่ย' },
  109: { gachaId: 12, activityName: 'เติมเงินรายวันชุด 9', gachaName: 'ไป๋เฉินเซียง' },
  146: { gachaId: 12, activityName: 'กิจกรรมซื้อเจ็ดวัน (หม่าหงจวิ้น)', gachaName: 'ไป๋เฉินเซียง' },
  46: { gachaId: 9, activityName: 'เติมเงินรายวัน', gachaName: 'ยูเรเซีย' },
  56: { gachaId: 11, activityName: 'เติมเงินรายวันชุด 8', gachaName: 'ปีศาจทะเล' },
  126: { gachaId: 24, activityName: 'กิจกรรมเงินคราม', gachaName: 'อาหยินร่างเทพ' },
}

export function isProtectedRechargeActivity(configId: string, id: number) {
  return configId === 'recharge-tabs' && PROTECTED_RECHARGE_ACTIVITY_IDS.includes(id)
}

export function isGachaLinkedRechargeActivity(configId: string, id: number) {
  return configId === 'recharge-tabs' && GACHA_LINKED_RECHARGE_ACTIVITY_IDS.includes(id)
}

export function getGachaLinkedRechargeActivityMessage(configId: string, id: number) {
  if (configId !== 'recharge-tabs') return undefined
  const linkedActivity = gachaLinkedRechargeActivityInfo[id]
  return linkedActivity
    ? `${linkedActivity.activityName} ID ${id} ถูกควบคุมตามตู้กาชา${linkedActivity.gachaName} ID ${linkedActivity.gachaId}`
    : undefined
}

export function getGachaLinkedRechargeActivityNotice(configId: string, id: number) {
  if (configId !== 'recharge-tabs') return undefined
  const linkedActivity = gachaLinkedRechargeActivityInfo[id]
  return linkedActivity
    ? linkedActivity.gachaId === 24
      ? `เปิด–ปิดตามตู้หลักอาหยินร่างเทพ ID 24 เท่านั้น (ตู้ร่างปกติ ID 4 จะตามด้วย)`
      : `เปิด–ปิดตามตู้กาชา${linkedActivity.gachaName} ID ${linkedActivity.gachaId} เท่านั้น`
    : undefined
}

export function getActivityOverrideFields(
  configId: string,
  active: boolean,
  now: Date,
): Record<string, string> {
  const nowText = formatDateTime(now)
  switch (configId) {
    case 'recharge-time':
    case 'direct-purchase-time':
      return {
        ShowStart: active ? nowText : permanentEnd,
        ShowEnd: permanentEnd,
        ShowWeekStart: '',
        ShowWeekEnd: '',
        TabShowEnd: active ? permanentEnd : nowText,
        GiveReward: active ? permanentEnd : nowText,
      }
    case 'recharge-tabs':
      return active
        ? {
            ShowStart: nowText,
            ShowEnd: permanentEnd,
            ShowWeekStart: '',
            ShowWeekEnd: '',
            TabShowEnd: permanentEnd,
            GiveReward: permanentEnd,
            OpenStart: '-1',
            OpenEnd: '0',
          }
        : {
            ShowStart: '',
            ShowEnd: '',
            ShowWeekStart: '',
            ShowWeekEnd: '',
            TabShowEnd: nowText,
            GiveReward: nowText,
            OpenStart: '-1',
            OpenEnd: '0',
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
    case 'recharge-time':
    case 'direct-purchase-time':
      return fields.ShowStart === permanentEnd && fields.ShowEnd === permanentEnd
    case 'recharge-tabs':
      return fields.ShowStart === '' && fields.ShowEnd === ''
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
