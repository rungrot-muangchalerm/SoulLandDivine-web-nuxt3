const { test } = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')
const ts = require('typescript')

const repo = path.join(__dirname, '..')
function loadHelper() {
  const source = fs.readFileSync(path.join(repo, 'server/utils/admin-cookie.ts'), 'utf8')
  const code = ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.CommonJS } }).outputText
  const module = { exports: {} }
  vm.runInNewContext(code, {
    module, exports: module.exports,
    require: (name) => name === 'h3' ? { getRequestProtocol: (event) => event.protocol } : require(name),
  })
  return module.exports.useSecureAdminCookie
}

test('admin cookie is not Secure for HTTP LAN so browsers can use the session', () => {
  assert.equal(loadHelper()({ protocol: 'http' }), false)
})

test('admin cookie remains Secure for HTTPS connections', () => {
  assert.equal(loadHelper()({ protocol: 'https' }), true)
})

test('login and token refresh use the same request-sensitive cookie policy', () => {
  const login = fs.readFileSync(path.join(repo, 'server/api/login.post.ts'), 'utf8')
  const session = fs.readFileSync(path.join(repo, 'server/utils/admin-session.ts'), 'utf8')
  assert.equal((login.match(/secure:\s*useSecureAdminCookie\(event\)/g) || []).length, 2)
  assert.equal((session.match(/secure:\s*useSecureAdminCookie\(event\)/g) || []).length, 1)
})