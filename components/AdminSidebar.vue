<script setup lang="ts">
import { ElMenu, ElMenuItem, ElSubMenu } from 'element-plus'

const props = defineProps<{
  authorization: string
  collapsed: boolean
}>()

interface MenuEntry {
  title: string
  path?: string
  limit: number | 'admin' | 'server'
  children?: Array<{ title: string; path: string }>
}

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

const visibleMenu = computed(() => {
  const role = props.authorization
  if (role === 'admin') return menu
  if (role === 'server') return menu.filter((item) => item.limit === 'server')
  const level = Number(role)
  if (!Number.isFinite(level)) return []
  return menu.filter((item) => typeof item.limit === 'number' && item.limit <= level)
})

const route = useRoute()
async function selectRoute(path: string) {
  if (path && path !== route.path) await navigateTo(path)
}
</script>

<template>
  <aside class="admin-sidebar" :class="{ collapsed }">
    <el-menu
      :default-active="route.path"
      :collapse="collapsed"
      background-color="#324157"
      text-color="#bfcbd9"
      active-text-color="#20a0ff"
      @select="selectRoute"
    >
      <template v-for="item in visibleMenu" :key="item.title">
        <el-sub-menu v-if="item.children" :index="item.title">
          <template #title><span>{{ item.title }}</span></template>
          <el-menu-item v-for="child in item.children" :key="child.path" :index="child.path">
            {{ child.title }}
          </el-menu-item>
        </el-sub-menu>
        <el-menu-item v-else-if="item.path" :index="item.path">{{ item.title }}</el-menu-item>
      </template>
    </el-menu>
  </aside>
</template>

<style scoped>
.admin-sidebar { position: fixed; top: 70px; bottom: 0; left: 0; z-index: 5; overflow-y: auto; }
.admin-sidebar :deep(.el-menu) { min-height: 100%; border-right: 0; }
.admin-sidebar:not(.collapsed) :deep(.el-menu) { width: 250px; }
.admin-sidebar.collapsed :deep(.el-menu) { width: 64px; }
</style>
