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
test('existing templates autosave single-field changes and keep their existing ID', () => {
  assert.match(editor, /watch\(definitionJson/)
  assert.match(editor, /queueAutosave\(/)
  assert.match(editor, /setTimeout\(/)
  assert.match(editor, /lastSavedTemplate/)
  assert.match(editor, /pendingGeneration = undefined/)
  assert.match(editor, /id: templateId\.value \|\| undefined/)
})
test('bone-affix note is larger in the editor and more legible on the card', () => {
  assert.match(editor, /v-model="affixText" rows="8"/)
  assert.match(editor, /class="form-control bone-affix-notes"/)
  assert.match(editor, /\.bone-affix-notes\s*\{[^}]*min-height:\s*190px/s)
  assert.match(preview, /text\(\x60• \$\{line\}\x60, 498, 349 \+ i \* 32, 26/)
})
