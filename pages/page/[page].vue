<script setup lang="ts">
interface GachaCharacterRate {
  id: number
  name: string
  imageUrl?: string
  quality: number
  ratio: number
  draftRatio: number
}

interface CharacterRatesResponse {
  drawType: number
  characters: Omit<GachaCharacterRate, 'draftRatio'>[]
}

const route = useRoute()
if (route.params.page !== 'gacha-characters') {
  throw createError({ statusCode: 404, statusMessage: 'ไม่พบหน้าที่ต้องการ' })
}
const drawType = computed(() => {
  const value = route.query.drawType
  return typeof value === 'string' ? Number(value) : 0
})
const characters = ref<GachaCharacterRate[]>([])
const search = ref('')
const loading = ref(true)
const savingCharacterId = ref<number | null>(null)
const errorMessage = ref('')
const successMessage = ref('')
let loadGeneration = 0

const visibleCharacters = computed(() => {
  const query = search.value.trim().toLocaleLowerCase()
  if (!query) return characters.value
  return characters.value.filter((character: GachaCharacterRate) =>
    character.name.toLocaleLowerCase().includes(query) || String(character.id).includes(query),
  )
})

function qualityName(quality: number) {
  return ({ 2: 'SSR', 3: 'SR', 4: 'R', 5: 'N' } as Record<number, string>)[quality] || `คุณภาพ ${quality}`
}

async function loadCharacterRates() {
  const generation = ++loadGeneration
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''
  characters.value = []

  if (!Number.isSafeInteger(drawType.value) || drawType.value < 1) {
    errorMessage.value = 'ประเภทตู้กาชาไม่ถูกต้อง'
    loading.value = false
    return
  }

  try {
    const result = await $fetch<CharacterRatesResponse>(
      `/api/gacha/character-rates?drawType=${drawType.value}`,
    )
    if (generation === loadGeneration) {
      characters.value = result.characters.map((character: Omit<GachaCharacterRate, 'draftRatio'>) => ({
        ...character,
        draftRatio: character.ratio,
      }))
    }
  } catch (error) {
    if (generation === loadGeneration) {
      errorMessage.value = error instanceof Error ? error.message : 'โหลดเรทตัวละครไม่สำเร็จ'
    }
  } finally {
    if (generation === loadGeneration) loading.value = false
  }
}

watch(drawType, () => {
  if (import.meta.client) void loadCharacterRates()
})
onMounted(() => {
  void loadCharacterRates()
})

async function saveCharacterRate(character: GachaCharacterRate) {
  if (!Number.isSafeInteger(character.draftRatio) || character.draftRatio < 0 || character.draftRatio > 1_000_000) {
    errorMessage.value = 'เรทตัวละครต้องเป็นจำนวนเต็มระหว่าง 0 ถึง 1000000'
    return
  }
  if (savingCharacterId.value !== null) return

  savingCharacterId.value = character.id
  errorMessage.value = ''
  successMessage.value = ''
  try {
    const result = await $fetch<CharacterRatesResponse & { message: string }>(
      '/api/gacha/character-rates',
      {
        method: 'POST',
        body: { drawType: drawType.value, heroId: character.id, ratio: character.draftRatio },
      },
    )
    characters.value = result.characters.map((item: Omit<GachaCharacterRate, 'draftRatio'>) => {
      const current = characters.value.find((entry: GachaCharacterRate) => entry.id === item.id)
      const ratio = item.id === character.id ? item.ratio : (current?.ratio ?? item.ratio)
      return {
        ...item,
        ratio,
        draftRatio: item.id === character.id ? item.ratio : (current?.draftRatio ?? item.ratio),
      }
    })
    successMessage.value = `${character.name}: ${result.message}`
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'บันทึกเรทตัวละครไม่สำเร็จ'
  } finally {
    savingCharacterId.value = null
  }
}
</script>

<template>
  <section class="container-fluid">
    <div class="d-flex flex-wrap justify-content-between align-items-start gap-3 mb-3">
      <div>
        <NuxtLink to="/gacha" class="btn btn-sm btn-outline-secondary mb-3">← กลับหน้าตู้กาชา</NuxtLink>
        <h1 class="h3 mb-1">จัดการตัวละครในตู้กาชา</h1>
        <p class="text-body-secondary mb-0">
          Type {{ drawType }} · ปรับน้ำหนักสุ่มภายในระดับคุณภาพ ไม่ใช่เปอร์เซ็นต์จริง
        </p>
        <p class="small text-body-secondary mb-0">ตู้ที่ใช้ Type เดียวกันจะใช้เรทชุดเดียวกัน และบันทึกแล้วส่งอัปเดตเข้าเกมอัตโนมัติ</p>
      </div>
      <button class="btn btn-outline-secondary" type="button" :disabled="loading" @click="loadCharacterRates">
        รีเฟรช
      </button>
    </div>

    <div v-if="errorMessage" class="alert alert-danger" role="alert">{{ errorMessage }}</div>
    <div v-if="successMessage" class="alert alert-success" role="status">{{ successMessage }}</div>

    <div class="row align-items-end g-2 mb-3">
      <div class="col-12 col-md-6 col-xl-4">
        <label class="form-label" for="gacha-character-search">ค้นหาชื่อตัวละครหรือ ID</label>
        <input id="gacha-character-search" v-model="search" class="form-control" type="search" placeholder="พิมพ์ชื่อหรือ ID">
      </div>
      <div class="col small text-body-secondary">
        แสดง {{ visibleCharacters.length }} / {{ characters.length }} ตัวละคร
      </div>
    </div>

    <p v-if="loading" class="alert alert-info" role="status">กำลังโหลดเรทตัวละคร...</p>
    <div v-else-if="!visibleCharacters.length" class="alert alert-secondary">
      {{ characters.length ? 'ไม่พบตัวละครที่ตรงกับคำค้นหา' : 'ไม่พบข้อมูลตัวละครในตู้ประเภทนี้' }}
    </div>
    <div v-else class="row g-3">
      <div v-for="character in visibleCharacters" :key="character.id" class="col-12 col-md-6 col-xxl-4">
        <article class="card h-100">
          <div class="card-body d-flex gap-3">
            <img
              v-if="character.imageUrl"
              :src="character.imageUrl"
              :alt="`ภาพตัวละคร ${character.name}`"
              class="gacha-character-image flex-shrink-0"
              loading="lazy"
            >
            <div v-else class="gacha-character-image gacha-character-image-fallback flex-shrink-0" aria-hidden="true">
              {{ character.name.slice(0, 1) }}
            </div>
            <div class="flex-grow-1 min-width-0">
              <div class="d-flex flex-wrap align-items-center gap-2 mb-2">
                <h2 class="h6 mb-0">{{ character.name }}</h2>
                <span class="badge text-bg-secondary">{{ qualityName(character.quality) }}</span>
                <span class="small text-body-secondary">ID {{ character.id }}</span>
              </div>
              <label class="form-label small mb-1" :for="`gacha-rate-${character.id}`">น้ำหนักสุ่ม</label>
              <div class="d-flex gap-2">
                <input
                  :id="`gacha-rate-${character.id}`"
                  v-model.number="character.draftRatio"
                  class="form-control form-control-sm"
                  type="number"
                  min="0"
                  max="1000000"
                  step="1"
                  :aria-label="`น้ำหนักสุ่มของ ${character.name} ID ${character.id}`"
                  :disabled="savingCharacterId !== null"
                >
                <button
                  class="btn btn-sm btn-primary flex-shrink-0"
                  type="button"
                  :disabled="savingCharacterId !== null || character.draftRatio === character.ratio"
                  @click="saveCharacterRate(character)"
                >
                  {{ savingCharacterId === character.id ? 'กำลังบันทึก...' : 'บันทึก' }}
                </button>
              </div>
            </div>
          </div>
        </article>
      </div>
    </div>
  </section>
</template>

<style scoped>
.gacha-character-image {
  width: 76px;
  height: 76px;
  border-radius: 0.5rem;
  object-fit: cover;
  background-color: var(--bs-tertiary-bg);
}

.gacha-character-image-fallback {
  display: grid;
  place-items: center;
  color: var(--bs-secondary-color);
  font-size: 1.5rem;
}

.min-width-0 {
  min-width: 0;
}
</style>
