import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync, existsSync } from 'node:fs'
import ts from 'typescript'

const source = readFileSync(new URL('../utils/gacha-schedule-links.ts', import.meta.url), 'utf8')
const js = ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.ESNext } }).outputText
const links = await import(`data:text/javascript;base64,${Buffer.from(js).toString('base64')}`)
const overridesSource = readFileSync(new URL('../utils/activity-schedule-overrides.ts', import.meta.url), 'utf8')
const overridesJs = ts.transpileModule(overridesSource, { compilerOptions: { module: ts.ModuleKind.ESNext } }).outputText
const overrides = await import(`data:text/javascript;base64,${Buffer.from(overridesJs).toString('base64')}`)
const serverFile = new URL('../../SoulLandDivine-server/AdminAPI/Services/ActivityService.cs', import.meta.url)

test('preview activity IDs match the server schedule linkage', { skip: !existsSync(serverFile) }, () => {
  const server = readFileSync(serverFile, 'utf8')
  const group = server.split('GachaLinkedRechargeActivityGroups =')[1].split('};')[0]
  const expected = [...group.matchAll(/\((\d+), new\[\] \{([^}]+)\}\)/g)]
  assert.ok(expected.length > 0)
  for (const row of expected) {
    assert.deepEqual(links.getGachaScheduleActivities(Number(row[1])), row[2].split(',').map(Number), `controller ${row[1]}`)
  }
})

test('activity manager excludes every server-linked recharge activity', { skip: !existsSync(serverFile) }, () => {
  const server = readFileSync(serverFile, 'utf8')
  const group = server.split('GachaLinkedRechargeActivityGroups =')[1].split('};')[0]
  const expected = [...group.matchAll(/\((\d+), new\[\] \{([^}]+)\}\)/g)]
    .flatMap(row => row[2].split(',').map(Number))
    .sort((a, b) => a - b)

  assert.deepEqual([...overrides.GACHA_LINKED_RECHARGE_ACTIVITY_IDS].sort((a, b) => a - b), expected)
  for (const id of expected) {
    assert.equal(overrides.isGachaLinkedRechargeActivity('recharge-tabs', id), true, `activity ${id}`)
  }
})

test('standalone pools do not receive unrelated activity previews', () => {
  assert.deepEqual(links.getGachaScheduleActivities(10000), [])
})

test('poison gacha 103 controls theme recruitment pool 18 and activity 272', () => {
  assert.equal(links.getGachaScheduleControllerId(18), 103)
  assert.deepEqual(links.getGachaScheduleFollowers(103), [18])
  assert.deepEqual(links.getGachaScheduleActivities(18), [])
  assert.deepEqual(links.getGachaScheduleActivities(103), [1123, 1124, 272])
})

test('Lougao gacha 99 controls theme pool 25 and linked activities', () => {
  assert.equal(links.getGachaScheduleControllerId(25), 99)
  assert.deepEqual(links.getGachaScheduleFollowers(99), [25])
  assert.deepEqual(links.getGachaScheduleActivities(25), [])
  assert.deepEqual(links.getGachaScheduleActivities(99), [121, 150, 901, 902])
})

test('Sea Witch gacha 6 controls daily recharge activity 241 and Deep Sea Voice activity 31', () => {
  assert.deepEqual(links.getGachaScheduleActivities(6), [241, 31])
  assert.equal(overrides.isGachaLinkedRechargeActivity('recharge-tabs', 31), true)
  assert.match(overrides.getGachaLinkedRechargeActivityMessage('recharge-tabs', 31), /ID 6/)
  assert.match(overrides.getGachaLinkedRechargeActivityNotice('recharge-tabs', 31), /แม่มดสมุทร ID 6/)
  assert.match(links.getGachaScheduleDescription(6), /深海之声 ID 31/)
  assert.match(links.getGachaScheduleCloseNotice(6), /深海之声 ID 31/)
})

test('Tang Lie gacha 7 controls daily recharge activity 34 and Sun Blessing activity 35', () => {
  assert.deepEqual(links.getGachaScheduleActivities(7), [34, 35])
  assert.equal(overrides.isGachaLinkedRechargeActivity('recharge-tabs', 35), true)
  assert.match(overrides.getGachaLinkedRechargeActivityMessage('recharge-tabs', 35), /ID 7/)
  assert.match(overrides.getGachaLinkedRechargeActivityNotice('recharge-tabs', 35), /ถังเลี่ย ID 7/)
  assert.match(links.getGachaScheduleDescription(7), /烈阳祝福 ID 35/)
  assert.match(links.getGachaScheduleCloseNotice(7), /烈阳祝福 ID 35/)
})

test('Bai Chenxiang gacha 12 controls Mahongjun gacha 20 and linked activities', () => {
  assert.equal(links.getGachaScheduleControllerId(20), 12)
  assert.deepEqual(links.getGachaScheduleFollowers(12), [20])
  assert.deepEqual(links.getGachaScheduleActivities(12), [109, 110, 146])
  assert.deepEqual(links.getGachaScheduleActivities(20), [])
  assert.match(overrides.getGachaLinkedRechargeActivityNotice('recharge-tabs', 109), /ID 12/)
  assert.match(overrides.getGachaLinkedRechargeActivityNotice('recharge-tabs', 146), /ID 12/)
})

test('Sea Dragon gacha 8 controls recharge set 2006 activity 242', () => {
  assert.deepEqual(links.getGachaScheduleActivities(8), [43, 242])
})

test('theme gacha 9 controls daily recharge activity 46 and Limo Treasure activity 47', () => {
  assert.deepEqual(links.getGachaScheduleActivities(9), [46, 47])
  assert.equal(overrides.isGachaLinkedRechargeActivity('recharge-tabs', 47), true)
  assert.match(overrides.getGachaLinkedRechargeActivityMessage('recharge-tabs', 47), /\u9ece\u6cab\u5b9d\u9601 ID 47/)
  assert.match(overrides.getGachaLinkedRechargeActivityMessage('recharge-tabs', 47), /\u0e22\u0e39\u0e40\u0e23\u0e40\u0e0b\u0e35\u0e22 ID 9/)
  assert.match(overrides.getGachaLinkedRechargeActivityNotice('recharge-tabs', 47), /\u0e22\u0e39\u0e40\u0e23\u0e40\u0e0b\u0e35\u0e22 ID 9/)
  assert.match(links.getGachaScheduleDescription(9), /\u9ece\u6cab\u5b9d\u9601 ID 47/)
  assert.match(links.getGachaScheduleDescription(9), /\u0e40\u0e1b\u0e34\u0e14\u2013\u0e1b\u0e34\u0e14\u0e15\u0e32\u0e21\u0e01\u0e31\u0e19/)
  assert.match(links.getGachaScheduleCloseNotice(9), /\u9ece\u6cab\u5b9d\u9601 ID 47/)
  assert.match(links.getGachaScheduleCloseNotice(9), /\u0e1b\u0e34\u0e14\u0e15\u0e32\u0e21\u0e14\u0e49\u0e27\u0e22/)
})

test('Sea Devil gacha 11 controls daily recharge set 8 activity 56', () => {
  assert.deepEqual(links.getGachaScheduleActivities(11), [56, 57])
})

test('daily recharge activity 46 is protected from manual scheduling', () => {
  assert.equal(overrides.isGachaLinkedRechargeActivity('recharge-tabs', 46), true)
  assert.match(overrides.getGachaLinkedRechargeActivityNotice('recharge-tabs', 46), /ยูเรเซีย ID 9/)
})

test('deity recruitment pool 42 controls the Ayin group and hides retired pool 24', () => {
  assert.equal(links.getGachaScheduleControllerId(4), 42)
  assert.deepEqual(links.getGachaScheduleFollowers(42), [4])
  assert.deepEqual(links.getGachaScheduleActivities(24), [])
  assert.deepEqual(links.getGachaScheduleActivities(42), [32, 33, 126, 137, 151])
  assert.equal(links.isGachaSchedulePoolHidden(24), true)
})

const type16PoolByActivityId = new Map([
  [32, 42], [27, 5], [31, 6], [35, 7], [43, 8], [47, 9], [54, 10], [57, 11],
  [110, 12], [117, 13], [127, 15], [79, 17], [133, 19], [145, 21], [147, 23],
  [150, 25], [157, 26], [163, 29], [902, 99], [1124, 103],
])
const type16ControllerByActivityId = new Map([
  [32, 42], [27, 44], [31, 6], [35, 7], [43, 8], [47, 9], [54, 43], [57, 11],
  [110, 12], [117, 13], [127, 15], [79, 17], [133, 19], [145, 21], [147, 23],
  [150, 99], [157, 26], [163, 29], [902, 99], [1124, 103],
])

function parseXmlRows(xml) {
  return [...xml.matchAll(/<class\b([^>]*)\/>/g)].map((match) =>
    Object.fromEntries([...match[1].matchAll(/([\w]+)="([^"]*)"/g)].map((attribute) => [attribute[1], attribute[2]])),
  )
}

test('every Type 16 Hero Seven Day activity points at its real DrawTime pool', () => {
  const clientFile = new URL('../../SoulLandDivine-client/Assets/Resources/XML/Server/Recharge/RechargeGiftTab.xml', import.meta.url)
  const drawTimeFile = new URL('../../SoulLandDivine-server/RuntimeData/Data/XML/Draw/DrawTime.xml', import.meta.url)
  assert.ok(existsSync(clientFile), 'client RechargeGiftTab.xml exists')
  assert.ok(existsSync(drawTimeFile), 'server DrawTime.xml exists')
  const activities = parseXmlRows(readFileSync(clientFile, 'utf8')).filter((row) => row.GiftType === '16')
  const drawTimeIds = new Set(parseXmlRows(readFileSync(drawTimeFile, 'utf8')).map((row) => Number(row.id)))
  assert.equal(activities.length, type16PoolByActivityId.size, 'all 20 Type 16 activities are present')
  for (const [activityId, poolId] of type16PoolByActivityId) {
    const activity = activities.find((row) => Number(row.id) === activityId)
    assert.ok(activity, `activity ${activityId} exists`)
    assert.equal(Number(activity.DrawPoolId), poolId, `activity ${activityId} uses DrawPoolId ${poolId}`)
    assert.ok(drawTimeIds.has(poolId), `DrawTime pool ${poolId} exists`)
    const controllerId = type16ControllerByActivityId.get(activityId)
    assert.equal(links.getGachaScheduleControllerId(poolId), controllerId, `activity ${activityId} follows controller ${controllerId}`)
    assert.ok(links.getGachaScheduleActivities(controllerId).includes(activityId), `controller ${controllerId} previews activity ${activityId}`)
  }
})

test('every Type 16 activity is protected and shows its controlling Gacha', () => {
  for (const [activityId, controllerId] of type16ControllerByActivityId) {
    assert.equal(overrides.isGachaLinkedRechargeActivity('recharge-tabs', activityId), true, `activity ${activityId} cannot be manually detached`)
    assert.match(overrides.getGachaLinkedRechargeActivityMessage('recharge-tabs', activityId) ?? '', new RegExp(`ID ${controllerId}`), `activity ${activityId} explains its controller`)
    assert.match(overrides.getGachaLinkedRechargeActivityNotice('recharge-tabs', activityId) ?? '', new RegExp(`ID ${controllerId}`), `activity ${activityId} displays its controller notice`)
  }
})
test('Hero Seven Day client state is isolated by activity period', () => {
  const managerFile = new URL('../../SoulLandDivine-client/Assets/Lua/Manager/Recharge/RechargeManager.lua', import.meta.url)
  const netFile = new URL('../../SoulLandDivine-client/Assets/Lua/Net/Net_Recharge.lua', import.meta.url)
  const widgetFile = new URL('../../SoulLandDivine-client/Assets/Lua/UI/Widget/Recharge/Widget_HeroSevenDay.lua', import.meta.url)
  assert.ok(existsSync(managerFile) && existsSync(netFile) && existsSync(widgetFile))

  const manager = readFileSync(managerFile, 'utf8')
  const net = readFileSync(netFile, 'utf8')
  const widget = readFileSync(widgetFile, 'utf8')
  assert.match(manager, /heroDaysInfoByPeriod/)
  assert.match(manager, /GetHeroDaysInfo\(giftTabData\.subType\)/)
  assert.match(net, /tonumber\(msg\.Period\)/)
  assert.match(net, /SetHeroDaysRewardList\(period, msg\.GetList\)/)
  assert.match(net, /function Net_Recharge:ReqHeroDaysReward\(request\)/)
  assert.match(net, /Id = rewardId, Period = period/)
  assert.match(widget, /local period = tonumber\(self\.rechargeGiftData\.subType\)/)
  assert.match(widget, /NetDispatch\(EventConst\.REQ_HERODAYS_REWARD, \{Id = id, Period = period\}\)/)
  assert.match(widget, /GetHeroDaysInfo\(self\.rechargeGiftData\.subType\)/)
  assert.match(widget, /ClearHeroDaysInfo\(self\.rechargeGiftData\.subType\)/)
  assert.doesNotMatch(widget, /local mTimeRun|local gameObject, transform/)
})
test('Activities page hides every Gacha-linked activity regardless of GiftType', () => {
  const linkedIds = overrides.GACHA_LINKED_RECHARGE_ACTIVITY_IDS
  for (const activityId of linkedIds) {
    assert.equal(overrides.isGachaLinkedRechargeActivity('recharge-tabs', activityId), true, 'linked activity ' + activityId + ' is hidden')
  }
  for (const dailyRechargeId of [241, 34, 46, 56, 109, 242]) {
    assert.ok(linkedIds.includes(dailyRechargeId), 'daily recharge activity ' + dailyRechargeId + ' is linked')
    assert.equal(overrides.isGachaLinkedRechargeActivity('recharge-tabs', dailyRechargeId), true)
  }
  assert.equal(overrides.isGachaLinkedRechargeActivity('recharge-tabs', 99999), false)
  assert.equal(overrides.isGachaLinkedRechargeActivity('activity-info', 24), false)

  const componentFile = new URL('../components/ActivitySchedules.vue', import.meta.url)
  assert.ok(existsSync(componentFile))
  const component = readFileSync(componentFile, 'utf8')
  assert.ok(component.includes('const managedActivities = result.activities.filter('))
  assert.ok(component.includes('isVisibleInActivityManagement(activity)'))
  assert.ok(component.includes('!isControlledRechargeActivity(activity.configId, activity.id)'))
  assert.ok(component.includes('activities.value = managedActivities'))
  assert.ok(component.includes('drafts.value = Object.fromEntries(managedActivities.map('))
  assert.ok(!component.includes('isHiddenGachaLinkedType16Activity'))
})


test('Luosha Land activity 1123 is exclusively controlled by poison gacha 103', () => {
  assert.deepEqual(links.getGachaScheduleActivities(103), [1123, 1124, 272])
  assert.equal(overrides.isGachaLinkedRechargeActivity('recharge-tabs', 1123), true)
  assert.match(overrides.getGachaLinkedRechargeActivityMessage('recharge-tabs', 1123), /ID 103/)
  assert.match(overrides.getGachaLinkedRechargeActivityNotice('recharge-tabs', 1123), /ID 103/)
  assert.match(links.getGachaScheduleDescription(103), /ID 1123/)
  assert.match(links.getGachaScheduleCloseNotice(103), /ID 1123/)
})


test('ThemeBoss ID 10–20 stay independently schedulable; relocated Ayin tabs 32 and 33 follow Gacha 42', () => {
  assert.deepEqual(overrides.PROTECTED_RECHARGE_ACTIVITY_IDS, [1, 6, 7, 8])
  for (let rowId = 10; rowId <= 20; rowId++) {
    assert.equal(overrides.isProtectedRechargeActivity('recharge-tabs', rowId), false, 'ThemeBoss row ' + rowId + ' must not be permanent')
    assert.equal(overrides.isGachaLinkedRechargeActivity('recharge-tabs', rowId), false, 'ThemeBoss row ' + rowId + ' must not be Gacha-linked')
  }
  for (const rowId of [32, 33]) {
    assert.equal(overrides.isGachaLinkedRechargeActivity('recharge-tabs', rowId), true)
    assert.match(overrides.getGachaLinkedRechargeActivityNotice('recharge-tabs', rowId), /ID 42/)
    assert.ok(links.getGachaScheduleActivities(42).includes(rowId))
  }
})

test('Summer Day is independent and does not show unverified supporting activities', () => {
  const overrideText = readFileSync(new URL('../utils/activity-schedule-overrides.ts', import.meta.url), 'utf8')
  const page = readFileSync(new URL('../components/ActivitySchedules.vue', import.meta.url), 'utf8')
  const server = readFileSync(new URL('../server/utils/activity-schedules.ts', import.meta.url), 'utf8')
  const route = readFileSync(new URL('../server/api/activities/index.get.ts', import.meta.url), 'utf8')
  assert.equal(overrides.isControlledRechargeActivity('recharge-time', 1), false)
  assert.equal(overrides.isControlledRechargeActivity('recharge-time', 3), false)
  assert.doesNotMatch(page, /ActivityDiceSales|getIslandHighDiceSupportingActivities|isIslandHighDiceSupporter/)
  assert.doesNotMatch(overrideText, /ISLAND_HIGH_DICE_SUPPORTERS|getIslandHighDiceSupportingActivities/)
  assert.doesNotMatch(server, /isIslandHighDiceSupporter/)
  assert.doesNotMatch(route, /config.id === 'recharge-time'/)
})
test('all 21 dice products are real sale entries in the original configuration', () => {
  const packs = readFileSync(new URL('../../SoulLandDivine-server/RuntimeData/Data/XML/Recharge/RechargeGiftItem.xml', import.meta.url), 'utf8')
  const mall = readFileSync(new URL('../../SoulLandDivine-server/RuntimeData/Data/XML/Recharge/CarnivalMall.xml', import.meta.url), 'utf8')
  for (let id = 6301; id <= 6309; id++) {
    const line = packs.split('\n').find(row => row.includes('id="' + id + '"'))
    assert.ok(line && /GiftType="24" SubType="1"/.test(line) && /402[012]:2:/.test(line), 'pack ' + id)
  }
  for (let id = 1; id <= 12; id++) {
    const line = mall.split('\n').find(row => row.includes('id="' + id + '"'))
    assert.ok(line && /402[012]:2:/.test(line) && /Price="503:1:/.test(line), 'mall item ' + id)
  }
})
test('Super Sales never auto-links to Summer Day without a real dice product', () => {
  const tabs = readFileSync(new URL('../../SoulLandDivine-server/RuntimeData/Data/XML/Recharge/RechargeGiftTab.xml', import.meta.url), 'utf8')
  const gifts = readFileSync(new URL('../../SoulLandDivine-server/RuntimeData/Data/XML/Recharge/RechargeGiftItem.xml', import.meta.url), 'utf8')
  const milestones = readFileSync(new URL('../../SoulLandDivine-server/RuntimeData/Data/XML/Recharge/NewRechargeGift.xml', import.meta.url), 'utf8')
  const salesRows = tabs.split('\n').filter(row => /<class /.test(row) && /GiftType="39"/.test(row))
  const saleProducts = gifts.split('\n').filter(row => /<class /.test(row) && /GiftType="39"/.test(row))
  const milestoneRows = milestones.split('\n').filter(row => /<class /.test(row) && /Reward="/.test(row))
  assert.equal(salesRows.length, 22)
  assert.equal(saleProducts.length, 207)
  for (const row of [...saleProducts, ...milestoneRows]) {
    const reward = row.match(/Reward="([^"]+)"/)?.[1] || ''
    assert.ok(!reward.split('|').some(item => /^402[012]:2:/.test(item)), 'Super Sales incorrectly supplies dice: ' + row)
  }
  const overrideText = readFileSync(new URL('../utils/activity-schedule-overrides.ts', import.meta.url), 'utf8')
})