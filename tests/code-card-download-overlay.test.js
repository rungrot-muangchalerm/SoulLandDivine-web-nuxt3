import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8')

test('card preview includes a keyboard-accessible PNG download overlay outside exported canvas', () => {
  const component = read('components/CodeCardPreview.vue')
  assert.match(component, /downloadOverlay\?: boolean/)
  assert.match(component, /v-if="downloadOverlay"/)
  assert.match(component, /class="download-overlay"/)
  assert.match(component, /aria-label="ดาวน์โหลด PNG"/)
  assert.match(component, /@click\.stop="download"/)
  assert.match(component, /<canvas[^>]*ref="canvas"/)
  assert.match(component, /\.download-overlay\s*\{[^}]*position:\s*absolute/s)
  assert.match(component, /\.code-card-preview\s*\{[^}]*position:\s*relative/s)
  assert.match(component, /\.download-overlay:focus-visible/)
})

test('generator and template editor show inline download overlays instead of header buttons', () => {
  for (const file of ['pages/code-cards/index.vue', 'pages/code-cards/templates.vue']) {
    const source = read(file)
    assert.match(source, /<CodeCardPreview[^>]*\bdownload-overlay\b/)
    assert.doesNotMatch(source, /@click="preview\?\.download\(\)"/)
  }
  const archiveItem = read('components/CodeCardArchiveItem.vue')
  assert.doesNotMatch(archiveItem, /\bdownload-overlay\b/)
  assert.match(archiveItem, /@click="downloadCard"/)
})
