const publicPaths = new Set(['/login', '/403', '/404'])

export default defineNuxtRouteMiddleware(async (to) => {
  if (to.path === '/login') {
    const { data: session, error } = await useFetch<{ authorization: string }>('/api/session')
    if (!error.value && session.value) {
      return navigateTo(session.value.authorization === 'server' ? '/server' : '/role')
    }
    return
  }

  if (publicPaths.has(to.path)) return

  const { error } = await useFetch('/api/session', { key: 'admin-session' })
  if (error.value) return navigateTo('/login')
})
