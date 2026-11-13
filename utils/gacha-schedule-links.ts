const scheduleControllerByPoolId: Record<number, number> = {
  4: 24,
  10: 43,
  5: 44,
  3: 41,
}

const scheduleFollowersByControllerId: Record<number, number[]> = {
  24: [4],
  43: [10],
  44: [5],
  41: [3],
}

const scheduleDescriptionByControllerId: Record<number, string> = {
  24: 'ตู้ร่างเทพ ID 24 เป็นตัวควบคุมหลัก: ตู้ร่างปกติ ID 4 และกิจกรรมเงินคราม ID 18, 19, 126 จะเปิด–ปิดตามกัน',
  43: 'ตู้เทพไต้มู่ไป๋ ID 43 เป็นตัวควบคุมหลัก: ตู้ธีมปกติ ID 10 (ชื่อในระบบหยางอี้อวิ๋น) และกิจกรรม ID 53, 149 จะเปิด–ปิดตามกัน',
  44: 'ตู้เทพเชียนเริ่นเสวี่ย ID 44 เป็นตัวควบคุมหลัก: ตู้ธีมปกติ ID 5 และกิจกรรมเชียนเริ่นเสวี่ย ID 25 จะเปิด–ปิดตามกัน',
  41: 'ตู้เทพถังซาน ID 41 เป็นตัวควบคุมหลัก: ตู้ฮ่าวเทียนจุติ ID 3 และกิจกรรมถังซาน ID 131 กับตรีศูลเทพสมุทร ID 32 จะเปิด–ปิดตามกัน',
}

const scheduleCloseNoticeByControllerId: Record<number, string> = {
  24: ' ตู้ร่างปกติ ID 4 และกิจกรรมเงินคราม ID 18, 19, 126 จะปิดตามด้วย',
  43: ' ตู้ธีมปกติ ID 10 และกิจกรรม ID 53, 149 จะปิดตามด้วย',
  44: ' ตู้ธีมปกติ ID 5 และกิจกรรมเชียนเริ่นเสวี่ย ID 25 จะปิดตามด้วย',
  41: ' ตู้ฮ่าวเทียนจุติ ID 3 และกิจกรรมถังซาน ID 131 กับตรีศูลเทพสมุทร ID 32 จะปิดตามด้วย',
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

export function getGachaScheduleDescription(poolId: number) {
  return scheduleDescriptionByControllerId[poolId] ?? ''
}

export function getGachaScheduleCloseNotice(poolId: number) {
  return scheduleCloseNoticeByControllerId[poolId] ?? ''
}
