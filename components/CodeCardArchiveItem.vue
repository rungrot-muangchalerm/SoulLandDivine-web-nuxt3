<script setup lang="ts">
import { ref } from 'vue'
import type { CardDefinition } from '~/utils/code-card'

type Asset = { id: string; name: string; iconUrl: string; portraitUrl?: string; backgroundUrl?: string; frameUrl?: string; star?: number; elementIds?: string[] }
type Catalog = { heroes: Asset[]; weapons: Asset[]; equipment: Asset[]; rings: Asset[]; ringElements?: Asset[]; ringFrames?: Array<{ minYear: number; maxYear: number; frameUrl: string }> }
type Issued = { id: string; code: string; status: string; definition: CardDefinition; redeemedUid?: number | null; redeemedAt?: string | null }
defineProps<{ card: Issued; catalog: Catalog }>()
const preview = ref<{ download: () => Promise<void> } | null>(null)
const downloading = ref(false)
async function downloadCard() {
  if (downloading.value) return
  downloading.value = true
  try {
    await preview.value?.download()
  } finally {
    downloading.value = false
  }
}
</script>
<template>
  <article class="archive-card">
    <div class="artwork">
      <CodeCardPreview ref="preview" :definition="card.definition" :code="card.code" :catalog="catalog" />
    </div>
    <div class="archive-card-info">
      <div class="archive-card-heading">
        <strong class="hero-name">{{ card.definition.name }}</strong>
        <span class="card-status" :class="{ redeemed: card.status === 'used' }">{{ card.status === 'used' ? 'ใช้แล้ว' : 'พร้อมใช้' }}</span>
      </div>
      <div class="code-line">{{ card.code }}</div>
      <p v-if="card.status === 'used' && card.redeemedUid" class="redeemer">ผู้รับ: {{ card.redeemedUid }}</p>
      <button type="button" class="download-btn" :disabled="downloading" :aria-label="'ดาวน์โหลดบัตร ' + card.code" @click="downloadCard">
        <i class="fa-solid fa-download" aria-hidden="true"></i>
        {{ downloading ? 'กำลังเตรียม PNG…' : 'ดาวน์โหลดบัตร PNG' }}
      </button>
    </div>
  </article>
</template>
<style scoped>
.archive-card { min-width:0; background:#102031; border:1px solid #344c62; border-radius:13px; overflow:hidden; box-shadow:0 8px 22px #0002; }
.artwork { padding:9px; background:#0c1826; }
.archive-card-info { padding:13px 14px 15px; }
.archive-card-heading { display:flex; justify-content:space-between; align-items:center; gap:8px; }
.hero-name { color:#eed39a; overflow:hidden; white-space:nowrap; text-overflow:ellipsis; }
.card-status { font-size:.75rem; padding:3px 8px; border-radius:50px; color:#94efd0; background:#173b35; white-space:nowrap; }
.card-status.redeemed { color:#b5bfcb; background:#303947; }
.code-line { font:600 .91rem ui-monospace,Consolas,monospace; color:#e4eaf0; margin-top:9px; overflow-wrap:anywhere; }
.redeemer { font-size:.78rem; color:#a9b7c6; margin:5px 0 0; }
.download-btn { display:block; width:100%; margin-top:13px; border:1px solid #c5a76b; border-radius:8px; background:#40351f; color:#f5d99e; padding:10px 12px; font-weight:600; }
.download-btn:disabled { cursor:wait; opacity:.65; }
.download-btn:not(:disabled):hover { background:#584826; }
.download-btn:focus-visible { outline:2px solid #9cd9ff; outline-offset:2px; }
</style>
