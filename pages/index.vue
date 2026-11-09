<script setup lang="ts">
definePageMeta({ layout: false })
const siteTitle = 'SoulLand Divine | ดาวน์โหลดเกม'
const siteDescription = 'ดาวน์โหลด SoulLand Divine สำหรับ Windows และ Android'
const siteUrl = 'https://soul-land-advent-of-the-gods.aoatheallrandom.com/'
const ogImage = `${siteUrl}og-image.png`

useSeoMeta({
  title: siteTitle,
  description: siteDescription,
  ogTitle: siteTitle,
  ogDescription: siteDescription,
  ogType: 'website',
  ogUrl: siteUrl,
  ogImage,
  ogImageWidth: '1200',
  ogImageHeight: '630',
  ogImageAlt: 'SoulLand Divine - ดาวน์โหลดเกม',
  ogLocale: 'th_TH',
  twitterCard: 'summary_large_image',
  twitterTitle: siteTitle,
  twitterDescription: siteDescription,
  twitterImage: ogImage,
})
useHead({
  link: [{ rel: 'canonical', href: siteUrl }],
})

interface UpdateManifest {
  platform: 'windows' | 'android'
  version: string
  releaseNotes: string
  downloadPath: string
}

interface PlatformRelease {
  manifest: UpdateManifest | null
  error: string | null
}

function getStatusCode(error: unknown) {
  if (typeof error !== 'object' || error === null) return undefined
  if ('statusCode' in error && typeof error.statusCode === 'number') return error.statusCode
  if ('status' in error && typeof error.status === 'number') return error.status
  return undefined
}

async function loadRelease(platform: UpdateManifest['platform']): Promise<PlatformRelease> {
  try {
    const manifest = await $fetch<UpdateManifest>('/api/client-update/manifest', {
      query: { platform },
    })
    return { manifest, error: null }
  } catch (error) {
    if (getStatusCode(error) === 404) {
      return { manifest: null, error: null }
    }
    return { manifest: null, error: 'โหลดข้อมูลเวอร์ชันไม่สำเร็จ กรุณาลองใหม่ภายหลัง' }
  }
}

const { data: releases, pending } = await useAsyncData('public-client-downloads', async () => {
  const [windows, android] = await Promise.all([
    loadRelease('windows'),
    loadRelease('android'),
  ])
  return { windows, android }
})
</script>

<template>
  <div class="download-page">
    <header class="download-navbar">
      <a class="download-brand" href="/" aria-label="SoulLand Divine - หน้าหลัก">
        <span class="download-brand-mark">SD</span>
        <span>SOULLAND <strong>DIVINE</strong></span>
      </a>
      <a class="admin-login-link" href="/login">
        <i class="fa-solid fa-shield-halved" aria-hidden="true"></i>
        เข้าสู่ระบบแอดมิน
      </a>
    </header>

    <main>
      <section id="downloads" class="landing-section">
        <div class="hero-orb hero-orb-one"></div>
        <div class="hero-orb hero-orb-two"></div>
        <div class="hero-decoration" aria-hidden="true">
          <div class="rune rune-one"></div>
          <div class="rune rune-two"></div>
          <div class="rune rune-three"></div>
          <div class="hero-sigil"><span>魂</span></div>
        </div>
        <div class="landing-layout">
          <div class="hero-content">
            <span class="eyebrow"><span class="eyebrow-dot"></span> ENTER THE WORLD</span>
            <h1>การผจญภัยครั้งใหม่<br><span>เริ่มต้นที่นี่</span></h1>
            <p>ดาวน์โหลด SoulLand Divine แล้วออกเดินทางไปพร้อมกับเหล่าวิญญาจารย์</p>
          </div>

          <div class="download-content">
            <div class="section-heading">
              <span class="eyebrow">DOWNLOAD THE GAME</span>
              <h2>เลือกแพลตฟอร์มของคุณ</h2>
              <p>ดาวน์โหลดตัวติดตั้งเวอร์ชันล่าสุด</p>
            </div>

            <div v-if="pending" class="release-message" role="status">
              <span class="spinner-border spinner-border-sm" aria-hidden="true"></span>
              กำลังตรวจสอบเวอร์ชันล่าสุด...
            </div>

            <div v-else class="platform-grid">
              <article class="platform-card">
                <div class="platform-icon windows-icon">
                  <i class="fa-brands fa-windows" aria-hidden="true"></i>
                </div>
                <div class="platform-copy">
                  <span class="platform-kicker">DESKTOP</span>
                  <h3>Windows</h3>
                  <p>ติดตั้งเกมบนคอมพิวเตอร์ Windows</p>
                </div>
                <div v-if="releases?.windows.error" class="release-error" role="alert">
                  {{ releases.windows.error }}
                </div>
                <div v-else-if="releases?.windows.manifest" class="release-meta">
                  <span>เวอร์ชัน {{ releases.windows.manifest.version }}</span>
                  <p v-if="releases.windows.manifest.releaseNotes">{{ releases.windows.manifest.releaseNotes }}</p>
                </div>
                <p v-else class="release-unavailable">ยังไม่มีไฟล์ดาวน์โหลดในขณะนี้</p>
                <a
                  v-if="releases?.windows.manifest"
                  class="download-button"
                  :href="releases.windows.manifest.downloadPath"
                >
                  ดาวน์โหลดสำหรับ Windows
                  <i class="fa-solid fa-download" aria-hidden="true"></i>
                </a>
                <span v-else class="download-button disabled" aria-disabled="true">ยังไม่พร้อมให้ดาวน์โหลด</span>
                <small class="platform-note">Windows 10 ขึ้นไป · Installer</small>
              </article>

              <article class="platform-card">
                <div class="platform-icon android-icon">
                  <i class="fa-brands fa-android" aria-hidden="true"></i>
                </div>
                <div class="platform-copy">
                  <span class="platform-kicker">MOBILE</span>
                  <h3>Android</h3>
                  <p>ติดตั้งเกมบนโทรศัพท์หรือแท็บเล็ต Android</p>
                </div>
                <div v-if="releases?.android.error" class="release-error" role="alert">
                  {{ releases.android.error }}
                </div>
                <div v-else-if="releases?.android.manifest" class="release-meta">
                  <span>เวอร์ชัน {{ releases.android.manifest.version }}</span>
                  <p v-if="releases.android.manifest.releaseNotes">{{ releases.android.manifest.releaseNotes }}</p>
                </div>
                <p v-else class="release-unavailable">ยังไม่มีไฟล์ดาวน์โหลดในขณะนี้</p>
                <a
                  v-if="releases?.android.manifest"
                  class="download-button"
                  :href="releases.android.manifest.downloadPath"
                >
                  ดาวน์โหลดสำหรับ Android
                  <i class="fa-solid fa-download" aria-hidden="true"></i>
                </a>
                <span v-else class="download-button disabled" aria-disabled="true">ยังไม่พร้อมให้ดาวน์โหลด</span>
                <small class="platform-note">ไฟล์ APK · อาจต้องอนุญาตติดตั้งจากแหล่งนี้</small>
              </article>
            </div>
            <p class="download-footnote">
              ดาวน์โหลดไม่ได้หรือพบปัญหาในการติดตั้ง? โปรดตรวจสอบการเชื่อมต่อและพื้นที่ว่างของอุปกรณ์
            </p>
          </div>
        </div>
        <div class="hero-bottom-glow"></div>
      </section>
    </main>

    <footer class="download-footer">
      <span>© SoulLand Divine</span>
      <a href="/login">สำหรับผู้ดูแลระบบ</a>
    </footer>
  </div>
</template>

<style scoped>
.download-page {
  --page-bg: #080d18;
  --panel-bg: #111a2b;
  --muted: #9daac0;
  --accent: #73e0d1;
  min-height: 100vh;
  color: #f3f6fc;
  background: var(--page-bg);
  font-family: Inter, "Noto Sans Thai", system-ui, sans-serif;
}

.download-navbar {
  position: relative;
  z-index: 2;
  display: flex;
  min-height: 76px;
  align-items: center;
  justify-content: space-between;
  padding: 0 clamp(20px, 7vw, 104px);
  border-bottom: 1px solid rgb(255 255 255 / 8%);
  background: #080d18;
}

.download-brand {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  color: #f3f6fc;
  font-size: 13px;
  font-weight: 500;
  letter-spacing: 0.15em;
  text-decoration: none;
}

.download-brand strong { color: var(--accent); font-weight: 700; }
.download-brand-mark {
  display: grid;
  width: 38px;
  height: 38px;
  place-items: center;
  border: 1px solid rgb(115 224 209 / 55%);
  border-radius: 12px;
  color: var(--accent);
  font-weight: 700;
  letter-spacing: 0;
}

.admin-login-link {
  display: inline-flex;
  align-items: center;
  gap: 9px;
  padding: 10px 15px;
  border: 1px solid rgb(255 255 255 / 15%);
  border-radius: 8px;
  color: #d7dfec;
  font-size: 13px;
  text-decoration: none;
  transition: border-color 160ms ease, color 160ms ease;
}
.admin-login-link:hover { border-color: var(--accent); color: var(--accent); }

.landing-section {
  position: relative;
  display: grid;
  min-height: calc(100vh - 142px);
  align-items: center;
  overflow: hidden;
  padding: 52px clamp(24px, 7vw, 104px);
  isolation: isolate;
  background:
    radial-gradient(ellipse at 75% 48%, rgb(31 77 99 / 34%), transparent 36%),
    linear-gradient(112deg, #0d1728 0%, #111c30 48%, #10182a 100%);
}

.landing-layout {
  position: relative;
  z-index: 1;
  display: grid;
  width: min(100%, 1320px);
  grid-template-columns: minmax(0, 0.85fr) minmax(0, 1.15fr);
  align-items: center;
  gap: clamp(32px, 5vw, 76px);
  margin: 0 auto;
}
.hero-content { position: relative; z-index: 1; max-width: 520px; }
.eyebrow {
  display: inline-flex;
  align-items: center;
  gap: 9px;
  color: var(--accent);
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.2em;
}
.eyebrow-dot { width: 7px; height: 7px; border-radius: 50%; background: var(--accent); box-shadow: 0 0 14px var(--accent); }
.landing-section h1 {
  margin: 18px 0 14px;
  font-size: clamp(38px, 6vw, 68px);
  font-weight: 750;
  letter-spacing: -0.045em;
  line-height: 1.2;
}
.landing-section h1 span { color: var(--accent); }
.hero-content p { max-width: 460px; margin: 0; color: #b6c1d2; font-size: 16px; line-height: 1.8; }
.download-content { position: relative; z-index: 1; }

.hero-orb { position: absolute; z-index: -1; border: 1px solid rgb(115 224 209 / 10%); border-radius: 50%; }
.hero-orb-one { width: 460px; height: 460px; top: -190px; right: 12%; }
.hero-orb-two { width: 620px; height: 620px; top: -270px; right: 5%; }
.hero-decoration { position: absolute; top: 0; right: 8%; width: 360px; height: 100%; opacity: 0.75; }
.hero-sigil {
  position: absolute;
  top: 50%;
  left: 50%;
  display: grid;
  width: 148px;
  height: 148px;
  place-items: center;
  transform: translate(-50%, -50%) rotate(45deg);
  border: 1px solid rgb(115 224 209 / 50%);
  box-shadow: 0 0 70px rgb(74 192 179 / 20%), inset 0 0 35px rgb(74 192 179 / 8%);
}
.hero-sigil::before, .hero-sigil::after { position: absolute; content: ""; border: 1px solid rgb(115 224 209 / 20%); }
.hero-sigil::before { inset: 13px; }
.hero-sigil::after { inset: -18px; transform: rotate(45deg); }
.hero-sigil span { transform: rotate(-45deg); color: var(--accent); font-size: 58px; font-family: serif; }
.rune { position: absolute; width: 5px; height: 5px; border-radius: 50%; background: var(--accent); box-shadow: 0 0 14px var(--accent); }
.rune-one { top: 25%; left: 17%; }
.rune-two { top: 69%; left: 20%; }
.rune-three { top: 33%; right: 10%; }
.hero-bottom-glow { position: absolute; right: 0; bottom: -90px; left: 0; height: 120px; background: linear-gradient(transparent, var(--page-bg)); }

.section-heading { margin-bottom: 22px; }
.section-heading h2 { margin: 10px 0 6px; font-size: clamp(22px, 2.4vw, 30px); font-weight: 700; letter-spacing: -0.03em; }
.section-heading p { margin: 0; color: var(--muted); font-size: 13px; }
.platform-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px; }
.platform-card {
  display: flex;
  min-height: 290px;
  flex-direction: column;
  align-items: flex-start;
  padding: 21px;
  border: 1px solid rgb(255 255 255 / 9%);
  border-radius: 14px;
  background: linear-gradient(145deg, #121d30, #0e1625);
  box-shadow: 0 18px 45px rgb(0 0 0 / 12%);
}
.platform-icon { display: grid; width: 52px; height: 52px; place-items: center; border-radius: 12px; font-size: 25px; }
.windows-icon { color: #69baff; background: rgb(64 157 226 / 12%); }
.android-icon { color: #8add8c; background: rgb(111 202 118 / 12%); }
.platform-copy { margin-top: 14px; }
.platform-kicker { color: var(--muted); font-size: 10px; font-weight: 700; letter-spacing: 0.18em; }
.platform-copy h3 { margin: 4px 0 5px; font-size: 24px; font-weight: 700; }
.platform-copy p { margin: 0; color: #b0bdcf; font-size: 13px; }
.release-meta { width: 100%; margin-top: 18px; color: var(--accent); font-size: 12px; font-weight: 650; }
.release-meta p { margin: 7px 0 0; color: var(--muted); font-size: 12px; font-weight: 400; white-space: pre-line; }
.release-unavailable, .release-error { margin: 18px 0 0; color: var(--muted); font-size: 12px; }
.release-error { color: #ff9a9a; }
.download-button {
  display: flex;
  width: 100%;
  min-height: 46px;
  align-items: center;
  justify-content: center;
  gap: 10px;
  margin-top: auto;
  padding: 11px 15px;
  border: 1px solid var(--accent);
  border-radius: 8px;
  color: #071411;
  background: var(--accent);
  font-size: 13px;
  font-weight: 700;
  text-align: center;
  text-decoration: none;
  transition: background 160ms ease, transform 160ms ease;
}
a.download-button:hover { transform: translateY(-1px); color: #071411; background: #8af0e2; }
.download-button.disabled { border-color: rgb(255 255 255 / 10%); color: #8591a4; background: rgb(255 255 255 / 4%); cursor: not-allowed; }
.platform-note { margin-top: 11px; color: #8290a5; font-size: 10px; }
.release-message { display: flex; min-height: 200px; align-items: center; justify-content: center; gap: 12px; color: var(--muted); }
.download-footnote { margin: 16px 0 0; color: #7f8da2; font-size: 11px; }
.download-footer { display: flex; justify-content: space-between; padding: 22px clamp(20px, 7vw, 104px); border-top: 1px solid rgb(255 255 255 / 8%); color: #8290a5; font-size: 12px; }
.download-footer a { color: #aab6c8; text-decoration: none; }
.download-footer a:hover { color: var(--accent); }

@media (max-width: 700px) {
  .download-navbar { min-height: 66px; padding: 0 17px; }
  .download-brand { gap: 8px; font-size: 10px; letter-spacing: 0.1em; }
  .download-brand-mark { width: 34px; height: 34px; }
  .admin-login-link { gap: 7px; padding: 9px 10px; font-size: 11px; }
  .landing-section { min-height: calc(100vh - 132px); padding: 42px 20px; }
  .landing-layout { grid-template-columns: 1fr; gap: 32px; }
  .hero-decoration { right: -210px; opacity: 0.32; }
  .landing-section h1 { margin: 12px 0 10px; font-size: clamp(36px, 10vw, 54px); }
  .hero-content p { max-width: 370px; font-size: 14px; }
  .platform-grid { grid-template-columns: 1fr 1fr; gap: 10px; }
  .platform-card { min-height: 300px; padding: 16px; }
  .platform-copy h3 { font-size: 20px; }
  .platform-copy p { font-size: 11px; }
  .download-button { font-size: 11px; }
  .platform-note { font-size: 9px; }
  .download-footer { padding: 20px 18px; }
}

@media (max-width: 420px) {
  .platform-grid { grid-template-columns: 1fr; }
  .platform-card { min-height: 260px; }
}

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { scroll-behavior: auto !important; transition-duration: 0.01ms !important; }
}
</style>
