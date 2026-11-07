import { createHash } from 'node:crypto'
import { getGameDatabase } from '../utils/database'

export default defineNitroPlugin(async () => {
  const config = useRuntimeConfig()
  const username = config.adminDefaultUsername
  const password = config.adminDefaultPassword

  if (!username && !password) return
  if (!username || !password) {
    throw new Error('Both ADMIN_DEFAULT_USERNAME and ADMIN_DEFAULT_PASSWORD must be set')
  }

  const storedPassword = createHash('md5').update(username + password, 'utf8').digest('hex')
  const [result] = await getGameDatabase().execute(
    `INSERT IGNORE INTO admin_user (username, password, authorization, channel)
     SELECT ?, ?, 'admin', '*'
     WHERE NOT EXISTS (SELECT 1 FROM admin_user LIMIT 1)`,
    [username, storedPassword],
  )

  if ('affectedRows' in result && result.affectedRows > 0) {
    console.info(`Initialized default admin account "${username}"`)
  }
})
