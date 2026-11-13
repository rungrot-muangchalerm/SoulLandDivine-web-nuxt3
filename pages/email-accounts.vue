<script setup lang="ts">




interface Account { id: number; email: string; contactUrl: string; used: boolean }
const session = ref<{ username: string; authorization: string; channel: string } | null>(null)
const accounts = ref<Account[]>([])
const month = ref('')
const busy = ref(false)
const error = ref('')
const success = ref('')
const revealed = reactive<Record<number, string>>({})
const form = reactive({ id: undefined as number | undefined, email: '', password: '', contactUrl: '' })
const query = ref('')
const statusFilter = ref<'unused' | 'used' | 'all'>('unused')
const usedCount = computed(() => accounts.value.filter((a: Account) => a.used).length)
const filtered = computed(() => accounts.value.filter((a: Account) =>
  (statusFilter.value === 'all' || a.used === (statusFilter.value === 'used'))
  && a.email.toLowerCase().includes(query.value.trim().toLowerCase())))
let timer: ReturnType<typeof setInterval> | undefined
async function load() {
  const data = await $fetch<{ month: string; accounts: Account[] }>('/api/email-accounts')
  month.value = data.month
  accounts.value = data.accounts
}
function clearForm() { form.id = undefined; form.email = ''; form.password = ''; form.contactUrl = '' }
function message(e: any) { return e?.data?.statusMessage || e?.message || 'ดำเนินการไม่สำเร็จ' }
async function run(task: () => Promise<void>) {
  busy.value = true; error.value = ''; success.value = ''
  try { await task() } catch (e) { error.value = message(e) } finally { busy.value = false }
}
async function save() {
  await run(async () => {
    await $fetch('/api/email-accounts', { method: 'POST', body: { action: 'save', ...form } })
    if (form.id) delete revealed[form.id]
    clearForm(); await load(); success.value = 'บันทึกเรียบร้อย'
  })
}
async function toggle(a: Account, event: Event) {
  const input = event.target as HTMLInputElement
  const used = input.checked
  await run(async () => { await $fetch('/api/email-accounts', { method: 'POST', body: { action: 'used', id: a.id, used } }); await load() })
  input.checked = accounts.value.find((row: Account) => row.id === a.id)?.used || false
}
async function reveal(a: Account) {
  if (revealed[a.id] !== undefined) { delete revealed[a.id]; return }
  await run(async () => { const result = await $fetch<{ password: string }>('/api/email-accounts', { method: 'POST', body: { action: 'reveal', id: a.id } }); revealed[a.id] = result.password })
}
async function copyPassword(a: Account) {
  await run(async () => {
    const password = revealed[a.id] ?? (await $fetch<{ password: string }>('/api/email-accounts', {
      method: 'POST', body: { action: 'reveal', id: a.id },
    })).password
    if (!navigator.clipboard?.writeText) throw new Error('เบราว์เซอร์นี้ต้องเปิดเว็บผ่าน HTTPS เพื่อคัดลอกรหัสผ่าน')
    await navigator.clipboard.writeText(password)
    success.value = 'คัดลอกรหัสผ่านแล้ว'
  })
}
async function remove(a: Account) {
  if (!window.confirm(`ลบบัญชี ${a.email} หรือไม่?`)) return
  await run(async () => {
    await $fetch('/api/email-accounts', { method: 'POST', body: { action: 'delete', id: a.id } })
    delete revealed[a.id]; if (form.id === a.id) clearForm(); await load()
  })
}
onMounted(async () => {
  await run(async () => {
    session.value = await $fetch('/api/session')
    if (session.value?.authorization !== 'admin') { await navigateTo('/403'); return }
    await load()
    timer = setInterval(() => { if (!busy.value) load().catch(e => { error.value = message(e) }) }, 30_000)
  })
})
onBeforeUnmount(() => { if (timer) clearInterval(timer) })
</script>

<template>
  <section v-if="session?.authorization === 'admin'">
        <h1 class="h3">บัญชีอีเมลรายเดือน</h1>
        <p class="text-secondary">สถานะใช้แล้วประจำเดือน {{ month }} · เริ่มใหม่ทุกวันที่ 1 เวลา 00:00 น. (เวลาไทย) โดยเก็บบัญชีเดิมไว้</p>
        <div v-if="error" class="alert alert-danger" role="alert">{{ error }}</div>
        <div v-if="success" class="alert alert-success" role="status">{{ success }}</div>
        <form class="card card-body mb-4" @submit.prevent="save">
          <h2 class="h5">{{ form.id ? 'แก้ไขบัญชี' : 'เพิ่มบัญชี' }}</h2>
          <div class="row g-3 align-items-end">
            <div class="col-md-4"><label for="account-email" class="form-label">Email</label><input id="account-email" v-model="form.email" class="form-control" type="email" maxlength="254" required autocomplete="off"></div>
            <div class="col-md-4"><label for="account-password" class="form-label">Password {{ form.id ? '(เว้นว่างเพื่อใช้รหัสเดิม)' : '' }}</label><input id="account-password" v-model="form.password" class="form-control" type="password" maxlength="4096" :required="!form.id" autocomplete="new-password"></div>
            <div class="col-md-4"><label for="account-contact" class="form-label">ลิงก์ติดต่ออื่น (ไม่บังคับ)</label><input id="account-contact" v-model="form.contactUrl" class="form-control" type="url" maxlength="2048" placeholder="https://..." autocomplete="off"></div>
            <div class="col-12 d-flex gap-2"><button class="btn btn-primary" :disabled="busy">บันทึก</button><button v-if="form.id" type="button" class="btn btn-secondary" :disabled="busy" @click="clearForm">ยกเลิก</button></div>
          </div>
        </form>
        <div class="card card-body">
          <div class="d-flex flex-wrap gap-3 align-items-center mb-3">
            <span>ทั้งหมด {{ accounts.length }} · ใช้แล้ว {{ usedCount }}</span>
            <select v-model="statusFilter" class="form-select w-auto" aria-label="กรองสถานะการใช้บัญชี">
              <option value="unused">ยังไม่ได้ใช้</option>
              <option value="used">ใช้แล้ว</option>
              <option value="all">ทั้งหมด</option>
            </select>
            <input v-model="query" type="search" class="form-control ms-auto" style="max-width: 320px" placeholder="ค้นหาอีเมล" aria-label="ค้นหาอีเมล">
          </div>
          <div class="table-responsive"><table class="table align-middle accounts-table">
            <colgroup><col class="email-column"><col class="password-column"><col class="used-column"><col class="actions-column"></colgroup>
            <thead><tr><th>Email</th><th>Password</th><th>ใช้แล้วเดือนนี้</th><th>จัดการ</th></tr></thead>
            <tbody>
              <tr v-for="a in filtered" :key="a.id">
                <td><span class="account-value" :title="a.email">{{ a.email }}</span></td>
                <td><div class="password-cell">
                  <span class="account-value font-monospace">{{ revealed[a.id] ?? '••••••••' }}</span>
                  <div class="password-actions">
                    <button type="button" class="btn btn-sm btn-outline-secondary toggle-password" :disabled="busy" :aria-label="`${revealed[a.id] !== undefined ? 'ซ่อน' : 'แสดง'}รหัสผ่าน ${a.email}`" @click="reveal(a)">{{ revealed[a.id] !== undefined ? 'ซ่อน' : 'แสดง' }}</button>
                    <button type="button" class="btn btn-sm btn-outline-primary" :disabled="busy" :aria-label="`คัดลอกรหัสผ่าน ${a.email}`" @click="copyPassword(a)">คัดลอก</button>
                  </div>
                </div></td>
                <td><input class="form-check-input" type="checkbox" :checked="a.used" :disabled="busy" :aria-label="`ใช้แล้ว ${a.email}`" @change="toggle(a, $event)"></td>
                <td><div class="d-flex flex-wrap gap-2"><a v-if="a.contactUrl" :href="a.contactUrl" class="btn btn-sm btn-outline-info text-nowrap" :title="a.contactUrl" target="_blank" rel="noopener noreferrer">ติดต่อ ↗</a><button class="btn btn-sm btn-outline-primary" :disabled="busy" @click="Object.assign(form, { id: a.id, email: a.email, password: '', contactUrl: a.contactUrl || '' })">แก้ไข</button><button class="btn btn-sm btn-outline-danger" :disabled="busy" @click="remove(a)">ลบ</button></div></td>
              </tr>
              <tr v-if="!filtered.length"><td colspan="4" class="text-center text-secondary py-4">ไม่พบรายการบัญชี</td></tr>
            </tbody>
          </table></div>
        </div>
  </section>
</template>

<style scoped>
.accounts-table { width: 100%; min-width: 860px; table-layout: fixed; }
.email-column { width: 27%; }
.password-column { width: 37%; }
.used-column { width: 12%; }
.actions-column { width: 24%; }
.account-value { display: block; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.password-cell { display: flex; align-items: center; gap: 0.75rem; min-width: 0; }
.password-cell .account-value { flex: 1; }
.password-actions { display: flex; flex: 0 0 auto; align-items: center; gap: 0.375rem; white-space: nowrap; }
.toggle-password { min-width: 3.25rem; }
</style>
