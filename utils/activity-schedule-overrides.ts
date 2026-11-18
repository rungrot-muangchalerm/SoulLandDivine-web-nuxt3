const permanentEnd = '9999-12-31 23:59:59'
const closedCampTime = '0:00:00:00'

export const PROTECTED_RECHARGE_ACTIVITY_IDS = [1, 6, 7, 8]
export const GACHA_LINKED_RECHARGE_ACTIVITY_IDS = [
  32, 33, 241, 25, 27, 31, 243, 34, 35, 43, 46, 47, 53, 54, 56, 57, 79, 109, 110, 117, 121,
  126, 127, 128, 131, 271, 133, 137, 272, 144, 145, 146, 147, 148, 149, 150, 151, 157, 158,
  160, 260, 163, 164, 166, 901, 902, 903, 242, 1123, 1124,
]

const gachaLinkedRechargeActivityInfo: Record<number, { gachaId: number; activityName: string; gachaName: string }> = {
  32: { gachaId: 42, activityName: 'กิจกรรมเงินคราม', gachaName: 'อาหยินร่างเทพ' },
  33: { gachaId: 42, activityName: 'กิจกรรมเงินคราม', gachaName: 'อาหยินร่างเทพ' },
  241: { gachaId: 6, activityName: 'เติมเงินรายวัน', gachaName: 'แม่มดสมุทร' },
  25: { gachaId: 44, activityName: 'กิจกรรมเซียนเริ่นเสวี่ย', gachaName: 'เซียนเริ่นเสวี่ย' },
  27: { gachaId: 44, activityName: '天使祈福', gachaName: 'เซียนเริ่นเสวี่ย' },
  31: { gachaId: 6, activityName: '深海之声', gachaName: 'แม่มดสมุทร' },
  243: { gachaId: 41, activityName: 'ตรีศูลเทพสมุทร', gachaName: 'ถังซานร่างเทพ' },
  34: { gachaId: 7, activityName: 'เติมเงินรายวันชุด 5', gachaName: 'ถังเลี่ย' },
  35: { gachaId: 7, activityName: '烈阳祝福', gachaName: 'ถังเลี่ย' },
  43: { gachaId: 8, activityName: '海龙宝藏', gachaName: 'มังกรสมุทร' },
  46: { gachaId: 9, activityName: 'เติมเงินรายวัน', gachaName: 'ยูเรเซีย' },
  47: { gachaId: 9, activityName: '黎沫宝阁', gachaName: 'ยูเรเซีย' },
  53: { gachaId: 43, activityName: 'กิจกรรมซื้อเจ็ดวัน', gachaName: 'ไต้มู่ไป๋' },
  54: { gachaId: 43, activityName: '七日七星', gachaName: 'ไต้มู่ไป๋' },
  56: { gachaId: 11, activityName: 'เติมเงินรายวันชุด 8', gachaName: 'ปีศาจทะเล' },
  57: { gachaId: 11, activityName: '魔鬼的宝藏', gachaName: 'ปีศาจทะเล' },
  79: { gachaId: 17, activityName: '幻境迷雾', gachaName: 'ไห่ฮ่วน' },
  109: { gachaId: 12, activityName: 'เติมเงินรายวันชุด 9', gachaName: 'ไป๋เฉินเซียง' },
  110: { gachaId: 12, activityName: '翼翼飞鸾', gachaName: 'ไป๋เฉินเซียง' },
  117: { gachaId: 13, activityName: '龙王降世', gachaName: 'หยวนเจิ้น' },
  121: { gachaId: 99, activityName: 'กิจกรรมซื้อเจ็ดวัน', gachaName: 'โหลวเกา' },
  126: { gachaId: 42, activityName: 'กิจกรรมเงินคราม', gachaName: 'อาหยินร่างเทพ' },
  127: { gachaId: 15, activityName: '昊天密藏', gachaName: 'ถังเซียว' },
  128: { gachaId: 40, activityName: 'กิจกรรมซื้อเจ็ดวัน', gachaName: 'ตู้ ID 40' },
  131: { gachaId: 41, activityName: 'กิจกรรมถังซาน', gachaName: 'ถังซานร่างเทพ' },
  271: { gachaId: 19, activityName: 'กิจกรรมซื้อเจ็ดวัน', gachaName: 'หนิงจื่อ' },
  133: { gachaId: 19, activityName: '星鱼寄礼', gachaName: 'หนิงจื่อ' },
  137: { gachaId: 42, activityName: 'กิจกรรมเงินคราม', gachaName: 'อาหยินร่างเทพ' },
  272: { gachaId: 103, activityName: 'กิจกรรมซื้อเจ็ดวัน', gachaName: 'พิษสิ้นชีพสงัด' },
  144: { gachaId: 21, activityName: 'กิจกรรมซื้อเจ็ดวัน', gachaName: 'เสวี่ยเปิง' },
  145: { gachaId: 21, activityName: '七日领取', gachaName: 'เสวี่ยเปิง' },
  146: { gachaId: 12, activityName: 'กิจกรรมซื้อเจ็ดวัน (หม่าหงจวิ้น)', gachaName: 'ไป๋เฉินเซียง' },
  147: { gachaId: 23, activityName: '七日领取', gachaName: 'หยู่เสี่ยวกัง' },
  148: { gachaId: 23, activityName: 'กิจกรรมซื้อเจ็ดวัน', gachaName: 'หยู่เสี่ยวกัง' },
  149: { gachaId: 43, activityName: 'กิจกรรมซื้อเจ็ดวัน', gachaName: 'ไต้มู่ไป๋' },
  150: { gachaId: 99, activityName: '七日领取', gachaName: 'โหลวเกา' },
  151: { gachaId: 42, activityName: 'กิจกรรมซื้อเจ็ดวัน', gachaName: 'อาหยินร่างเทพ' },
  157: { gachaId: 26, activityName: '七日领取', gachaName: 'เฟิงเซี่ยวเทียน' },
  158: { gachaId: 26, activityName: 'กิจกรรมซื้อเจ็ดวัน', gachaName: 'เฟิงเซี่ยวเทียน' },
  160: { gachaId: 44, activityName: 'กิจกรรมซื้อเจ็ดวัน', gachaName: 'เซียนเริ่นเสวี่ย' },
  260: { gachaId: 27, activityName: 'กิจกรรมซื้อเจ็ดวัน', gachaName: 'ตู้ ID 27' },
  163: { gachaId: 29, activityName: '七日领取', gachaName: 'ไต้เว่ยซือ' },
  164: { gachaId: 29, activityName: 'กิจกรรมซื้อเจ็ดวัน', gachaName: 'ไต้เว่ยซือ' },
  166: { gachaId: 28, activityName: 'กิจกรรมซื้อเจ็ดวัน', gachaName: 'ตู้ ID 28' },
  901: { gachaId: 99, activityName: 'กิจกรรมซื้อเจ็ดวัน', gachaName: 'โหลวเกา' },
  902: { gachaId: 99, activityName: '角色新程', gachaName: 'โหลวเกา' },
  903: { gachaId: 98, activityName: 'กิจกรรมซื้อเจ็ดวัน', gachaName: 'ตู้ ID 98' },
  242: { gachaId: 8, activityName: 'เติมเงินรายวันชุด 2006', gachaName: 'มังกรสมุทร' },
  1123: { gachaId: 103, activityName: 'ดินแดนหลัวช่า', gachaName: 'พิษสิ้นชีพสงัด' },
  1124: { gachaId: 103, activityName: '教皇殿', gachaName: 'พิษสิ้นชีพสงัด' },
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
    ? linkedActivity.gachaId === 42
      ? `เปิด–ปิดตามตู้หลักอาหยินร่างเทพ ID 42 เท่านั้น (ตู้ร่างปกติ ID 4 จะตามด้วย)`
      : `เปิด–ปิดตามตู้กาชา${linkedActivity.gachaName} ID ${linkedActivity.gachaId} เท่านั้น`
    : undefined
}


export const BOSS_LINKED_RECHARGE_ACTIVITY_IDS = [255, 29, 239, 21, 22, 257, 23, 240, 38, 256, 258]
const bossParentByFollowerActivityId: Record<number, number> = {
  255: 10,
  29: 11,
  239: 12,
  21: 13,
  22: 14,
  257: 15,
  23: 16,
  240: 17,
  38: 18,
  256: 19,
  258: 20,
}

/** Resolve actual follower activities from the full API result, not the
 * independently manageable list (which intentionally hides followers).
 * Same mapping powers the disabled child controls and the parent previews.
 */
export function getBossLinkedRechargeActivities<T extends { id: number; configId: string }>(
  configId: string,
  bossId: number,
  activities: readonly T[],
): T[] {
  if (configId !== 'recharge-tabs' || !Number.isSafeInteger(bossId)) return []
  return activities.filter(
    activity => activity.configId === 'recharge-tabs'
      && bossParentByFollowerActivityId[activity.id] === bossId,
  )
}

export function getBossLinkedRechargeParentId(configId: string, childId: number): number | undefined {
  return configId === 'recharge-tabs' ? bossParentByFollowerActivityId[childId] : undefined
}
export function isBossLinkedRechargeActivity(configId: string, id: number) {
  return configId === 'recharge-tabs' && bossParentByFollowerActivityId[id] !== undefined
}

export function getBossLinkedRechargeActivityNotice(configId: string, id: number) {
  if (!isBossLinkedRechargeActivity(configId, id)) return undefined
  return 'เปิด–ปิดตามกิจกรรมบอสธีม ID ' + bossParentByFollowerActivityId[id] + ' เท่านั้น'
}

/** Super Sales parents ordered by increasing Shrekland cumulative-score ceiling.
 * Periods 3 and 4 tie at 100000 points; preserve their period order.
 * The child ID is never a standalone activity controller.
 */
export const SUPER_SALES_SHREKLAND_LINKS = [
  { superSalesId: 207, shreklandId: 269, period: 1, maxScore: 15000 },
  { superSalesId: 212, shreklandId: 270, period: 2, maxScore: 30000 },
  { superSalesId: 216, shreklandId: 279, period: 3, maxScore: 50000 },
  { superSalesId: 220, shreklandId: 280, period: 4, maxScore: 100000 },
  { superSalesId: 222, shreklandId: 281, period: 5, maxScore: 100000 },
] as const

const superSalesParentByShreklandId: Record<number, number> = Object.fromEntries(
  SUPER_SALES_SHREKLAND_LINKS.map(link => [link.shreklandId, link.superSalesId]),
)

export function getSuperSalesLinkedShreklandParentId(configId: string, childId: number): number | undefined {
  return configId === 'recharge-tabs' ? superSalesParentByShreklandId[childId] : undefined
}

export function isSuperSalesLinkedShreklandActivity(configId: string, id: number) {
  return getSuperSalesLinkedShreklandParentId(configId, id) !== undefined
}

export function getSuperSalesLinkedShreklandActivityNotice(configId: string, id: number) {
  const parentId = getSuperSalesLinkedShreklandParentId(configId, id)
  return parentId !== undefined
    ? 'เปิด–ปิดตามกิจกรรม Super Sales ID ' + parentId + ' เท่านั้น'
    : undefined
}

export function getSuperSalesLinkedShreklandActivities<T extends { id: number; configId: string }>(
  configId: string,
  parentId: number,
  activities: readonly T[],
): T[] {
  if (configId !== 'recharge-tabs') return []
  return activities.filter(activity => activity.configId === 'recharge-tabs'
    && superSalesParentByShreklandId[activity.id] === parentId)
}
export function isControlledRechargeActivity(configId: string, id: number) {
  return isGachaLinkedRechargeActivity(configId, id) || isBossLinkedRechargeActivity(configId, id)
    || isSuperSalesLinkedShreklandActivity(configId, id)
}

export function getControlledRechargeActivityMessage(configId: string, id: number) {
  return getBossLinkedRechargeActivityNotice(configId, id)
    ?? getSuperSalesLinkedShreklandActivityNotice(configId, id)
    ?? getGachaLinkedRechargeActivityMessage(configId, id)
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
