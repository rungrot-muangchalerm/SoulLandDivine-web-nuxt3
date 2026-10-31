const publicPaths = new Set(['/login', '/403', '/404'])

export default defineNuxtRouteMiddleware(async (to) => {
  if (publicPaths.has(to.path)) return

  const { error } = await useFetch('/api/session', { key: 'admin-session' })
  if (error.value) return navigateTo('/login')
})
