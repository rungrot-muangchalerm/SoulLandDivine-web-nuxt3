<script setup lang="ts">
interface CustomGachaConfig {
  singlePrice: number
  continuousPrice: number
  singleItem: number
  continuousItem: number
  blessingMax: number
  ssrWeight: number
  srWeight: number
  rWeight: number
  nWeight: number
}

const customConfig = ref<CustomGachaConfig | null>(null)
const loading = ref(true)
const saving = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const customConfigFields: { key: keyof CustomGachaConfig, label: string, min: number, max: number }[] = [
  { key: 'singlePrice', label: 'เพชรต่อครั้ง', min: 1, max: 1000000 },
  { key: 'continuousPrice', label: 'เพชรต่อเจ็ดครั้ง', min: 1, max: 1000000 },
  { key: 'singleItem', label: 'ID ตั๋วเดี่ยว (0 = ไม่ใช้)', min: 0, max: 100000000 },
  { key: 'continuousItem', label: 'ID ตั๋วเจ็ดครั้ง (0 = ไม่ใช้)', min: 0, max: 100000000 },
  { key: 'blessingMax', label: 'จำนวนครั้งการันตี SSR (0 = ปิด)', min: 0, max: 10000 },
  { key: 'ssrWeight', label: 'น้ำหนัก SSR', min: 0, max: 1000000 },
  { key: 'srWeight', label: 'น้ำหนัก SR', min: 0, max: 1000000 },
  { key: 'rWeight', label: 'น้ำหนัก R', min: 0, max: 1000000 },
  { key: 'nWeight', label: 'น้ำหนัก N', min: 0, max: 1000000 },
]

async function loadCustomConfig() {
  loading.value = true
  errorMessage.value = ''
  try {
    customConfig.value = await $fetch<CustomGachaConfig>('/api/gacha/custom-config')
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'โหลดกติกาตู้ปรับแต่งไม่สำเร็จ'
  } finally {
    loading.value = false
  }
}

async function saveCustomConfig() {
  if (!customConfig.value || saving.value) return
  saving.value = true
  errorMessage.value = ''
  successMessage.value = ''
  try {
    const result = await $fetch<{ config: CustomGachaConfig, message: string }>('/api/gacha/custom-config', {
      method: 'POST',
      body: customConfig.value,
    })
    customConfig.value = result.config
    successMessage.value = result.message
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'บันทึกกติกาตู้ปรับแต่งไม่สำเร็จ'
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  void loadCustomConfig()
})
</script>

<template>
  <section class="container-fluid">
    <div class="mb-3">
      <NuxtLink to="/gacha" class="btn btn-sm btn-outline-secondary mb-3">← กลับหน้าตู้กาชา</NuxtLink>
      <h1 class="h3 mb-1">ตั้งค่าตู้ปรับแต่ง UP</h1>
      <p class="text-body-secondary mb-0">Type 10000 · ราคา ตั๋ว การันตี และน้ำหนักเรทแยกจากตู้ประเภทอื่น</p>
    </div>

    <div v-if="errorMessage" class="alert alert-danger" role="alert">{{ errorMessage }}</div>
    <div v-if="successMessage" class="alert alert-success" role="status">{{ successMessage }}</div>
    <p v-if="loading" class="alert alert-info" role="status">กำลังโหลดกติกาตู้...</p>

    <form v-else-if="customConfig" class="card" @submit.prevent="saveCustomConfig">
      <div class="card-body">
        <div class="row g-3">
          <div v-for="field in customConfigFields" :key="field.key" class="col-12 col-md-6 col-xl-4">
            <label class="form-label" :for="`custom-${field.key}`">{{ field.label }}</label>
            <input
              :id="`custom-${field.key}`"
              v-model.number="customConfig[field.key]"
              class="form-control"
              type="number"
              :min="field.min"
              :max="field.max"
              step="1"
              :disabled="saving"
            >
          </div>
        </div>
        <p class="small text-body-secondary mt-3 mb-3">
          น้ำหนักระดับคุณภาพหารด้วยผลรวมคือโอกาสสุ่มปกติ ส่วนเรทตัวละครปรับแยกในหน้าจัดการตัวละครและเรท
          การันตีแยกจากเรทปกติ และถ้าใช้ ID ตั๋วเดียวกับตู้อื่นจะใช้จำนวนตั๋วในกระเป๋าร่วมกัน
        </p>
        <button class="btn btn-primary" type="submit" :disabled="saving">
          {{ saving ? 'กำลังบันทึก...' : 'บันทึกกติกาตู้ปรับแต่ง' }}
        </button>
      </div>
    </form>
  </section>
</template>
