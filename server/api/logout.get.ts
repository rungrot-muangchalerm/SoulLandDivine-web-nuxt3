export default defineEventHandler((event) => {
  deleteCookie(event, 'userRandom', { path: '/' })
  deleteCookie(event, 'username', { path: '/' })
  deleteCookie(event, 'channel', { path: '/' })
  return sendRedirect(event, '/login')
})
