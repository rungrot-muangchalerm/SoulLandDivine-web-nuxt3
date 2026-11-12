import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import ts from 'typescript'
const source = readFileSync(new URL('../server/utils/email-vault.ts', import.meta.url), 'utf8')
const js = ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.ESNext } }).outputText
const { monthInBangkok } = await import(`data:text/javascript;base64,${Buffer.from(js).toString('base64')}`)
test('monthly reset uses Bangkok midnight, including year rollover', () => {
  assert.equal(monthInBangkok(new Date('2026-11-30T16:59:59Z')), '2026-11')
  assert.equal(monthInBangkok(new Date('2026-11-30T17:00:00Z')), '2026-12')
  assert.equal(monthInBangkok(new Date('2026-12-31T17:00:00Z')), '2027-01')
})
