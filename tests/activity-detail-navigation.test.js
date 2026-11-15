import { test } from 'node:test'
import assert from 'node:assert/strict'
import { existsSync, readFileSync } from 'node:fs'

const componentPath = new URL('../components/ActivitySchedules.vue', import.meta.url)
const detailRoutePath = new URL('../pages/activities/[id].vue', import.meta.url)
const oldGroupRoutePath = new URL('../pages/activities/[group].vue', import.meta.url)

test('activity cards keep quick activation and move schedule editing to the detail route', () => {
  const component = readFileSync(componentPath, 'utf8')
  const template = component.slice(component.indexOf('<template>') + '<template>'.length, component.lastIndexOf('</template>'))
  const cardList = template.slice(template.indexOf('class="activity-card-overlay"'))

  assert.match(template, /activity-card-overlay/)
  assert.match(cardList, /:to="'\/activities\/'\s*\+\s*activity\.id"/)
  assert.match(cardList, /setActivityAlwaysOpen\(activity/)
  assert.doesNotMatch(cardList, /v-model="drafts\[rowKey\(activity\)\]\[field\.key\]"/)
  assert.doesNotMatch(cardList, /บันทึกตารางเวลา/)
})

test('activity detail route resolves the numeric ID and owns the schedule editor', () => {
  assert.equal(existsSync(detailRoutePath), true)
  assert.equal(existsSync(oldGroupRoutePath), false)

  const route = readFileSync(detailRoutePath, 'utf8')
  const component = readFileSync(componentPath, 'utf8')
  const template = component.slice(component.indexOf('<template>') + '<template>'.length, component.lastIndexOf('</template>'))

  assert.match(route, /route\.params\.id/)
  assert.match(route, /ActivitySchedules[^>]*activity-id/)
  assert.match(component, /activityId\??:\s*number/)
  assert.match(template, /selectedActivityConfig/)
  assert.match(template, /saveSchedule\(selectedActivity\)/)
  assert.match(template, /v-model="drafts\[rowKey\(selectedActivity\)\]\[field\.key\]"/)
})

test('activity card overlays preserve the existing banner aspect ratio without cropping', () => {
  const component = readFileSync(componentPath, 'utf8')
  const style = component.split('<style scoped>')[1].split('</style>')[0]

  assert.match(style, /activity-card-image\s*\{[^}]*width:\s*100%[^}]*height:\s*auto/s)
  assert.match(style, /activity-card-overlay\s*\{/)
  assert.doesNotMatch(style, /aspect-ratio\s*:/)
  assert.doesNotMatch(style, /object-fit:\s*cover/)
})
