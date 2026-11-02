<script setup lang="ts">
interface GachaPool {
  id: number
  type: string
  name: string
  beginTime: string
  endTime: string
  active: boolean
  imageUrl?: string
}

interface GachaCharacterRate {
  id: number
  name: string
  quality: number
  ratio: number
  draftRatio: number
}

interface CharacterRatePanel {
  open: boolean
  loaded: boolean
  loading: boolean
  characters: GachaCharacterRate[]
}

const pools = ref<GachaPool[]>([])
const endTimes = ref<Record<number, string>>({})
const savingPoolId = ref<number | null>(null)
const characterRatePanels = ref<Record<number, CharacterRatePanel>>({})
const savingCharacterKey = ref<string | null>(null)
const loading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

function toInputDateTime(value: string) {
  const match = /^(\d{4})-(\d{1,2})-(\d{1,2})[ T](\d{1,2}):(\d{1,2})(?::\d{1,2})?$/.exec(value)
  if (!match) return ''
  const [, year, month, day, hour, minute] = match
  return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}T${hour.padStart(2, '0')}:${minute.padStart(2, '0')}`
}

function defaultEndTime() {
  const tomorrow = new Date()
  tomorrow.setDate(tomorrow.getDate() + 1)
  tomorrow.setMinutes(0, 0, 0)
  const pad = (part: number) => String(part).padStart(2, '0')
  return `${tomorrow.getFullYear()}-${pad(tomorrow.getMonth() + 1)}-${pad(tomorrow.getDate())}T${pad(tomorrow.getHours())}:${pad(tomorrow.getMinutes())}`
}

function setPools(value: GachaPool[]) {
  pools.value = value
  endTimes.value = Object.fromEntries(value.map((pool) => {
    const configuredEndTime = toInputDateTime(pool.endTime)
    return [
      pool.id,
      configuredEndTime && new Date(configuredEndTime) > new Date()
        ? configuredEndTime
        : defaultEndTime(),
    ]
  }))
}

async function loadSchedule() {
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''
  try {
    setPools(await $fetch<GachaPool[]>('/api/gacha/rate-up'))
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'โหลดข้อมูลตู้กาชาไม่สำเร็จ'
  } finally {
    loading.value = false
  }
}

async function changeSchedule(pool: GachaPool, action: 'open' | 'close') {
  if (action === 'close' && !window.confirm(`ยืนยันปิดตู้ "${pool.name}" (ID ${pool.id}) ทันทีหรือไม่?`)) return false

  savingPoolId.value = pool.id
  errorMessage.value = ''
  successMessage.value = ''
  try {
    const result = await $fetch<GachaPool & { message: string }>('/api/gacha/rate-up', {
      method: 'POST',
      body: {
        poolId: pool.id,
        action,
        ...(action === 'open' ? { endTime: endTimes.value[pool.id] } : {}),
      },
    })
    pools.value = pools.value.map((item: GachaPool) => item.id === result.id ? result : item)
    successMessage.value = `${result.name}: ${result.message}`
    return true
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'บันทึกการตั้งค่าตู้กาชาไม่สำเร็จ'
    return false
  } finally {
    savingPoolId.value = null
  }
}

async function togglePool(pool: GachaPool, event: Event) {
  const checkbox = event.target
  if (!(checkbox instanceof HTMLInputElement)) return

  const action = checkbox.checked ? 'open' : 'close'
  if (action === 'open' && !endTimes.value[pool.id]) {
    errorMessage.value = 'กรุณากำหนดเวลาปิดตู้ก่อนเปิด'
    checkbox.checked = false
    return
  }
  if (!await changeSchedule(pool, action)) {
    checkbox.checked = pool.active
  }
}

function getCharacterRatePanel(pool: GachaPool) {
  return characterRatePanels.value[Number(pool.type)]
}

async function toggleCharacterRates(pool: GachaPool) {
  const drawType = Number(pool.type)
  if (!Number.isSafeInteger(drawType) || drawType < 1) {
    errorMessage.value = 'ข้อมูลประเภทตู้กาชาไม่ถูกต้อง'
    return
  }

  const panel = characterRatePanels.value[drawType] ??= {
    open: false,
    loaded: false,
    loading: false,
    characters: [],
  }
  panel.open = !panel.open
  if (!panel.open || panel.loaded) return

  panel.loading = true
  errorMessage.value = ''
  try {
    const result = await $fetch<{ characters: Omit<GachaCharacterRate, 'draftRatio'>[] }>(
      `/api/gacha/character-rates?drawType=${drawType}`,
    )
    panel.characters = result.characters.map((character: Omit<GachaCharacterRate, 'draftRatio'>) => ({
      ...character,
      draftRatio: character.ratio,
    }))
    panel.loaded = true
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'โหลดเรทตัวละครไม่สำเร็จ'
    panel.open = false
  } finally {
    panel.loading = false
  }
}

function qualityName(quality: number) {
  return ({ 2: 'SSR', 3: 'SR', 4: 'R', 5: 'N' } as Record<number, string>)[quality] || `คุณภาพ ${quality}`
}

async function saveCharacterRate(pool: GachaPool, character: GachaCharacterRate) {
  const drawType = Number(pool.type)
  if (!Number.isSafeInteger(character.draftRatio) || character.draftRatio < 0 || character.draftRatio > 1_000_000) {
    errorMessage.value = 'เรทตัวละครต้องเป็นจำนวนเต็มระหว่าง 0 ถึง 1000000'
    return
  }
  if (savingCharacterKey.value !== null) return
  if (
    character.draftRatio === 0
    && character.ratio > 0
    && !window.confirm(`ยืนยันตั้งเรทของ ${character.name} (ID ${character.id}) เป็น 0 หรือไม่? ตัวละครนี้จะไม่ถูกสุ่มจากตู้ประเภท ${drawType}`)
  ) return

  savingCharacterKey.value = `${drawType}:${character.id}`
  errorMessage.value = ''
  successMessage.value = ''
  try {
    const result = await $fetch<{ characters: Omit<GachaCharacterRate, 'draftRatio'>[], message: string }>(
      '/api/gacha/character-rates',
      {
        method: 'POST',
        body: { drawType, heroId: character.id, ratio: character.draftRatio },
      },
    )
    const panel = characterRatePanels.value[drawType]
    panel.characters = result.characters.map((item: Omit<GachaCharacterRate, 'draftRatio'>) => {
      const current = panel.characters.find((entry: GachaCharacterRate) => entry.id === item.id)
      const ratio = item.id === character.id ? item.ratio : (current?.ratio ?? item.ratio)
      return { ...item, ratio, draftRatio: item.id === character.id ? item.ratio : (current?.draftRatio ?? item.ratio) }
    })
    successMessage.value = `${character.name}: ${result.message}`
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'บันทึกเรทตัวละครไม่สำเร็จ'
  } finally {
    savingCharacterKey.value = null
  }
}

onMounted(loadSchedule)
</script>

<template>
  <section class="container-fluid">
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
      <div>
        <h1 class="h3 mb-1">จัดการตู้กาชาเรทอัพ</h1>
        <p class="text-body-secondary mb-0">ติ๊กช่องเพื่อเปิดตู้ทันที โดยตู้จะปิดตามเวลาที่กำหนด</p>
      </div>
      <button class="btn btn-outline-secondary" type="button" :disabled="loading || savingPoolId !== null" @click="loadSchedule">
        รีเฟรช
      </button>
    </div>

    <div v-if="errorMessage" class="alert alert-danger" role="alert">
      {{ errorMessage }}
    </div>
    <div v-if="successMessage" class="alert alert-success" role="status">
      {{ successMessage }}
    </div>

    <p v-if="loading" class="mb-0" role="status">กำลังโหลดข้อมูล...</p>
    <div v-else-if="pools.length" class="row g-3">
      <div v-for="pool in pools" :key="pool.id" class="col-12 col-xl-6">
        <article class="card h-100">
          <img
            v-if="pool.imageUrl"
            :src="pool.imageUrl"
            :alt="`ภาพตู้ ${pool.name}`"
            class="card-img-top gacha-pool-image"
            loading="lazy"
          >
          <div class="card-body">
            <div class="d-flex flex-wrap justify-content-between align-items-start gap-2 mb-3">
              <div>
                <h2 class="h5 mb-1">{{ pool.name }}</h2>
                <div class="small text-body-secondary">ID {{ pool.id }} · Type {{ pool.type }}</div>
              </div>
              <div class="form-check form-switch">
                <input
                  :id="`gacha-active-${pool.id}`"
                  class="form-check-input"
                  type="checkbox"
                  role="switch"
                  :checked="pool.active"
                  :disabled="savingPoolId !== null"
                  @change="togglePool(pool, $event)"
                >
                <label class="form-check-label" :for="`gacha-active-${pool.id}`">
                  {{ pool.active ? 'เปิดอยู่' : 'เปิดตู้ทันที' }}
                </label>
              </div>
            </div>

            <dl class="small mb-3 gacha-pool-schedule">
              <div>
                <dt>เวลาเริ่ม</dt>
                <dd>{{ pool.beginTime || 'ไม่ได้กำหนด' }}</dd>
              </div>
              <div>
                <dt>เวลาปิด</dt>
                <dd>{{ pool.endTime || 'ไม่ได้กำหนด' }}</dd>
              </div>
            </dl>

            <div class="border-top pt-3">
              <button
                class="btn btn-sm btn-outline-primary"
                type="button"
                :aria-expanded="getCharacterRatePanel(pool)?.open || false"
                :disabled="getCharacterRatePanel(pool)?.loading || savingPoolId !== null"
                @click="toggleCharacterRates(pool)"
              >
                {{ getCharacterRatePanel(pool)?.open ? 'ซ่อนเรทตัวละคร' : 'ปรับเรทตัวละคร' }}
              </button>
              <div v-if="getCharacterRatePanel(pool)?.open" class="mt-3">
                <p class="small text-body-secondary mb-2">
                  Type {{ pool.type }} · น้ำหนักสุ่มภายในระดับคุณภาพ ไม่ใช่เปอร์เซ็นต์จริง
                </p>
                <p class="small text-body-secondary mb-2">
                  ตู้ที่ใช้ Type เดียวกันจะใช้เรทชุดเดียวกัน
                </p>
                <p class="small text-body-secondary mb-2">
                  ค่าที่บันทึกจะมีผลเมื่อ Game Server โหลด config ใหม่
                </p>
                <p v-if="getCharacterRatePanel(pool)?.loading" class="small mb-0" role="status">
                  กำลังโหลดเรทตัวละคร...
                </p>
                <div v-else class="table-responsive">
                  <table class="table table-sm align-middle mb-0">
                    <thead>
                      <tr>
                        <th scope="col">ตัวละคร</th>
                        <th scope="col">คุณภาพ</th>
                        <th scope="col">น้ำหนัก</th>
                        <th scope="col"><span class="visually-hidden">บันทึก</span></th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="character in getCharacterRatePanel(pool)?.characters" :key="character.id">
                        <td>
                          {{ character.name }}
                          <span class="text-body-secondary">#{{ character.id }}</span>
                        </td>
                        <td>{{ qualityName(character.quality) }}</td>
                        <td>
                          <input
                            v-model.number="character.draftRatio"
                            class="form-control form-control-sm gacha-rate-input"
                            type="number"
                            min="0"
                            max="1000000"
                            step="1"
                            :aria-label="`น้ำหนักสุ่มของ ${character.name} ID ${character.id}`"
                            :disabled="savingCharacterKey !== null"
                          >
                        </td>
                        <td>
                          <button
                            class="btn btn-sm btn-primary"
                            type="button"
                            :disabled="savingCharacterKey !== null || character.draftRatio === character.ratio"
                            @click="saveCharacterRate(pool, character)"
                          >
                            {{ savingCharacterKey === `${pool.type}:${character.id}` ? 'กำลังบันทึก...' : 'บันทึก' }}
                          </button>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>

            <div v-if="!pool.active" class="row align-items-end g-2">
              <div class="col">
                <label class="form-label" :for="`gacha-end-time-${pool.id}`">กำหนดเวลาปิดหลังเปิด</label>
                <input
                  :id="`gacha-end-time-${pool.id}`"
                  v-model="endTimes[pool.id]"
                  class="form-control"
                  type="datetime-local"
                  :disabled="savingPoolId !== null"
                  required
                >
                <div class="form-text">เมื่อเปิดแล้ว ตู้จะเริ่มทำงานทันที</div>
              </div>
            </div>
          </div>
        </article>
      </div>
    </div>
    <div v-else-if="!loading" class="alert alert-info">
      ไม่พบรายการตู้กาชาใน DrawTime.xml
    </div>
  </section>
</template>

<style scoped>
.gacha-pool-schedule > div {
  display: flex;
  gap: 0.5rem;
}

.gacha-pool-schedule dt,
.gacha-pool-schedule dd {
  margin: 0;
}

.gacha-pool-schedule > div + div {
  margin-top: 0.25rem;
}

.gacha-rate-input {
  min-width: 6rem;
  width: 7rem;
}

.gacha-pool-image {
  aspect-ratio: 16 / 9;
  object-fit: cover;
  background-color: var(--bs-tertiary-bg);
}
</style>
