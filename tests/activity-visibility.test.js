import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import { isVisibleInActivityManagement } from '../utils/activity-schedule-visibility.mjs'

test('hides only the WeChat Official Account row from activity management', () => {
  assert.equal(isVisibleInActivityManagement({ configId: 'recharge-tabs', id: 9 }), false)
  assert.equal(isVisibleInActivityManagement({ configId: 'recharge-tabs', id: 10 }), true)
  assert.equal(isVisibleInActivityManagement({ configId: 'activity-info', id: 9 }), true)
})

test('activity list and direct detail view both use the filtered activity collection', () => {
  const component = readFileSync(new URL('../components/ActivitySchedules.vue', import.meta.url), 'utf8')

  assert.match(component, /isVisibleInActivityManagement\(activity\)/)
  assert.match(component, /activities\.value = managedActivities/)
  assert.match(component, /activities\.value\.find\(\(activity\) => activity\.id === props\.activityId\)/)
})
