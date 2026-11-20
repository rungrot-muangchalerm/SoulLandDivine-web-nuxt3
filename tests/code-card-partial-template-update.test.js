import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import ts from 'typescript'

const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8')
async function loadTs(source) {
  const js = ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.ESNext } }).outputText
  return import('data:text/javascript;base64,' + Buffer.from(js).toString('base64'))
}
const { validateCard, buildCardRewards } = await loadTs(read('utils/code-card.ts'))
function blank() {
  return { name: 'Partial', heroId: '', talent: '', talentValue: 0, boneAffixes: [],
    equipment: Array.from({ length: 5 }, () => ({ id: '', stars: 0, level: 0 })),
    rings: Array.from({ length: 10 }, () => ({ id: '', year: 0 })) }
}

test('one-field edits can be saved in an incomplete template draft', () => {
  const partial = validateCard({ ...blank(), boneAffixes: ['HP +5%'] })
  assert.equal(partial.name, 'Partial')
  assert.deepEqual(partial.boneAffixes, ['HP +5%'])
  assert.equal(partial.talent, '')
  assert.equal(partial.rings[0].year, 0)
  assert.throws(() => buildCardRewards(partial), /ตัวละคร|equipment|วงแหวน/)
  const another = validateCard({ ...partial, talent: 'body', talentValue: 2 })
  assert.equal(another.talentValue, 2)
})

test('a template with a selected ring but missing its year cannot be issued', () => {
  const draft = blank()
  draft.heroId = '101'
  draft.equipment.forEach((x, i) => { x.id = String(i + 1) })
  draft.rings.forEach((x, i) => { x.id = String(111001 + i) })
  const normalized = validateCard(draft)
  assert.throws(() => buildCardRewards(normalized), /อายุ/)
})

test('actual template POST handler upserts a single changed field under its original ID', async () => {
  globalThis.defineEventHandler = handler => handler
  globalThis.cardAdmin = async () => ({ username: 'tester' })
  globalThis.cardInput = validateCard
  globalThis.readBody = async event => event.body
  globalThis.recordOperationLog = async () => {}
  const database = new Map()
  globalThis.updateCardTemplate = async (id, definition, username) => {
    assert.equal(username, 'tester')
    database.set(id, { name: definition.name, definition })
    return 0
  }

  let source = read('server/api/code-cards/templates.post.ts')
  source = source.replace(/^import \{ (?:cardAdmin|recordOperationLog|getGameDatabase)[^\n]+\n/gm, '')
    .replace(/^import \{ cardAdmin, cardInput, updateCardTemplate \}[^\n]+\n/gm, '')
  const { default: handler } = await loadTs(source)
  const id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'
  const event = definition => ({ body: { id, definition }, node: { req: { socket: { remoteAddress: '127.0.0.1' } } } })
  const result = await handler(event(blank()))
  assert.equal(result.id, id)
  const updated = blank()
  updated.boneAffixes = ['Attack +5']
  const saved = await handler(event(updated))
  assert.equal(saved.id, id)
  assert.equal(database.size, 1)
  assert.deepEqual(database.get(id).definition.boneAffixes, ['Attack +5'])
  assert.equal(database.get(id).definition.heroId, '')
})

test('existing editor templates autosave changed fields, show save feedback and preserve downloads', () => {
  const editor = read('pages/code-cards/templates.vue')
  assert.match(editor, /watch\(definitionJson/)
  assert.match(editor, /queueAutosave\(/)
  assert.match(editor, /setTimeout\(/)
  assert.match(editor, /lastSavedTemplate/)
  assert.match(editor, /autoSaveStatus/)
})
test('bone notes have larger editable space and clearer preview typography', () => {
  const editor = read('pages/code-cards/templates.vue')
  const preview = read('components/CodeCardPreview.vue')
  assert.match(editor, /v-model="affixText" rows="8"/)
  assert.match(editor, /class="form-control bone-affix-notes"/)
  assert.match(editor, /\.bone-affix-notes\s*\{[^}]*min-height:\s*190px/s)
  assert.match(preview, /text\(\x60• \$\{line\}\x60, 498, 349 \+ i \* 32, 26/)
})
