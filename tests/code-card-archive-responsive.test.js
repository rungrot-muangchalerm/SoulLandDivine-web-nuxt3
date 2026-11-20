import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const page = readFileSync(new URL('../pages/code-cards/archive.vue', import.meta.url), 'utf8')
const item = readFileSync(new URL('../components/CodeCardArchiveItem.vue', import.meta.url), 'utf8')

test('archive card grid uses available container width instead of viewport breakpoints', () => {
  assert.match(page, /grid-template-columns:\s*repeat\(auto-fit,\s*minmax\(min\(100%,\s*320px\),\s*1fr\)\)/)
  assert.match(page, /min-width:\s*0/)
  assert.doesNotMatch(page, /grid-template-columns:\s*repeat\(3,\s*minmax/)
  assert.match(page, /@container\s*\(max-width:\s*560px\)/)
})

test('archive controls remain usable on small phones without expanding the page', () => {
  assert.match(page, /\.card-tabs\s*\{[^}]*overflow-x:\s*auto/s)
  assert.match(page, /\.issued-actions\s*\{[^}]*flex-wrap:\s*wrap/s)
  assert.match(page, /\.gallery-pagination\s*\{[^}]*min-width:\s*0/s)
  assert.match(page, /@media\s*\(max-width:\s*480px\)/)
  assert.match(page, /:disabled="busy \|\| currentPage <= 1"/)
  assert.match(page, /:disabled="busy \|\| currentPage >= pageCount"/)
})

test('individual cards keep code, name, badge and download controls readable', () => {
  assert.match(item, /\.hero-name\s*\{[^}]*overflow-wrap:\s*anywhere/s)
  assert.match(item, /\.code-line\s*\{[^}]*overflow-wrap:\s*anywhere/s)
  assert.match(item, /\.download-btn\s*\{[^}]*min-height:\s*44px/s)
  assert.match(item, /\.card-status\s*\{[^}]*flex-shrink:\s*0/s)
  assert.match(item, /@media\s*\(max-width:\s*480px\)/)
  assert.match(item, /@click="downloadCard"/)
})