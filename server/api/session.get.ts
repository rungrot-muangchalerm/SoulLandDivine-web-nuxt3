import { getAdminSession } from '../utils/admin-session'

export default defineEventHandler(async (event) => {
  const session = await getAdminSession(event)
  return {
    username: session.username,
    authorization: session.authorization,
    channel: '*',
  }
})
