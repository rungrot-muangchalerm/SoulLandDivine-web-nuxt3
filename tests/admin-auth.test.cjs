const { test } = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const vm = require('node:vm')
const ts = require('typescript')
const path = require('node:path')

function middleware(pathname) {
  let sessionCalls = 0
  const module = { exports: {} }
  const source = fs.readFileSync(path.join(__dirname, '../server/middleware/admin-auth.ts'), 'utf8')
  const code = ts.transpileModule(source, {
    compilerOptions: { module: ts.ModuleKind.CommonJS, esModuleInterop: true },
  }).outputText
  vm.runInNewContext(code, {
    module, exports: module.exports,
    require(name) {
      if (name === 'h3') return { getRequestURL: () => ({ pathname }) }
      if (name === '../utils/admin-session') {
        return { getAdminSession: async () => { sessionCalls++ } }
      }
      return require(name)
    },
    defineEventHandler: fn => fn,
  })
  return { request: () => module.exports.default({}), sessionCalls: () => sessionCalls }
}

test('allows the public client config endpoint without an admin session', async () => {
  const api = middleware('/api/client-config')
  await api.request()
  assert.equal(api.sessionCalls(), 0)
})

test('continues requiring an admin session for protected API routes', async () => {
  const api = middleware('/api/admin/users')
  await api.request()
  assert.equal(api.sessionCalls(), 1)
})
