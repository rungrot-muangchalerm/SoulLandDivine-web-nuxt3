const { test } = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const vm = require('node:vm')
const ts = require('typescript')
const defaults = require('../server/config/client-connection.json')

function endpoint() {
  let content = null
  const headers = {}
  const module = { exports: {} }
  const source = fs.readFileSync(require('node:path').join(__dirname, '../server/api/client-config.get.ts'), 'utf8')
  const code = ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.CommonJS, esModuleInterop: true } }).outputText
  vm.runInNewContext(code, {
    module, exports: module.exports, URL,
    require(name) {
      if (name === 'node:fs/promises') return { readFile: async () => {
        if (content === null) throw Object.assign(new Error('Missing'), { code: 'ENOENT' })
        return content
      } }
      if (name === '../config/client-connection.json') return defaults
      if (name === '../utils/client-updates') return { getClientUpdateDirectory: () => '/updates' }
      return require(name)
    },
    defineEventHandler: fn => fn,
    setHeader: (_, key, value) => { headers[key] = value },
    createError: value => Object.assign(new Error(value.statusMessage), value),
  })
  return { request: () => module.exports.default({}), set: value => { content = value }, headers }
}

test('uses defaults when override is missing and disables caching', async () => {
  const api = endpoint()
  assert.equal((await api.request()).loginHost, defaults.loginHost)
  assert.equal(api.headers['cache-control'], 'no-store')
})

test('reads changed IP on the next request and strips unrelated fields', async () => {
  const api = endpoint()
  api.set(JSON.stringify({ ...defaults, loginHost: '192.168.1.10', password: 'must-not-be-public' }))
  const first = await api.request()
  assert.equal(first.loginHost, '192.168.1.10')
  assert.equal(first.password, undefined)
  api.set(JSON.stringify({ ...defaults, loginHost: '192.168.1.11' }))
  assert.equal((await api.request()).loginHost, '192.168.1.11')
})

test('rejects malformed, incomplete or unsafe configs with 503', async () => {
  const api = endpoint()
  for (const invalid of ['{', '{}', 'null', JSON.stringify({ ...defaults, loginPort: 0 }),
    JSON.stringify({ ...defaults, loginHost: 'http://wrong-host' }),
    JSON.stringify({ ...defaults, updateManifestUrl: 'file:///secret' }),
    JSON.stringify({ ...defaults, announcementUrl: 'https://user:password@example.com/' })]) {
    api.set(invalid)
    await assert.rejects(api.request(), error => error.statusCode === 503)
  }
})
