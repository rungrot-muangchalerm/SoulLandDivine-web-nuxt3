import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const editor = readFileSync(new URL('../pages/code-cards/templates.vue', import.meta.url), 'utf8')
const preview = readFileSync(new URL('../components/CodeCardPreview.vue', import.meta.url), 'utf8')

test('new template starts with no preselected hero, name, talent, equipment, or ring ages', () => {
  assert.match(editor, /function blank\(\): CardDefinition[\s\S]*?name: ''/)
  assert.match(editor, /heroId: ''/)
  assert.match(editor, /talent: ''/)
  assert.match(editor, /talentValue: 0/)
  assert.match(editor, /length: 5[\s\S]*?id: '', stars: 0, level: 0/)
  assert.match(editor, /length: 10[\s\S]*?id: '', year: 0/)
  assert.doesNotMatch(editor, /catalog\.value\?\.defaultCard\s*\?/)
  assert.match(editor, /const draft = ref<CardDefinition>\(blank\(\)\)/)
  assert.match(editor, /value \? cloneCardDefinition\(value\.definition\) : blank\(\)/)
})

test('blank form keeps ring year and talent unselected until entered', () => {
  assert.match(editor, /<option value="">เลือกพรสวรรค์<\/option>/)
  assert.match(editor, /:value="ring\.year \|\| ''"/)
  assert.match(preview, /if \(card\.talent\)/)
  assert.match(preview, /if \(card\.rings\[i\]\.id && card\.rings\[i\]\.year > 0\)/)
})