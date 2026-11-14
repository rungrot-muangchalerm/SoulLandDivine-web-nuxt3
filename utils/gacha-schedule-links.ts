const scheduleControllerByPoolId: Record<number, number> = {
  18: 103,
  4: 42,
  10: 43,
  5: 44,
  3: 41,
}

const scheduleFollowersByControllerId: Record<number, number[]> = {
  103: [18],
  42: [4],
  43: [10],
  44: [5],
  41: [3],
}

const hiddenSchedulePoolIds = new Set([24])

// Keep aligned with ActivityService.GachaLinkedRechargeActivityGroups.
const scheduleActivitiesByControllerId: Record<number, number[]> = {
  103: [141], 19: [132], 20: [146], 21: [144], 23: [148],
  25: [121], 26: [158], 27: [161],
  28: [166], 29: [164], 40: [128], 41: [131, 32], 42: [18, 19, 126, 137, 151],
  43: [53, 149], 44: [25, 27, 160], 98: [903], 99: [901, 902],
}

export function getGachaScheduleActivities(poolId: number) {
  return scheduleActivitiesByControllerId[poolId] ?? []
}

const scheduleDescriptionByControllerId: Record<number, string> = {
  103: 'ตู้พิษสิ้นชีพสงัด ID 103 เป็นตู้หลัก: ตู้รับสมัครธีม ID 18 และกิจกรรมซื้อเจ็ดวัน ID 141 จะเปิด–ปิดตามกัน',
  19: 'ตู้หลัก ID 19 และกิจกรรมซื้อเจ็ดวัน ID 132 จะเปิด–ปิดตามกัน',
  20: 'ตู้หลัก ID 20 และกิจกรรมซื้อเจ็ดวัน ID 146 จะเปิด–ปิดตามกัน',
  21: 'ตู้หลัก ID 21 และกิจกรรมซื้อเจ็ดวัน ID 144 จะเปิด–ปิดตามกัน',
  23: 'ตู้หลัก ID 23 และกิจกรรมซื้อเจ็ดวัน ID 148 จะเปิด–ปิดตามกัน',
  25: 'ตู้หลัก ID 25 และกิจกรรมซื้อเจ็ดวัน ID 121 จะเปิด–ปิดตามกัน',
  26: 'ตู้หลัก ID 26 และกิจกรรมซื้อเจ็ดวัน ID 158 จะเปิด–ปิดตามกัน',
  27: 'ตู้หลัก ID 27 และกิจกรรมซื้อเจ็ดวัน ID 161 จะเปิด–ปิดตามกัน',
  28: 'ตู้หลัก ID 28 และกิจกรรมซื้อเจ็ดวัน ID 166 จะเปิด–ปิดตามกัน',
  29: 'ตู้หลัก ID 29 และกิจกรรมซื้อเจ็ดวัน ID 164 จะเปิด–ปิดตามกัน',
  40: 'ตู้หลัก ID 40 และกิจกรรมซื้อเจ็ดวัน ID 128 จะเปิด–ปิดตามกัน',
  42: 'ตู้เทพอาหยิน ID 42 เป็นแกนหลัก: ตู้ ID 4 และกิจกรรม ID 18, 19, 126, 137, 151 จะเปิด–ปิดตามกัน',
  43: 'ตู้เทพไต้มู่ไป๋ ID 43 เป็นตัวควบคุมหลัก: ตู้ธีมปกติ ID 10 (ชื่อในระบบหยางอี้อวิ๋น) และกิจกรรม ID 53, 149 จะเปิด–ปิดตามกัน',
  44: 'ตู้เทพเชียนเริ่นเสวี่ย ID 44 เป็นตัวควบคุมหลัก: ตู้ธีมปกติ ID 5 และกิจกรรม ID 25, 27, 160 จะเปิด–ปิดตามกัน',
  41: 'ตู้เทพถังซาน ID 41 เป็นตัวควบคุมหลัก: ตู้ฮ่าวเทียนจุติ ID 3 และกิจกรรมถังซาน ID 131 กับตรีศูลเทพสมุทร ID 32 จะเปิด–ปิดตามกัน',
  98: 'ตู้หลัก ID 98 และกิจกรรมซื้อเจ็ดวัน ID 903 จะเปิด–ปิดตามกัน',
  99: 'ตู้หลัก ID 99 และกิจกรรมซื้อเจ็ดวัน ID 901 กับ HeroSevenDay ID 902 จะเปิด–ปิดตามกัน',
}

const scheduleCloseNoticeByControllerId: Record<number, string> = {
  103: ' ตู้รับสมัครธีม ID 18 และกิจกรรมซื้อเจ็ดวัน ID 141 จะปิดตามด้วย',
  19: ' กิจกรรมซื้อเจ็ดวัน ID 132 จะปิดตามด้วย',
  20: ' กิจกรรมซื้อเจ็ดวัน ID 146 จะปิดตามด้วย',
  21: ' กิจกรรมซื้อเจ็ดวัน ID 144 จะปิดตามด้วย',
  23: ' กิจกรรมซื้อเจ็ดวัน ID 148 จะปิดตามด้วย',
  25: ' กิจกรรมซื้อเจ็ดวัน ID 121 จะปิดตามด้วย',
  26: ' กิจกรรมซื้อเจ็ดวัน ID 158 จะปิดตามด้วย',
  27: ' กิจกรรมซื้อเจ็ดวัน ID 161 จะปิดตามด้วย',
  28: ' กิจกรรมซื้อเจ็ดวัน ID 166 จะปิดตามด้วย',
  29: ' กิจกรรมซื้อเจ็ดวัน ID 164 จะปิดตามด้วย',
  40: ' กิจกรรมซื้อเจ็ดวัน ID 128 จะปิดตามด้วย',
  42: ' ตู้ ID 4 และกิจกรรม ID 18, 19, 126, 137, 151 จะปิดตามด้วย',
  43: ' ตู้ธีมปกติ ID 10 และกิจกรรม ID 53, 149 จะปิดตามด้วย',
  44: ' ตู้ธีมปกติ ID 5 และกิจกรรม ID 25, 27, 160 จะปิดตามด้วย',
  41: ' ตู้ฮ่าวเทียนจุติ ID 3 และกิจกรรมถังซาน ID 131 กับตรีศูลเทพสมุทร ID 32 จะปิดตามด้วย',
  98: ' กิจกรรมซื้อเจ็ดวัน ID 903 จะปิดตามด้วย',
  99: ' กิจกรรมซื้อเจ็ดวัน ID 901 และ HeroSevenDay ID 902 จะปิดตามด้วย',
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

export function isGachaSchedulePoolHidden(poolId: number) {
  return hiddenSchedulePoolIds.has(poolId)
}

export function getGachaScheduleDescription(poolId: number) {
  return scheduleDescriptionByControllerId[poolId] ?? ''
}

export function getGachaScheduleCloseNotice(poolId: number) {
  return scheduleCloseNoticeByControllerId[poolId] ?? ''
}
