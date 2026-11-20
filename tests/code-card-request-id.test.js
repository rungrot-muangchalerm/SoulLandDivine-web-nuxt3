import test from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import { createCardRequestId } from '../utils/code-card-request-id.ts'

const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/

test('generates a valid v4 request ID on HTTP when crypto.randomUUID is unavailable', () => {
  const api = {
    getRandomValues(bytes) {
      bytes.set(Array.from({ length: 16 }, (_, i) => i))
      return bytes
    },
  }
  assert.equal(createCardRequestId(api), '00010203-0405-4607-8809-0a0b0c0d0e0f')
})

test('uses native randomUUID when available', () => {
  let fallbackCalled = false
  const native = 'aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee'
  const api = {
    randomUUID: () => native,
    getRandomValues() { fallbackCalled = true; throw Error('not needed') },
  }
  assert.equal(createCardRequestId(api), native)
  assert.equal(fallbackCalled, false)
})

test('uses cryptographic randomness for independent requests', () => {
  let counter = 0
  const api = {
    getRandomValues(bytes) {
      counter++
      bytes.fill(counter)
      return bytes
    },
  }
  const first = createCardRequestId(api)
  const second = createCardRequestId(api)
  assert.match(first, uuidPattern)
  assert.match(second, uuidPattern)
  assert.notEqual(first, second)
})

test('does not fall back to predictable Math.random when browser crypto is missing', () => {
  assert.throws(() => createCardRequestId({}), /secure random/i)
})

test('both card generation pages use the request ID helper', () => {
  for (const path of ['../pages/code-cards/index.vue', '../pages/code-cards/templates.vue']) {
    const page = readFileSync(new URL(path, import.meta.url), 'utf8')
    assert.match(page, /createCardRequestId\(\)/)
    assert.doesNotMatch(page, /crypto\.randomUUID\(\)/)
  }
})