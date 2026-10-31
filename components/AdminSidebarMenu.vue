<script setup lang="ts">
interface MenuEntry {
  title: string
  path?: string
  limit: number | 'admin' | 'server'
  children?: Array<{ title: string; path: string }>
}

const props = defineProps<{
  authorization: string
  mobile?: boolean
}>()

const menu: MenuEntry[] = [
  { title: 'ข้อมูลผู้เล่น', path: '/role', limit: 0 },
  { title: 'หักทรัพยากร', limit: 4, children: [
    { title: 'หักไอเทม', path: '/item' },
    { title: 'หักความคืบหน้าการเติมเงินสะสม', path: '/recharge' },
    { title: 'หักความคืบหน้าการเติมเงินกิจกรรม', path: '/activity' },
  ] },
  { title: 'ประกาศข้อความ', path: '/boradcast', limit: 2 },
  { title: 'ประกาศ', path: '/notice', limit: 'admin' },
  { title: 'ส่งอีเมล', path: '/email', limit: 3 },
  { title: 'เติมเงินย้อนหลัง', path: '/pay', limit: 3 },
  { title: 'คำต้องห้าม', path: '/sensitive', limit: 1 },
  { title: 'เปิดเซิร์ฟเวอร์ด่วน', path: '/server', limit: 'server' },
  { title: 'จัดการรายงาน', path: '/report', limit: 1 },
  { title: 'จัดการของรางวัล', limit: 3, children: [
    { title: 'จัดการระดับรางวัล', path: '/grade' },
    { title: 'จัดการผู้เล่น', path: '/player' },
  ] },
  { title: 'ค้นหาบันทึก', limit: 0, children: [
    { title: 'ค้นหาการใช้ไอเทม', path: '/ItemConsume' },
    { title: 'ค้นหาการได้รับไอเทม', path: '/ItemProduce' },
    { title: 'ค้นหาการใช้สกุลเงิน', path: '/CurrencyConsume' },
    { title: 'ค้นหาการได้รับสกุลเงิน', path: '/CurrencyProduce' },
    { title: 'ประวัติเข้าและออกจากระบบ', path: '/conlog' },
    { title: 'ค้นหาการเติมเงิน', path: '/paylog' },
  ] },
  { title: 'จัดการการตั้งค่า', limit: 'server', children: [{ title: 'จัดการช่องทาง', path: '/channel' }] },
  { title: 'จัดการสิทธิ์', limit: 'admin', children: [
    { title: 'จัดการผู้ใช้', path: '/user' },
    { title: 'ประวัติการดำเนินการ', path: '/operating' },
  ] },
]

const visibleMenu = computed<MenuEntry[]>(() => {
  const role = props.authorization
  if (role === 'admin') return menu
  if (role === 'server') return menu.filter((item) => item.limit === 'server')
  const level = Number(role)
  if (!Number.isFinite(level)) return []
  return menu.filter((item) => typeof item.limit === 'number' && item.limit <= level)
})

const route = useRoute()
const openGroups = ref<Record<string, boolean>>({})

watch(() => route.path, (path: string) => {
  for (const item of visibleMenu.value) {
    if (item.children?.some((child: { title: string; path: string }) => child.path === path)) {
      openGroups.value[item.title] = true
    }
  }
}, { immediate: true })

function isActiveGroup(item: MenuEntry) {
  return item.children?.some((child: { title: string; path: string }) => child.path === route.path) ?? false
}

async function selectRoute(path: string) {
  if (path && path !== route.path) await navigateTo(path)
}
</script>

<template>
  <nav class="nav nav-pills flex-column gap-1 p-2" aria-label="เมนูหลัก">
    <template v-for="item in visibleMenu" :key="item.title">
      <button
        v-if="item.children"
        class="nav-link text-start text-wrap d-flex align-items-center"
        :class="{ 'text-white': openGroups[item.title], active: isActiveGroup(item) }"
        type="button"
        :aria-expanded="Boolean(openGroups[item.title])"
        @click="openGroups[item.title] = !openGroups[item.title]"
      >
        <span>{{ item.title }}</span>
        <span class="ms-auto" aria-hidden="true">{{ openGroups[item.title] ? '⌄' : '›' }}</span>
      </button>
      <div v-if="item.children && openGroups[item.title]" class="ps-3">
        <button
          v-for="child in item.children"
          :key="child.path"
          class="nav-link text-start text-wrap small"
          :class="{ active: route.path === child.path }"
          type="button"
          :data-bs-dismiss="mobile ? 'offcanvas' : undefined"
          @click="selectRoute(child.path)"
        >
          {{ child.title }}
        </button>
      </div>
      <button
        v-if="item.path"
        class="nav-link text-start text-wrap"
        :class="{ active: route.path === item.path }"
        type="button"
        :data-bs-dismiss="mobile ? 'offcanvas' : undefined"
        @click="selectRoute(item.path)"
      >
        {{ item.title }}
      </button>
    </template>
  </nav>
</template>
